from datetime import timedelta
import pytest

from app.core.security import create_access_token
from app.seed import DEMO_APPLICATION_ID, DEMO_STUDENT_ID, DEMO_USER_ID


def test_auth_login_success_with_email(client, seeded_db):
    """Test successful login using email and password."""
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "demo.student@example.com",
            "password": "DemoPassword123!",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert isinstance(data["access_token"], str)
    assert len(data["access_token"]) > 20
    assert data["token_type"] == "bearer"


def test_auth_login_success_with_username(client, seeded_db):
    """Test successful login using username and password."""
    response = client.post(
        "/api/v1/auth/login",
        json={
            "username": "Demo Student User",
            "password": "DemoPassword123!",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_auth_login_invalid_password(client, seeded_db):
    """Test login failure with wrong password."""
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "demo.student@example.com",
            "password": "WrongPassword!",
        },
    )
    assert response.status_code == 401
    assert response.json()["detail"] == "Invalid credentials"


def test_auth_login_nonexistent_user(client, seeded_db):
    """Test login failure with non-existent user."""
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "unknown.user@example.com",
            "password": "DemoPassword123!",
        },
    )
    assert response.status_code == 401
    assert response.json()["detail"] == "Invalid credentials"


def test_protected_endpoints_missing_auth_header(client, seeded_db):
    """Protected endpoints reject requests missing the Authorization header with 401."""
    endpoints = [
        "/api/v1/auth/me",
        "/api/v1/users/me",
        "/api/v1/students/me",
        "/api/v1/notifications/me",
        "/api/v1/applications/me",
    ]
    for ep in endpoints:
        res = client.get(ep)
        assert res.status_code == 401
        assert "Authorization" in res.json()["detail"] or "authenticated" in res.json()["detail"].lower()


def test_protected_endpoints_malformed_and_invalid_jwt(client, seeded_db):
    """Protected endpoints reject malformed or invalid signatures with 401."""
    # Non-JWT string
    res1 = client.get("/api/v1/auth/me", headers={"Authorization": "Bearer not-a-jwt"})
    assert res1.status_code == 401
    assert "Invalid token" in res1.json()["detail"]

    # Tampered signature
    valid_token = create_access_token({"sub": DEMO_USER_ID})
    tampered_token = valid_token[:-5] + "XXXXX"
    res2 = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {tampered_token}"})
    assert res2.status_code == 401
    assert "Invalid token" in res2.json()["detail"]

    # Non-Bearer scheme
    res3 = client.get("/api/v1/auth/me", headers={"Authorization": "Basic dXNlcjpwYXNz"})
    assert res3.status_code == 401
    assert "Bearer required" in res3.json()["detail"]


def test_protected_endpoints_expired_jwt(client, seeded_db):
    """Protected endpoints reject expired JWT tokens with 401."""
    expired_token = create_access_token(
        {"sub": DEMO_USER_ID},
        expires_delta=timedelta(seconds=-10),
    )
    res = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {expired_token}"},
    )
    assert res.status_code == 401
    assert "expired" in res.json()["detail"].lower()


def test_authenticated_requests_succeed(client, seeded_db):
    """Authenticated requests with valid Bearer token succeed across protected endpoints."""
    # Obtain token
    login_res = client.post(
        "/api/v1/auth/login",
        json={
            "email": "demo.student@example.com",
            "password": "DemoPassword123!",
        },
    )
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # /auth/me
    auth_me = client.get("/api/v1/auth/me", headers=headers)
    assert auth_me.status_code == 200
    assert auth_me.json()["id"] == DEMO_USER_ID
    assert auth_me.json()["email"] == "demo.student@example.com"

    # /users/me
    users_me = client.get("/api/v1/users/me", headers=headers)
    assert users_me.status_code == 200
    assert users_me.json()["id"] == DEMO_USER_ID

    # /students/me
    students_me = client.get("/api/v1/students/me", headers=headers)
    assert students_me.status_code == 200
    assert students_me.json()["id"] == DEMO_STUDENT_ID
    assert students_me.json()["user_id"] == DEMO_USER_ID

    # /notifications/me
    notif_me = client.get("/api/v1/notifications/me", headers=headers)
    assert notif_me.status_code == 200
    assert isinstance(notif_me.json(), list)
    assert len(notif_me.json()) >= 1

    # /applications/me
    apps_me = client.get("/api/v1/applications/me", headers=headers)
    assert apps_me.status_code == 200
    assert isinstance(apps_me.json(), list)
    assert len(apps_me.json()) >= 1
    assert apps_me.json()[0]["id"] == DEMO_APPLICATION_ID


def test_passwords_never_returned_in_api_responses(client, seeded_db):
    """Verify that password fields are never exposed in any API response."""
    # 1. Login response
    login_res = client.post(
        "/api/v1/auth/login",
        json={
            "email": "demo.student@example.com",
            "password": "DemoPassword123!",
        },
    )
    assert login_res.status_code == 200
    assert "password" not in login_res.json()

    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. /auth/me profile
    auth_me = client.get("/api/v1/auth/me", headers=headers)
    assert auth_me.status_code == 200
    assert "password" not in auth_me.json()

    # 3. /users/me profile
    users_me = client.get("/api/v1/users/me", headers=headers)
    assert users_me.status_code == 200
    assert "password" not in users_me.json()

    # 4. User registration response
    reg_res = client.post(
        "/api/v1/users",
        json={
            "name": "Audit Applicant",
            "email": "audit.applicant@example.com",
            "password": "TestPassword123!",
        },
    )
    assert reg_res.status_code == 200
    assert "password" not in reg_res.json()

    # 5. Legacy login response
    legacy_res = client.post(
        "/api/v1/users/login",
        json={
            "email": "audit.applicant@example.com",
            "password": "TestPassword123!",
        },
    )
    assert legacy_res.status_code == 200
    assert "password" not in legacy_res.json()


def test_jago_authenticated_context_resolves_student_and_application(client, seeded_db):
    """Authenticated JAGO requests automatically resolve current user's student and application."""
    # Log in as demo student
    login_res = client.post(
        "/api/v1/auth/login",
        json={
            "email": "demo.student@example.com",
            "password": "DemoPassword123!",
        },
    )
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Application status query without providing application_id or student_id
    status_res = client.post(
        "/api/v1/jago/conversations/conv-auth-1/messages",
        headers=headers,
        json={"message": "Check my application status"},
    )
    assert status_res.status_code == 200
    status_data = status_res.json()
    assert status_data["intent"] == "APPLICATION_STATUS"
    assert DEMO_APPLICATION_ID in status_data["message"]
    assert status_data["data"]["id"] == DEMO_APPLICATION_ID
    assert status_data["data"]["status"] == "DRAFT"

    # 2. Deficiencies query without providing application_id
    defic_res = client.post(
        "/api/v1/jago/conversations/conv-auth-2/messages",
        headers=headers,
        json={"message": "What documents are missing?"},
    )
    assert defic_res.status_code == 200
    defic_data = defic_res.json()
    assert defic_data["intent"] == "APPLICATION_DEFICIENCIES"
    assert DEMO_APPLICATION_ID in defic_data["message"]
    assert defic_data["data"]["application_id"] == DEMO_APPLICATION_ID

    # 3. Payment status query without providing application_id
    pay_res = client.post(
        "/api/v1/jago/conversations/conv-auth-3/messages",
        headers=headers,
        json={"message": "What is my payment status?"},
    )
    assert pay_res.status_code == 200
    pay_data = pay_res.json()
    assert pay_data["intent"] == "PAYMENT_STATUS"
    assert pay_data["data"]["application_id"] == DEMO_APPLICATION_ID

    # 4. Eligibility check without providing student_id
    elig_res = client.post(
        "/api/v1/jago/conversations/conv-auth-4/messages",
        headers=headers,
        json={"message": "Am I eligible?"},
    )
    assert elig_res.status_code == 200
    elig_data = elig_res.json()
    assert elig_data["intent"] == "ELIGIBILITY"
    assert elig_data["data"]["student_id"] == DEMO_STUDENT_ID

    # 5. Explicit application_id in message overrides user context
    explicit_id = "00000000-0000-0000-0000-999999999999"
    override_res = client.post(
        "/api/v1/jago/conversations/conv-auth-5/messages",
        headers=headers,
        json={"message": f"Check status for {explicit_id}"},
    )
    assert override_res.status_code == 200
    override_data = override_res.json()
    assert explicit_id in override_data["message"]
