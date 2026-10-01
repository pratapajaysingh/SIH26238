from __future__ import annotations

import logging
from typing import Protocol

import httpx

from app.core import config

logger = logging.getLogger(__name__)


class OtpDeliveryError(RuntimeError):
    """Raised when a channel could not deliver the code."""


class OtpDeliveryChannel(Protocol):
    name: str

    async def send(self, identifier: str, code: str) -> None: ...


class ConsoleOtpChannel:
    """Development only. Prints the code to the server log.

    Refuses to construct in production so a misconfigured deploy fails loudly
    instead of quietly writing codes to stdout.
    """

    name = "console"

    def __init__(self) -> None:
        if config.ENVIRONMENT == "production":
            raise RuntimeError("ConsoleOtpChannel must never be used in production.")

    async def send(self, identifier: str, code: str) -> None:
        logger.warning("[DEV OTP] %s -> %s", identifier, code)


class ResendEmailOtpChannel:
    """Delivers via Resend's HTTP API. Free tier, no credit card required."""

    name = "email"
    ENDPOINT = "https://api.resend.com/emails"

    def __init__(self) -> None:
        if not config.RESEND_API_KEY:
            raise RuntimeError("RESEND_API_KEY is not configured.")

    async def send(self, identifier: str, code: str) -> None:
        minutes = config.OTP_TTL_SECONDS // 60
        payload = {
            "from": config.OTP_EMAIL_SENDER,
            "to": [identifier],
            "subject": f"{code} is your TribalSetu verification code",
            "text": (
                f"Your TribalSetu verification code is {code}.\n\n"
                f"It expires in {minutes} minutes. Do not share it with anyone.\n\n"
                "If you did not request this code, you can ignore this email."
            ),
        }
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.post(
                    self.ENDPOINT,
                    json=payload,
                    headers={"Authorization": f"Bearer {config.RESEND_API_KEY}"},
                )
        except httpx.HTTPError as exc:
            raise OtpDeliveryError("email provider unreachable") from exc

        if resp.status_code >= 400:
            # Never log the code or the raw body.
            logger.error("Resend rejected send: HTTP %s", resp.status_code)
            raise OtpDeliveryError("email provider rejected the request")


class SmsOtpChannel:
    """NOT ACTIVE.

    Real SMS in India needs a paid gateway plus TRAI DLT registration as a
    Principal Entity, which requires a registered business. The interface
    exists so a gateway can be dropped in later without touching the engine.
    Do not advertise SMS OTP in the UI or docs.
    """

    name = "sms"

    async def send(self, identifier: str, code: str) -> None:
        raise OtpDeliveryError(
            "SMS delivery is not activated: requires a paid gateway and DLT "
            "sender-ID registration."
        )


_CHANNELS = {
    "console": ConsoleOtpChannel,
    "email": ResendEmailOtpChannel,
    "sms": SmsOtpChannel,
}


def build_delivery_channel() -> OtpDeliveryChannel:
    try:
        return _CHANNELS[config.OTP_DELIVERY_CHANNEL]()
    except KeyError:
        raise RuntimeError(
            f"Unknown OTP_DELIVERY_CHANNEL: {config.OTP_DELIVERY_CHANNEL!r}"
        )
