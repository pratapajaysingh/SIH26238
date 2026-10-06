import pytest
from app.core.security import hash_password, verify_password, decode_access_token, create_access_token
from app.models.user import User
from app.seed import (
    seed_database,
    DEMO_USER_ID,
    DEMO_USER_ID_2,
    DEMO_USER_ID_3,
    DEMO_USER_ID_4,
    DEMO_ADMIN_USER_ID,
)
from app.api import auth_otp


def test_seeded_users_cannot_log_in_with_old_hardcoded_passwords(client, db_session, monkeypatch):
    """Seeded users get unusable passwords and verify_password fails for all old credentials."""
    monkeypatch.setenv("ADMIN_EMAIL", "admin.mota@tribalsetu.gov.in")
    seed_database(db_session, reset=True)

    old_credentials = [
        ("demo.student@example.com", "DemoPassword123!"),
        ("demo.student2@example.com", "DemoPassword456!"),
        ("demo.student3@example.com", "DemoPassword789!"),
        ("demo.student4@example.com", "DemoPassword012!"),
        ("admin.mota@tribalsetu.gov.in", "AdminSecret123!"),
    ]

    for identifier, password in old_credentials:
        user = db_session.query(User).filter(User.email == identifier).first()
        if user:
            assert verify_password(password, user.password) is False, f"User {identifier} password matched old password!"

    # Test existing rows overwrite on database re-seed
    # 1. Manually set a known password hash simulating an old pre-existing database row
    student = db_session.query(User).filter(User.email == "demo.student@example.com").first()
    assert student is not None
    student.password = hash_password("ValidPassword123!")
    db_session.commit()

    assert verify_password("ValidPassword123!", student.password) is True

    # 2. Run seed again without reset (existing row update scenario)
    seed_database(db_session, reset=False)

    # 3. Old password must now be overwritten with an unusable value
    db_session.refresh(student)
    assert verify_password("ValidPassword123!", student.password) is False


def test_removed_routes_return_404_or_405(client):
    """POST to removed password login and registration routes returns 404 or 405."""
    # POST /api/v1/auth/login removed -> 404
    r1 = client.post("/api/v1/auth/login", json={"email": "demo.student@example.com", "password": "x"})
    assert r1.status_code == 404

    # POST /api/v1/users removed -> 404 or 405
    r2 = client.post("/api/v1/users", json={"name": "test", "email": "test@example.com", "password": "x"})
    assert r2.status_code in (404, 405)

    # POST /api/v1/users/login removed -> 404
    r3 = client.post("/api/v1/users/login", json={"email": "test@example.com", "password": "x"})
    assert r3.status_code == 404


def test_student_in_db_refused_on_admin_endpoint_even_if_token_carries_admin_role(client, db_session):
    """A user whose DB role is STUDENT is refused on an admin endpoint even if their JWT token claims ADMIN."""
    import uuid
    student_user = User(
        id=str(uuid.uuid4()),
        name="Student Attacker",
        email="attacker.student@example.com",
        role="STUDENT",
        password=hash_password("RandomUnusablePassword123!"),
    )
    db_session.add(student_user)
    db_session.commit()
    db_session.refresh(student_user)

    # Craft a JWT token carrying forged role="ADMIN" claim
    forged_admin_token = create_access_token({"sub": str(student_user.id), "role": "ADMIN"})
    headers = {"Authorization": f"Bearer {forged_admin_token}"}

    # Protected admin endpoints must check current_user.role from DB, not from JWT claim
    r_manual = client.get("/api/v1/manual-reviews", headers=headers)
    assert r_manual.status_code == 403
    assert "Student accounts cannot access" in r_manual.json()["detail"]

    r_analytics = client.get("/api/v1/analytics/dashboard", headers=headers)
    assert r_analytics.status_code == 403
    assert "Admin role required" in r_analytics.json()["detail"]


def test_seed_with_admin_email_unset_creates_no_admin(db_session, monkeypatch):
    """When ADMIN_EMAIL is unset, seed creates no admin account."""
    monkeypatch.delenv("ADMIN_EMAIL", raising=False)

    counts = seed_database(db_session, reset=True)

    # Only 4 student demo users should be created
    assert counts["users"] == 4

    admin = db_session.query(User).filter(User.role == "ADMIN").first()
    assert admin is None

    admin_by_id = db_session.query(User).filter(User.id == DEMO_ADMIN_USER_ID).first()
    assert admin_by_id is None


@pytest.mark.anyio
async def test_seeded_admin_can_complete_otp_flow_and_receives_admin_role_in_token(
    client, db_session, monkeypatch
):
    """Seeded admin logs in via standard email OTP flow and receives ADMIN role in access token."""
    admin_email = "admin.official@tribalsetu.gov.in"
    monkeypatch.setenv("ADMIN_EMAIL", admin_email)

    seed_database(db_session, reset=True)

    admin_user = db_session.query(User).filter(User.email == admin_email).first()
    assert admin_user is not None
    assert admin_user.role == "ADMIN"

    # Capture delivered OTP
    captured = []

    async def mock_send(identifier: str, code: str):
        captured.append((identifier, code))

    monkeypatch.setattr(auth_otp._channel, "send", mock_send)

    # 1. Admin requests OTP via standard endpoint
    req_res = client.post(
        "/api/v1/auth/otp/request",
        json={"identifier": admin_email},
    )
    assert req_res.status_code == 202
    assert len(captured) == 1
    sent_identifier, sent_code = captured[0]
    assert sent_identifier == admin_email

    # 2. Admin verifies OTP code via standard endpoint
    verify_res = client.post(
        "/api/v1/auth/otp/verify",
        json={"identifier": admin_email, "code": sent_code},
    )
    assert verify_res.status_code == 200
    token_data = verify_res.json()
    assert "access_token" in token_data

    # 3. Decoded token must contain ADMIN role claim and admin sub ID
    access_token = token_data["access_token"]
    claims = decode_access_token(access_token)
    assert claims.get("role") == "ADMIN"
    assert claims.get("sub") == str(admin_user.id)
