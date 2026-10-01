from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, Index, Integer, String
from sqlalchemy.sql import func

from app.core.database import Base


def utcnow() -> datetime:
    """Timezone-aware UTC. Avoids the deprecated datetime.utcnow()."""
    return datetime.now(timezone.utc)


class OtpToken(Base):
    """One issued OTP. Only the HMAC digest is stored, never the code itself."""

    __tablename__ = "otp_tokens"

    id = Column(Integer, primary_key=True, autoincrement=True)

    identifier = Column(String(255), nullable=False)      # normalised email
    purpose = Column(String(32), nullable=False, default="login")

    otp_hash = Column(String(64), nullable=False)          # hex sha256 digest
    expires_at = Column(DateTime(timezone=True), nullable=False)
    consumed_at = Column(DateTime(timezone=True), nullable=True)
    attempt_count = Column(Integer, nullable=False, default=0)

    request_ip = Column(String(64), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False,
                        server_default=func.now())

    __table_args__ = (
        Index("ix_otp_identifier_created", "identifier", "created_at"),
        Index("ix_otp_ip_created", "request_ip", "created_at"),
    )

    @property
    def is_expired(self) -> bool:
        expires = self.expires_at
        # SQLite returns naive datetimes; normalise before comparing.
        if expires.tzinfo is None:
            expires = expires.replace(tzinfo=timezone.utc)
        return utcnow() >= expires
