import secrets as _secrets
from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session

from app.core import config
from app.core.dependencies import get_db
from app.core.security import create_access_token, hash_password
from app.models.user import User
from app.services.otp_delivery import OtpDeliveryError, build_delivery_channel
from app.services.otp_service import InvalidOtp, OtpService, RateLimited

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])

_channel = build_delivery_channel()


class OtpRequestIn(BaseModel):
    identifier: EmailStr


class OtpVerifyIn(BaseModel):
    identifier: EmailStr
    code: str = Field(min_length=6, max_length=6, pattern=r"^\d{6}$")


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


def _client_ip(request: Request) -> str | None:
    # Render and most PaaS front ends set X-Forwarded-For.
    fwd = request.headers.get("x-forwarded-for")
    if fwd:
        return fwd.split(",")[0].strip()
    return request.client.host if request.client else None


def _get_or_create_user(db: Session, email: str) -> User:
    user = db.query(User).filter(User.email == email).first()
    if user:
        return user
    # User.password is NOT NULL, so store an unusable random hash. There is no
    # password login path for OTP users; this only satisfies the constraint.
    user = User(
        name=email.split("@")[0],
        email=email,
        password=hash_password(_secrets.token_urlsafe(32)),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.post("/otp/request", status_code=status.HTTP_202_ACCEPTED)
async def request_otp(
    payload: OtpRequestIn,
    request: Request,
    db: Session = Depends(get_db),
):
    service = OtpService(db, _channel)
    try:
        issued = await service.issue(payload.identifier, ip=_client_ip(request))
    except RateLimited as exc:
        raise HTTPException(
            status.HTTP_429_TOO_MANY_REQUESTS,
            detail=exc.message,
            headers={"Retry-After": str(exc.retry_after or 60)},
        )
    except OtpDeliveryError:
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY,
            detail="Could not send the code right now. Please try again.",
        )
    # Deliberately does not reveal whether the address is registered.
    return {
        "detail": "If that address is valid, a code has been sent.",
        "expires_in": issued.expires_in,
    }


@router.post("/otp/verify", response_model=TokenOut)
def verify_otp(payload: OtpVerifyIn, db: Session = Depends(get_db)):
    service = OtpService(db, _channel)
    try:
        service.verify(payload.identifier, payload.code)
    except InvalidOtp as exc:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail=exc.message)

    user = _get_or_create_user(db, payload.identifier.strip().lower())

    access = create_access_token({"sub": str(user.id), "type": "access"})
    refresh = create_access_token(
        {"sub": str(user.id), "type": "refresh"},
        expires_delta=timedelta(days=config.REFRESH_TOKEN_EXPIRE_DAYS),
    )
    return TokenOut(access_token=access, refresh_token=refresh)
