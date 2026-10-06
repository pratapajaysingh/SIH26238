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
    import uuid
    from app.core.security import hash_password
    from app.models.user import User
    user_b = User(
        id=str(uuid.uuid4()),
        email="student.b@example.com",
        name="Student B",
        password=hash_password("UnusableSecret123!"),
        role="STUDENT",
    )
    seeded_db.add(user_b)
    seeded_db.commit()
    user_b_id = user_b.id

    # 2. Create auth token for Student B
    token = create_access_token({"sub": user_b_id, "email": "student.b@example.com"})
    headers = {"Authorization": f"Bearer {token}"}

    # 3. Add Student Profile B
    student_res = client.post(
        "/api/v1/students",
        headers=headers,
        json={
            "user_id": user_b_id,
            "name": "Student B",
            "email": "student.b@example.com",
        },
    )
    assert student_res.status_code == 200
    student_b_id = student_res.json()["id"]

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
    assert "Admin role required to create notifications" in response.json()["detail"]


def test_cross_student_notification_read_blocked(client, seeded_db, auth_headers_student_b, admin_headers):
    """Authenticated Student B cannot mark Student A's notification as read."""
    # First create a notification for Student A by Admin
    notif_res = client.post(
        "/api/v1/notifications",
        headers=admin_headers,
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

    # Query param check: /notifications?student_id={student_id} (Admin only)
    res_query = client.get(
        f"/api/v1/notifications?student_id={DEMO_STUDENT_ID}",
        headers=headers,
    )
    assert res_query.status_code == 403
    assert "Admin role required to view global notifications" in res_query.json()["detail"]


def test_cross_user_student_profile_creation_blocked(client, seeded_db, auth_headers_student_b):
    """Authenticated User B already having a profile gets 409 when trying to create another."""
    headers = auth_headers_student_b["headers"]
    response = client.post(
        "/api/v1/students",
        headers=headers,
        json={
            "user_id": DEMO_USER_ID,  # Even with different user_id, user_id is ignored and existing profile triggers 409
            "name": "Hijacked Profile",
            "email": "hijack@example.com",
        },
    )
    assert response.status_code == 409
    assert "Student profile already exists for this user" in response.json()["detail"]


# ---------------------------------------------------------------------------
# Unauthenticated and Role Access Tests for Analytics, Manual Review, and DigiLocker
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("path", [
    "/api/v1/analytics/unreached-beneficiaries",
    "/api/v1/analytics/unreached-beneficiaries/all",
    "/api/v1/analytics/dashboard",
])
def test_unauthenticated_analytics_get_endpoints_return_401(client, seeded_db, path):
    """Unauthenticated call to GET analytics endpoints returns 401."""
    res = client.get(path)
    assert res.status_code == 401


def test_unauthenticated_analytics_outreach_post_returns_401(client, seeded_db):
    """Unauthenticated call to POST /analytics/unreached-beneficiaries/outreach returns 401."""
    res = client.post(
        "/api/v1/analytics/unreached-beneficiaries/outreach",
        json={"demo_id": "ENROL-ST-002"},
    )
    assert res.status_code == 401


def test_unauthenticated_manual_reviews_get_returns_401(client, seeded_db):
    """Unauthenticated call to GET /manual-reviews returns 401."""
    res = client.get("/api/v1/manual-reviews")
    assert res.status_code == 401


def test_unauthenticated_manual_reviews_decide_post_returns_401(client, seeded_db):
    """Unauthenticated call to POST /manual-reviews/{id}/decide returns 401."""
    res = client.post(
        "/api/v1/manual-reviews/non-existent-review-id/decide",
        json={"action": "APPROVE", "remarks": "Test"},
    )
    assert res.status_code == 401


@pytest.mark.parametrize("path", [
    "/api/v1/analytics/unreached-beneficiaries",
    "/api/v1/analytics/unreached-beneficiaries/all",
    "/api/v1/analytics/dashboard",
])
def test_student_role_denied_on_analytics_get_endpoints(client, seeded_db, auth_headers, path):
    """Authenticated student user receives 403 on GET analytics endpoints."""
    res = client.get(path, headers=auth_headers)
    assert res.status_code == 403
    assert "Admin role required" in res.json().get("detail", "")


def test_student_role_denied_on_analytics_outreach_post(client, seeded_db, auth_headers):
    """Authenticated student user receives 403 on POST analytics outreach endpoint."""
    res = client.post(
        "/api/v1/analytics/unreached-beneficiaries/outreach",
        headers=auth_headers,
        json={"demo_id": "ENROL-ST-002"},
    )
    assert res.status_code == 403
    assert "Admin role required" in res.json().get("detail", "")


def test_student_role_denied_on_manual_reviews_get(client, seeded_db, auth_headers):
    """Authenticated student user receives 403 on GET /manual-reviews."""
    res = client.get("/api/v1/manual-reviews", headers=auth_headers)
    assert res.status_code == 403
    assert "Student accounts cannot access" in res.json().get("detail", "")


def test_student_role_denied_on_manual_reviews_decide_post(client, seeded_db, auth_headers):
    """Authenticated student user receives 403 on POST /manual-reviews/{id}/decide."""
    res = client.post(
        "/api/v1/manual-reviews/non-existent-review-id/decide",
        headers=auth_headers,
        json={"action": "APPROVE", "remarks": "Malicious attempt"},
    )
    assert res.status_code == 403
    assert "Student accounts cannot resolve" in res.json().get("detail", "")


def test_unauthenticated_digilocker_documents_returns_401(client, seeded_db):
    """Unauthenticated call to GET /students/{id}/digilocker/documents returns 401."""
    res = client.get(f"/api/v1/students/{DEMO_STUDENT_ID}/digilocker/documents")
    assert res.status_code == 401


def test_cross_student_digilocker_documents_returns_403(client, seeded_db, auth_headers_student_b):
    """Another student requesting student A's digilocker documents returns 403."""
    headers_b = auth_headers_student_b["headers"]
    res = client.get(
        f"/api/v1/students/{DEMO_STUDENT_ID}/digilocker/documents",
        headers=headers_b,
    )
    assert res.status_code == 403
    assert "Cannot access another student's DigiLocker assets" in res.json().get("detail", "")


def test_admin_can_access_student_digilocker_documents(client, seeded_db, admin_headers):
    """Admin user CAN access any student's digilocker documents (returns 200)."""
    res = client.get(
        f"/api/v1/students/{DEMO_STUDENT_ID}/digilocker/documents",
        headers=admin_headers,
    )
    assert res.status_code == 200
    assert isinstance(res.json(), list)


# ---------------------------------------------------------------------------
# Strict Security Lockdown Tests: Endpoint Role Verification
# ---------------------------------------------------------------------------

def test_unauthenticated_get_students_returns_401_student_gets_403(client, seeded_db, auth_headers):
    """Unauthenticated GET /students returns 401, STUDENT gets 403."""
    res_unauth = client.get("/api/v1/students")
    assert res_unauth.status_code == 401

    res_student = client.get("/api/v1/students", headers=auth_headers)
    assert res_student.status_code == 403
    assert "Admin role required" in res_student.json().get("detail", "")


def test_unauthenticated_post_notifications_returns_401_student_gets_403(client, seeded_db, auth_headers):
    """Unauthenticated POST /notifications returns 401, STUDENT gets 403."""
    payload = {
        "student_id": DEMO_STUDENT_ID,
        "title": "Alert",
        "message": "Notice",
        "type": "SYSTEM",
    }
    res_unauth = client.post("/api/v1/notifications", json=payload)
    assert res_unauth.status_code == 401

    res_student = client.post("/api/v1/notifications", headers=auth_headers, json=payload)
    assert res_student.status_code == 403
    assert "Admin role required" in res_student.json().get("detail", "")


def test_student_a_cannot_read_or_mark_read_student_b_notifications(
    client, seeded_db, auth_headers, auth_headers_student_b, admin_headers
):
    """Student A cannot read or mark-read student B's notifications (403)."""
    student_b_id = auth_headers_student_b["student_id"]
    # Admin creates a notification for student B
    create_res = client.post(
        "/api/v1/notifications",
        headers=admin_headers,
        json={
            "student_id": student_b_id,
            "title": "Private for B",
            "message": "Secret message for B",
            "type": "APPLICATION_UPDATE",
        },
    )
    assert create_res.status_code == 201
    notif_b_id = create_res.json()["id"]

    # Student A attempts to read student B's notifications
    read_res = client.get(
        f"/api/v1/students/{student_b_id}/notifications",
        headers=auth_headers,
    )
    assert read_res.status_code == 403
    assert "Cannot access another student's notifications" in read_res.json().get("detail", "")

    # Student A attempts to mark read student B's notification
    mark_res = client.patch(
        f"/api/v1/notifications/{notif_b_id}/read",
        headers=auth_headers,
    )
    assert mark_res.status_code == 403
    assert "Cannot modify another student's notification" in mark_res.json().get("detail", "")


def test_student_a_cannot_list_verifications_on_student_b_application(
    client, seeded_db, auth_headers, auth_headers_student_b
):
    """Student A cannot list verifications on student B's application (403)."""
    app_b_id = auth_headers_student_b["application_id"]
    res = client.get(
        f"/api/v1/applications/{app_b_id}/verifications",
        headers=auth_headers,
    )
    assert res.status_code == 403
    assert "Cannot view verifications on another student's application" in res.json().get("detail", "")


def test_add_student_api_ignores_user_id_in_payload(client, seeded_db):
    """add_student_api ignores a user_id in the payload and sets current_user.id."""
    import uuid
    from app.models.user import User

    # Create fresh User C
    user_c = User(
        id=str(uuid.uuid4()),
        email="student_c_isolation@example.com",
        name="Student C",
        password="secret_password",
        role="STUDENT",
    )
    seeded_db.add(user_c)
    seeded_db.commit()

    token_c = create_access_token({"sub": user_c.id, "email": user_c.email})
    headers_c = {"Authorization": f"Bearer {token_c}"}

    # Attempt to pass an arbitrary forged user_id in payload
    forged_user_id = str(uuid.uuid4())
    res = client.post(
        "/api/v1/students",
        headers=headers_c,
        json={
            "user_id": forged_user_id,
            "name": "Student C Real",
            "email": "student_c_isolation@example.com",
        },
    )
    assert res.status_code == 200
    data = res.json()
    assert data["user_id"] == user_c.id
    assert data["user_id"] != forged_user_id


def test_second_add_student_api_for_same_user_returns_409(client, seeded_db):
    """Second add_student_api for same user returns 409."""
    import uuid
    from app.models.user import User

    # Create fresh User D
    user_d = User(
        id=str(uuid.uuid4()),
        email="student_d_dup@example.com",
        name="Student D",
        password="secret_password",
        role="STUDENT",
    )
    seeded_db.add(user_d)
    seeded_db.commit()

    token_d = create_access_token({"sub": user_d.id, "email": user_d.email})
    headers_d = {"Authorization": f"Bearer {token_d}"}

    # First student profile creation
    res1 = client.post(
        "/api/v1/students",
        headers=headers_d,
        json={
            "name": "Student D",
            "email": "student_d_dup@example.com",
        },
    )
    assert res1.status_code == 200

    # Second student profile creation for the same authenticated user
    res2 = client.post(
        "/api/v1/students",
        headers=headers_d,
        json={
            "name": "Student D Duplicate",
            "email": "student_d_dup@example.com",
        },
    )
    assert res2.status_code == 409
    assert "Student profile already exists for this user" in res2.json().get("detail", "")

