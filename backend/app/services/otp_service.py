from __future__ import annotations

import hashlib
import hmac
import secrets
from dataclasses import dataclass
from datetime import timedelta

from sqlalchemy import func as sa_func
from sqlalchemy.orm import Session

from app.core import config
from app.models.otp_token import OtpToken, utcnow
from app.services.otp_delivery import OtpDeliveryChannel


class OtpError(Exception):
    def __init__(self, message: str, retry_after: int | None = None):
        super().__init__(message)
        self.message = message
        self.retry_after = retry_after


class RateLimited(OtpError):
    pass


class InvalidOtp(OtpError):
    pass


@dataclass(frozen=True)
class IssuedOtp:
    identifier: str
    expires_in: int


def _digest(code: str) -> str:
    """HMAC-SHA256 of the code under the server secret.

    HMAC rather than a bare hash: a 6-digit code has only 10^6 possibilities,
    so a leaked database with plain SHA-256 digests would be reversed in
    seconds. With HMAC the attacker also needs the server secret.
    """
    return hmac.new(
        config.OTP_HMAC_SECRET.encode(), code.encode(), hashlib.sha256
    ).hexdigest()


def _generate_code() -> str:
    """Uniform 6-digit code. secrets, never random."""
    return f"{secrets.randbelow(1_000_000):06d}"


def normalise_identifier(identifier: str) -> str:
    return identifier.strip().lower()


class OtpService:
    def __init__(self, db: Session, channel: OtpDeliveryChannel):
        self.db = db
        self.channel = channel

    # -- issuance ---------------------------------------------------------

    def _count_recent(self, column, value: str, seconds: int) -> int:
        since = utcnow() - timedelta(seconds=seconds)
        return (
            self.db.query(sa_func.count(OtpToken.id))
            .filter(column == value, OtpToken.created_at >= since)
            .scalar()
            or 0
        )

    def _enforce_rate_limits(self, identifier: str, ip: str | None) -> None:
        # 1 per minute and 5 per hour, per identifier AND per IP.
        checks = (
            (OtpToken.identifier, identifier, 60, 1),
            (OtpToken.identifier, identifier, 3600, 5),
            (OtpToken.request_ip, ip, 60, 1),
            (OtpToken.request_ip, ip, 3600, 5),
        )
        for column, value, window, limit in checks:
            if not value:
                continue
            if self._count_recent(column, value, window) >= limit:
                raise RateLimited(
                    "Too many requests. Please wait before trying again.",
                    retry_after=window,
                )

    async def issue(
        self,
        identifier: str,
        *,
        purpose: str = "login",
        ip: str | None = None,
    ) -> IssuedOtp:
        identifier = normalise_identifier(identifier)
        self._enforce_rate_limits(identifier, ip)

        # Invalidate any outstanding code so only the newest one works.
        (
            self.db.query(OtpToken)
            .filter(
                OtpToken.identifier == identifier,
                OtpToken.purpose == purpose,
                OtpToken.consumed_at.is_(None),
            )
            .update({"consumed_at": utcnow()}, synchronize_session=False)
        )

        code = _generate_code()
        token = OtpToken(
            identifier=identifier,
            purpose=purpose,
            otp_hash=_digest(code),
            expires_at=utcnow() + timedelta(seconds=config.OTP_TTL_SECONDS),
            attempt_count=0,
            request_ip=ip,
            created_at=utcnow(),
        )
        self.db.add(token)
        self.db.commit()

        # Deliver after commit: a delivery failure must not leave a live code
        # that the database has no record of.
        await self.channel.send(identifier, code)
        return IssuedOtp(identifier, config.OTP_TTL_SECONDS)

    # -- verification -----------------------------------------------------

    def verify(self, identifier: str, code: str, *, purpose: str = "login") -> None:
        """Raises InvalidOtp on failure, returns None on success."""
        identifier = normalise_identifier(identifier)

        token = (
            self.db.query(OtpToken)
            .filter(
                OtpToken.identifier == identifier,
                OtpToken.purpose == purpose,
                OtpToken.consumed_at.is_(None),
            )
            .order_by(OtpToken.created_at.desc(), OtpToken.id.desc())
            .first()
        )

        # One message for every failure mode. Distinct messages would reveal
        # which email addresses are registered.
        generic = "Invalid or expired code."

        if token is None or token.is_expired:
            raise InvalidOtp(generic)

        token.attempt_count += 1
        if token.attempt_count >= config.OTP_MAX_ATTEMPTS:
            token.consumed_at = utcnow()  # burn it
            self.db.commit()
            raise InvalidOtp(generic)

        if not hmac.compare_digest(token.otp_hash, _digest(code)):
            self.db.commit()  # persist the incremented attempt count
            raise InvalidOtp(generic)

        token.consumed_at = utcnow()
        self.db.commit()
