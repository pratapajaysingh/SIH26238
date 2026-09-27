import pytest
from app.core.security import create_access_token
from app.seed import (
    DEMO_APPLICATION_ID,
    DEMO_DOCUMENTS,
    DEMO_SCHOLARSHIPS,
    DEMO_STUDENT_ID,
    DEMO_USER_ID,
    DEMO_VERIFICATION_ID,
)


@pytest.fixture
def auth_headers_student_b(client, seeded_db):
    """Create a second student (Student B) and return authorization headers along with IDs."""
    # 1. Register User B
    reg_res = client.post(
        "/api/v1/users",
        json={
            "name": "Student B",
            "email": "student.b@example.com",
            "password": "PasswordB123!",
        },
    )
    assert reg_res.status_code == 200
    user_b_id = reg_res.json()["id"]

    # 2. Add Student Profile B
    student_res = client.post(
        "/api/v1/students",
        json={
            "user_id": user_b_id,
            "name": "Student B",
            "email": "student.b@example.com",
        },
    )
    assert student_res.status_code == 200
    student_b_id = student_res.json()["id"]

    # 3. Create auth token for Student B
    token = create_access_token({"sub": user_b_id, "email": "student.b@example.com"})
    headers = {"Authorization": f"Bearer {token}"}

    # 4. Create an application owned by Student B
    app_res = client.post(
        "/api/v1/applications",
        headers=headers,
        json={
            "student_id": student_b_id,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    assert app_res.status_code == 200
    app_b_id = app_res.json()["id"]

    return {
        "headers": headers,
        "user_id": user_b_id,
        "student_id": student_b_id,
        "application_id": app_b_id,
    }


def test_cross_student_application_transition_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot transition Demo Student A's application."""
    headers = auth_headers_student_b["headers"]
    response = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/transition",
        headers=headers,
        json={"status": "UNDER_REVIEW", "message": "Malicious transition attempt"},
    )
    assert response.status_code == 403
    assert "Cannot transition another student's application" in response.json()["detail"]


def test_cross_student_application_status_patch_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot PATCH status on Demo Student A's application."""
    headers = auth_headers_student_b["headers"]
    response = client.patch(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/status",
        headers=headers,
        json={"status": "UNDER_REVIEW", "message": "Malicious patch attempt"},
    )
    assert response.status_code == 403
    assert "Cannot transition another student's application" in response.json()["detail"]


def test_own_student_application_transition_allowed(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B CAN transition their own application."""
    headers = auth_headers_student_b["headers"]
    app_b_id = auth_headers_student_b["application_id"]
    response = client.post(
        f"/api/v1/applications/{app_b_id}/transition",
        headers=headers,
        json={"status": "SUBMITTED", "message": "Submitted by student"},
    )
    assert response.status_code == 200
    assert response.json()["status"] == "SUBMITTED"


def test_cross_student_application_creation_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot create an application under Student A's student_id."""
    headers = auth_headers_student_b["headers"]
    response = client.post(
        "/api/v1/applications",
        headers=headers,
        json={
            "student_id": DEMO_STUDENT_ID,  # Belongs to Student A
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    assert response.status_code == 403
    assert "Cannot create application for another student" in response.json()["detail"]


def test_cross_student_link_document_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot link documents to Student A's application."""
    headers = auth_headers_student_b["headers"]
    doc_a_id = DEMO_DOCUMENTS[0]["id"]
    response = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/documents",
        headers=headers,
        json={"document_id": doc_a_id},
    )
    assert response.status_code == 403
    assert "Cannot modify another student's application" in response.json()["detail"]


def test_cross_student_document_upload_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot upload a document under Student A's student_id."""
    headers = auth_headers_student_b["headers"]
    response = client.post(
        "/api/v1/documents",
        headers=headers,
        json={
            "student_id": DEMO_STUDENT_ID,
            "document_type": "INCOME_CERTIFICATE",
            "document_name": "Income Certificate",
        },
    )
    assert response.status_code == 403
    assert "Cannot upload documents for another student" in response.json()["detail"]


def test_own_student_document_upload_allowed(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B CAN upload a document under their own student_id."""
    headers = auth_headers_student_b["headers"]
    student_b_id = auth_headers_student_b["student_id"]
    response = client.post(
        "/api/v1/documents",
        headers=headers,
        json={
            "student_id": student_b_id,
            "document_type": "CASTE_CERTIFICATE",
            "document_name": "Caste Certificate",
        },
    )
    assert response.status_code == 200
    assert response.json()["student_id"] == student_b_id


def test_cross_student_digilocker_list_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot list Student A's DigiLocker documents."""
    headers = auth_headers_student_b["headers"]
    response = client.get(
        f"/api/v1/students/{DEMO_STUDENT_ID}/digilocker/documents",
        headers=headers,
    )
    assert response.status_code == 403
    assert "Cannot access another student's DigiLocker assets" in response.json()["detail"]


def test_cross_student_digilocker_import_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot import Student A's DigiLocker document."""
    headers = auth_headers_student_b["headers"]
    response = client.post(
        f"/api/v1/students/{DEMO_STUDENT_ID}/digilocker/documents/import",
        headers=headers,
        json={"document_type": "AADHAAR"},
    )
    assert response.status_code == 403
    assert "Cannot access another student's DigiLocker assets" in response.json()["detail"]


def test_cross_student_verification_create_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot create verification on Student A's application."""
    headers = auth_headers_student_b["headers"]
    doc_a_id = DEMO_DOCUMENTS[0]["id"]
    response = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/verifications",
        headers=headers,
        json={"document_id": doc_a_id},
    )
    assert response.status_code == 403
    assert "Cannot create verifications on another student's application" in response.json()["detail"]


def test_cross_student_verification_execute_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot execute verification on Student A's verification record."""
    headers = auth_headers_student_b["headers"]
    response = client.post(
        f"/api/v1/verifications/{DEMO_VERIFICATION_ID}/execute",
        headers=headers,
    )
    assert response.status_code == 403
    assert "Cannot execute verification on another student's application" in response.json()["detail"]


def test_cross_student_manual_review_enqueue_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot enqueue manual review on Student A's verification record."""
    headers = auth_headers_student_b["headers"]
    response = client.post(
        f"/api/v1/verifications/{DEMO_VERIFICATION_ID}/manual-review",
        headers=headers,
    )
    assert response.status_code == 403
    assert "Cannot enqueue manual review for another student's application" in response.json()["detail"]


def test_cross_student_notification_creation_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot create notification targeting Student A."""
    headers = auth_headers_student_b["headers"]
    response = client.post(
        "/api/v1/notifications",
        headers=headers,
        json={
            "student_id": DEMO_STUDENT_ID,
            "title": "Phishing notification",
            "message": "Click here to claim money",
            "type": "SYSTEM",
        },
    )
    assert response.status_code == 403
    assert "Students cannot send notifications to other students" in response.json()["detail"]


def test_cross_student_notification_read_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot mark Student A's notification as read."""
    # First create a notification for Student A (unauthenticated/system)
    notif_res = client.post(
        "/api/v1/notifications",
        json={
            "student_id": DEMO_STUDENT_ID,
            "title": "A Notification",
            "message": "Message for A",
            "type": "APPLICATION_UPDATE",
        },
    )
    assert notif_res.status_code == 201
    notif_id = notif_res.json()["id"]

    # Student B attempts to mark Student A's notification as read
    headers = auth_headers_student_b["headers"]
    response = client.patch(
        f"/api/v1/notifications/{notif_id}/read",
        headers=headers,
    )
    assert response.status_code == 403
    assert "Cannot modify another student's notification" in response.json()["detail"]


def test_cross_student_notification_get_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated Student B cannot read Student A's notifications via path or query."""
    headers = auth_headers_student_b["headers"]

    # Path check: /students/{student_id}/notifications
    res_path = client.get(
        f"/api/v1/students/{DEMO_STUDENT_ID}/notifications",
        headers=headers,
    )
    assert res_path.status_code == 403
    assert "Cannot access another student's notifications" in res_path.json()["detail"]

    # Query param check: /notifications?student_id={student_id}
    res_query = client.get(
        f"/api/v1/notifications?student_id={DEMO_STUDENT_ID}",
        headers=headers,
    )
    assert res_query.status_code == 403
    assert "Cannot access another student's notifications" in res_query.json()["detail"]


def test_cross_user_student_profile_creation_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated User B cannot create a student profile for User A."""
    headers = auth_headers_student_b["headers"]
    response = client.post(
        "/api/v1/students",
        headers=headers,
        json={
            "user_id": DEMO_USER_ID,  # Belongs to User A
            "name": "Hijacked Profile",
            "email": "hijack@example.com",
        },
    )
    assert response.status_code == 403
    assert "Cannot create student profile for another user" in response.json()["detail"]
