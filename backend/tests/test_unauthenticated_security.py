"""Comprehensive security tests verifying that:
1. Endpoints reading or writing student application/document data reject unauthenticated requests (NO Authorization header) with 401 Unauthorized.
2. Cross-student access is strictly forbidden (Student A receives 403 Forbidden or 404 Not Found on Student B's application).
"""
import pytest
from app.core.security import create_access_token, hash_password
from app.seed import (
    DEMO_APPLICATION_ID,
    DEMO_DOCUMENTS,
    DEMO_SCHOLARSHIPS,
    DEMO_STUDENT_ID,
)


# ---------------------------------------------------------------------------
# 1. Unauthenticated Access Assertions (NO Authorization Header -> 401)
# ---------------------------------------------------------------------------

def test_unauthenticated_get_applications_returns_401(client, seeded_db):
    """GET /applications with NO Authorization header returns 401."""
    res = client.get("/api/v1/applications")
    assert res.status_code == 401


def test_unauthenticated_get_documents_returns_401(client, seeded_db):
    """GET /documents with NO Authorization header returns 401."""
    res = client.get("/api/v1/documents")
    assert res.status_code == 401


def test_unauthenticated_get_application_status_returns_401(client, seeded_db):
    """GET /applications/{id}/status with NO Authorization header returns 401."""
    res = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/status")
    assert res.status_code == 401


def test_unauthenticated_get_application_timeline_returns_401(client, seeded_db):
    """GET /applications/{id}/timeline with NO Authorization header returns 401."""
    res = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/timeline")
    assert res.status_code == 401


def test_unauthenticated_get_application_deficiencies_returns_401(client, seeded_db):
    """GET /applications/{id}/deficiencies with NO Authorization header returns 401."""
    res = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/deficiencies")
    assert res.status_code == 401


def test_unauthenticated_get_application_payment_status_returns_401(client, seeded_db):
    """GET /applications/{id}/payment-status with NO Authorization header returns 401."""
    res = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/payment-status")
    assert res.status_code == 401


def test_unauthenticated_get_application_payments_alias_returns_401(client, seeded_db):
    """GET /applications/{id}/payments with NO Authorization header returns 401."""
    res = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/payments")
    assert res.status_code == 401


def test_unauthenticated_get_application_documents_returns_401(client, seeded_db):
    """GET /applications/{id}/documents with NO Authorization header returns 401."""
    res = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/documents")
    assert res.status_code == 401


def test_unauthenticated_post_application_returns_401(client, seeded_db):
    """POST /applications with NO Authorization header returns 401."""
    res = client.post(
        "/api/v1/applications",
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    assert res.status_code == 401


def test_unauthenticated_post_application_documents_returns_401(client, seeded_db):
    """POST /applications/{id}/documents with NO Authorization header returns 401."""
    res = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/documents",
        json={"document_id": DEMO_DOCUMENTS[0]["id"]},
    )
    assert res.status_code == 401


def test_unauthenticated_post_application_transition_returns_401(client, seeded_db):
    """POST /applications/{id}/transition with NO Authorization header returns 401."""
    res = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/transition",
        json={"status": "SUBMITTED"},
    )
    assert res.status_code == 401


def test_unauthenticated_patch_application_status_returns_401(client, seeded_db):
    """PATCH /applications/{id}/status with NO Authorization header returns 401."""
    res = client.patch(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/status",
        json={"status": "SUBMITTED"},
    )
    assert res.status_code == 401



# ---------------------------------------------------------------------------
# 2. Cross-Student Ownership Assertions (Student A accessing Student B -> 403/404)
# ---------------------------------------------------------------------------

@pytest.fixture
def two_students_setup(client, seeded_db):
    """Create Student A and Student B with their tokens and an application for Student B."""
    import uuid
    from app.models.user import User

    # Register and setup Student A
    user_a = User(
        id=str(uuid.uuid4()),
        email="student_a_sec@example.com",
        name="A",
        password=hash_password("UnusableSecret123!"),
        role="STUDENT",
    )
    seeded_db.add(user_a)
    seeded_db.commit()
    u_a = user_a.id
    s_a = client.post("/api/v1/students", json={"user_id": u_a, "name": "A", "email": "student_a_sec@example.com"}).json()["id"]
    token_a = create_access_token({"sub": u_a})
    headers_a = {"Authorization": f"Bearer {token_a}"}

    # Register and setup Student B
    user_b = User(
        id=str(uuid.uuid4()),
        email="student_b_sec@example.com",
        name="B",
        password=hash_password("UnusableSecret123!"),
        role="STUDENT",
    )
    seeded_db.add(user_b)
    seeded_db.commit()
    u_b = user_b.id
    s_b = client.post("/api/v1/students", json={"user_id": u_b, "name": "B", "email": "student_b_sec@example.com"}).json()["id"]
    token_b = create_access_token({"sub": u_b})
    headers_b = {"Authorization": f"Bearer {token_b}"}

    # Create application for Student B
    sch_id = DEMO_SCHOLARSHIPS[0]["id"]
    app_b_res = client.post(
        "/api/v1/applications",
        headers=headers_b,
        json={"student_id": s_b, "scholarship_id": sch_id},
    )
    assert app_b_res.status_code == 200
    app_b_id = app_b_res.json()["id"]

    return {
        "headers_a": headers_a,
        "student_a_id": s_a,
        "headers_b": headers_b,
        "student_b_id": s_b,
        "app_b_id": app_b_id,
    }


def test_student_a_cannot_view_student_b_application_status(client, two_students_setup):
    """Student A gets 403 when requesting Student B's application status."""
    headers_a = two_students_setup["headers_a"]
    app_b_id = two_students_setup["app_b_id"]

    res = client.get(f"/api/v1/applications/{app_b_id}/status", headers=headers_a)
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_a_cannot_view_student_b_timeline(client, two_students_setup):
    """Student A gets 403 when requesting Student B's timeline."""
    headers_a = two_students_setup["headers_a"]
    app_b_id = two_students_setup["app_b_id"]

    res = client.get(f"/api/v1/applications/{app_b_id}/timeline", headers=headers_a)
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_a_cannot_view_student_b_deficiencies(client, two_students_setup):
    """Student A gets 403 when requesting Student B's deficiencies."""
    headers_a = two_students_setup["headers_a"]
    app_b_id = two_students_setup["app_b_id"]

    res = client.get(f"/api/v1/applications/{app_b_id}/deficiencies", headers=headers_a)
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_a_cannot_view_student_b_payment_status(client, two_students_setup):
    """Student A gets 403 when requesting Student B's payment status."""
    headers_a = two_students_setup["headers_a"]
    app_b_id = two_students_setup["app_b_id"]

    res = client.get(f"/api/v1/applications/{app_b_id}/payment-status", headers=headers_a)
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_a_cannot_view_student_b_payments_alias(client, two_students_setup):
    """Student A gets 403 when requesting Student B's payment via legacy alias."""
    headers_a = two_students_setup["headers_a"]
    app_b_id = two_students_setup["app_b_id"]

    res = client.get(f"/api/v1/applications/{app_b_id}/payments", headers=headers_a)
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_a_cannot_view_student_b_documents(client, two_students_setup):
    """Student A gets 403 when listing documents attached to Student B's application."""
    headers_a = two_students_setup["headers_a"]
    app_b_id = two_students_setup["app_b_id"]

    res = client.get(f"/api/v1/applications/{app_b_id}/documents", headers=headers_a)
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_a_cannot_link_document_to_student_b_application(client, two_students_setup):
    """Student A gets 403 when attempting to link a document to Student B's application."""
    headers_a = two_students_setup["headers_a"]
    app_b_id = two_students_setup["app_b_id"]

    res = client.post(
        f"/api/v1/applications/{app_b_id}/documents",
        headers=headers_a,
        json={"document_id": DEMO_DOCUMENTS[0]["id"]},
    )
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_a_cannot_transition_student_b_application(client, two_students_setup):
    """Student A gets 403 when attempting to transition Student B's application."""
    headers_a = two_students_setup["headers_a"]
    app_b_id = two_students_setup["app_b_id"]

    res = client.post(
        f"/api/v1/applications/{app_b_id}/transition",
        headers=headers_a,
        json={"status": "SUBMITTED"},
    )
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_a_cannot_patch_student_b_application_status(client, two_students_setup):
    """Student A gets 403 when attempting to PATCH Student B's application status."""
    headers_a = two_students_setup["headers_a"]
    app_b_id = two_students_setup["app_b_id"]

    res = client.patch(
        f"/api/v1/applications/{app_b_id}/status",
        headers=headers_a,
        json={"status": "SUBMITTED"},
    )
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_a_cannot_create_application_for_student_b(client, two_students_setup):
    """Student A gets 403 when attempting to create an application with student_id=student_b_id."""
    headers_a = two_students_setup["headers_a"]
    student_b_id = two_students_setup["student_b_id"]

    res = client.post(
        "/api/v1/applications",
        headers=headers_a,
        json={
            "student_id": student_b_id,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    assert res.status_code == 403
    assert "Access denied" in res.json().get("detail", "")


def test_student_accessing_nonexistent_application_returns_404(client, two_students_setup):
    """Accessing an application ID that does not exist returns 404 Not Found."""
    headers_a = two_students_setup["headers_a"]
    fake_id = "00000000-0000-0000-0000-ffffffffffff"

    res = client.get(f"/api/v1/applications/{fake_id}/status", headers=headers_a)
    assert res.status_code == 404
    assert res.json().get("detail") == "Application not found"
