import base64
from datetime import datetime, timedelta, timezone
import hashlib
import hmac
import json
import time
import bcrypt

from app.core.config import (
    JWT_SECRET,
    JWT_ALGORITHM,
    ACCESS_TOKEN_EXPIRE_MINUTES,
)


class TokenError(Exception):
    """Base exception for authentication token errors."""
    pass


class TokenExpiredError(TokenError):
    """Raised when an authentication token has expired."""
    pass


class TokenInvalidError(TokenError):
    """Raised when an authentication token is malformed or invalid."""
    pass


def hash_password(password: str) -> str:
    password_bytes = password.encode("utf-8")
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password_bytes, salt).decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(
            plain_password.encode("utf-8"),
            hashed_password.encode("utf-8")
        )
    except Exception:
        return False


def _b64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("utf-8")


def _b64url_decode(segment: str) -> bytes:
    padding = "=" * ((4 - len(segment) % 4) % 4)
    return base64.urlsafe_b64decode(segment + padding)


def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    """Generate a standard RFC 7519 HS256 JWT access token."""
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    if expires_delta is not None:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update({
        "iat": int(now.timestamp()),
        "exp": int(expire.timestamp()),
    })

    header = {"alg": JWT_ALGORITHM, "typ": "JWT"}
    header_json = json.dumps(header, separators=(",", ":"), sort_keys=True).encode("utf-8")
    payload_json = json.dumps(to_encode, separators=(",", ":"), sort_keys=True).encode("utf-8")

    header_b64 = _b64url_encode(header_json)
    payload_b64 = _b64url_encode(payload_json)

    signing_input = f"{header_b64}.{payload_b64}".encode("utf-8")
    signature = hmac.new(
        JWT_SECRET.encode("utf-8"),
        signing_input,
        hashlib.sha256,
    ).digest()
    sig_b64 = _b64url_encode(signature)

    return f"{header_b64}.{payload_b64}.{sig_b64}"


def decode_access_token(token: str) -> dict:
    """Verify and decode an RFC 7519 HS256 JWT access token."""
    if not isinstance(token, str):
        raise TokenInvalidError("Token must be a string")

    parts = token.strip().split(".")
    if len(parts) != 3:
        raise TokenInvalidError("Token must contain exactly 3 segments")

    header_b64, payload_b64, sig_b64 = parts

    try:
        header_bytes = _b64url_decode(header_b64)
        header = json.loads(header_bytes.decode("utf-8"))
    except Exception as exc:
        raise TokenInvalidError("Malformed token header") from exc

    if not isinstance(header, dict) or header.get("alg") != JWT_ALGORITHM:
        raise TokenInvalidError(f"Unsupported token algorithm: {header.get('alg') if isinstance(header, dict) else 'none'}")

    signing_input = f"{header_b64}.{payload_b64}".encode("utf-8")
    expected_sig = hmac.new(
        JWT_SECRET.encode("utf-8"),
        signing_input,
        hashlib.sha256,
    ).digest()
    expected_sig_b64 = _b64url_encode(expected_sig)

    if not hmac.compare_digest(sig_b64, expected_sig_b64):
        raise TokenInvalidError("Invalid token signature")

    try:
        payload_bytes = _b64url_decode(payload_b64)
        payload = json.loads(payload_bytes.decode("utf-8"))
    except Exception as exc:
        raise TokenInvalidError("Malformed token payload") from exc

    if not isinstance(payload, dict):
        raise TokenInvalidError("Token payload must be a JSON object")

    exp = payload.get("exp")
    if exp is not None:
        try:
            exp_int = int(exp)
            if time.time() > exp_int:
                raise TokenExpiredError("Token has expired")
        except TokenExpiredError:
            raise
        except Exception as exc:
            raise TokenInvalidError("Invalid expiration claim") from exc

    return payload