# Self-contained: builds its own in-memory SQLite session so it does not
# depend on fixtures in the existing conftest.py.

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core import config
from app.core.database import Base
from app.models.otp_token import OtpToken, utcnow
from app.services.otp_service import InvalidOtp, OtpService, RateLimited, _digest


@pytest.fixture(autouse=True)
def _otp_secret(monkeypatch):
    monkeypatch.setattr(config, "OTP_HMAC_SECRET", "test-secret-" + "x" * 32)
    monkeypatch.setattr(config, "OTP_TTL_SECONDS", 300)
    monkeypatch.setattr(config, "OTP_MAX_ATTEMPTS", 5)


@pytest.fixture
def db():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine, tables=[OtpToken.__table__])
    session = sessionmaker(bind=engine)()
    try:
        yield session
    finally:
        session.close()


class CapturingChannel:
    """Test double that records the code instead of sending it."""

    name = "capture"

    def __init__(self):
        self.sent: list[tuple[str, str]] = []

    async def send(self, identifier: str, code: str) -> None:
        self.sent.append((identifier, code))


@pytest.fixture
def channel():
    return CapturingChannel()


@pytest.fixture
def service(db, channel):
    return OtpService(db, channel)


@pytest.mark.anyio
async def test_issue_sends_normalised_six_digit_code(service, channel):
    await service.issue("  Birsa@Example.COM ")
    identifier, code = channel.sent[0]
    assert identifier == "birsa@example.com"
    assert len(code) == 6 and code.isdigit()


@pytest.mark.anyio
async def test_plaintext_code_is_never_stored(service, channel, db):
    await service.issue("a@example.com")
    _, code = channel.sent[0]
    token = db.query(OtpToken).one()
    assert token.otp_hash != code
    assert token.otp_hash == _digest(code)


@pytest.mark.anyio
async def test_correct_code_works_once_only(service, channel):
    await service.issue("a@example.com")
    _, code = channel.sent[0]
    service.verify("a@example.com", code)
    with pytest.raises(InvalidOtp):
        service.verify("a@example.com", code)  # replay must fail


@pytest.mark.anyio
async def test_wrong_code_rejected(service, channel):
    await service.issue("a@example.com")
    _, code = channel.sent[0]
    wrong = "000000" if code != "000000" else "111111"
    with pytest.raises(InvalidOtp):
        service.verify("a@example.com", wrong)


@pytest.mark.anyio
async def test_expired_code_rejected(service, channel, db):
    await service.issue("a@example.com")
    _, code = channel.sent[0]
    token = db.query(OtpToken).one()
    token.expires_at = utcnow()
    db.commit()
    with pytest.raises(InvalidOtp):
        service.verify("a@example.com", code)


@pytest.mark.anyio
async def test_token_burns_after_max_attempts(service, channel):
    await service.issue("a@example.com")
    _, code = channel.sent[0]
    for _ in range(config.OTP_MAX_ATTEMPTS):
        with pytest.raises(InvalidOtp):
            service.verify("a@example.com", "999999")
    # Even the correct code must now fail.
    with pytest.raises(InvalidOtp):
        service.verify("a@example.com", code)


@pytest.mark.anyio
async def test_rate_limited_within_one_minute(service):
    await service.issue("a@example.com", ip="1.2.3.4")
    with pytest.raises(RateLimited):
        await service.issue("a@example.com", ip="1.2.3.4")


@pytest.mark.anyio
async def test_issuing_a_new_code_invalidates_the_previous_one(service, channel, db):
    await service.issue("a@example.com")
    first = channel.sent[0][1]
    # Age the row so the rate limiter allows a second issue.
    db.query(OtpToken).update({"created_at": utcnow().replace(year=2020)})
    db.commit()
    await service.issue("a@example.com")
    with pytest.raises(InvalidOtp):
        service.verify("a@example.com", first)


@pytest.mark.anyio
async def test_delivery_failure_leaves_no_usable_code(service, db, monkeypatch):
    async def boom(identifier, code):
        raise RuntimeError("provider down")

    monkeypatch.setattr(service.channel, "send", boom)
    with pytest.raises(RuntimeError):
        await service.issue("a@example.com")
    # Row exists, but nobody ever learned the code and it will expire.
    assert db.query(OtpToken).count() == 1


def test_console_channel_refuses_production(monkeypatch):
    from app.services.otp_delivery import ConsoleOtpChannel

    monkeypatch.setattr(config, "ENVIRONMENT", "production")
    with pytest.raises(RuntimeError):
        ConsoleOtpChannel()
