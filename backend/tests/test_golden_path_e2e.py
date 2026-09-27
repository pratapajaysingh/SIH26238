"""End-to-end integration and golden-path tests for TribalSetu backend."""

import pytest
from app.seed import DEMO_SCHOLARSHIPS


def test_golden_path_complete_journey(client, seeded_db):

    """Verify the complete user journey end-to-end:
    Register -> Login -> Profile -> Scholarships -> Eligibility -> Application -> 
    Document Link -> Verification -> Status -> Deficiencies -> Payment -> Notifications -> JAGO.
    """
    # 1. Register User
    reg_res = client.post(
        "/api/v1/users",
        json={
            "name": "E2E Tribal Student",
            "email": "e2e.student@example.com",
            "password": "E2EPassword123!",
        },
    )
    assert reg_res.status_code == 200
    user_id = reg_res.json()["id"]
    assert "password" not in reg_res.json()

    # 2. Login to get JWT Bearer token
    login_res = client.post(
        "/api/v1/auth/login",
        json={
            "email": "e2e.student@example.com",
            "password": "E2EPassword123!",
        },
    )
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    assert login_res.json()["token_type"] == "bearer"
    auth_headers = {"Authorization": f"Bearer {token}"}

    # 3. Verify user profile via /users/me
    user_me = client.get("/api/v1/users/me", headers=auth_headers)
    assert user_me.status_code == 200
    assert user_me.json()["id"] == user_id
    assert user_me.json()["email"] == "e2e.student@example.com"

    # 4. Create student profile
    student_res = client.post(
        "/api/v1/students",
        json={
            "user_id": user_id,
            "name": "E2E Tribal Student",
            "email": "e2e.student@example.com",
        },
    )
    assert student_res.status_code == 200
    student_id = student_res.json()["id"]

    # 5. Verify student profile via /students/me
    student_me = client.get("/api/v1/students/me", headers=auth_headers)
    assert student_me.status_code == 200
    assert student_me.json()["id"] == student_id
    assert student_me.json()["user_id"] == user_id

    # 6. Browse scholarships catalogue
    sch_res = client.get("/api/v1/scholarships")
    assert sch_res.status_code == 200
    schemes = sch_res.json()
    assert len(schemes) >= 1
    target_sch_id = schemes[0]["id"]

    # 7. Check eligibility for scheme
    elig_res = client.post(
        "/api/v1/eligibility/check",
        json={
            "student_id": student_id,
            "scholarship_id": target_sch_id,
        },
    )
    assert elig_res.status_code == 200
    assert elig_res.json()["eligible"] is True

    # 8. Create Application
    app_res = client.post(
        "/api/v1/applications",
        json={
            "student_id": student_id,
            "scholarship_id": target_sch_id,
        },
    )
    assert app_res.status_code == 200
    app_id = app_res.json()["id"]
    assert app_res.json()["status"] == "DRAFT"

    # 9. Verify application retrieval via /applications/me
    my_apps = client.get("/api/v1/applications/me", headers=auth_headers)
    assert my_apps.status_code == 200
    assert len(my_apps.json()) == 1
    assert my_apps.json()[0]["id"] == app_id

    # 10. Register Document
    doc_res = client.post(
        "/api/v1/documents",
        json={
            "student_id": student_id,
            "document_type": "TEST_VERIFIED",
            "document_name": "Official 10th Certificate",
        },
    )
    assert doc_res.status_code == 200
    doc_id = doc_res.json()["id"]

    # 11. Link document to application
    link_res = client.post(
        f"/api/v1/applications/{app_id}/documents",
        json={"document_id": doc_id},
    )
    assert link_res.status_code == 200
    assert link_res.json()["application_id"] == app_id
    assert link_res.json()["document_id"] == doc_id

    # 12. Create verification record
    verif_res = client.post(
        f"/api/v1/applications/{app_id}/verifications",
        json={"document_id": doc_id},
    )
    assert verif_res.status_code == 200
    verif_id = verif_res.json()["id"]
    assert verif_res.json()["status"] == "PENDING"

    # 13. Execute verification
    exec_res = client.post(f"/api/v1/verifications/{verif_id}/execute")
    assert exec_res.status_code == 200
    assert exec_res.json()["status"] == "VERIFIED"

    # 14. Query Application Status
    status_res = client.get(f"/api/v1/applications/{app_id}/status")
    assert status_res.status_code == 200
    assert status_res.json()["id"] == app_id
    assert status_res.json()["status"] == "DRAFT"

    # 15. Query Application Deficiencies (should be 0 since document verified)
    defic_res = client.get(f"/api/v1/applications/{app_id}/deficiencies")
    assert defic_res.status_code == 200
    assert len(defic_res.json()) == 0

    # 16. Query Payment / DBT Status
    pay_res = client.get(f"/api/v1/applications/{app_id}/payment-status")
    assert pay_res.status_code == 200
    assert pay_res.json()["application_id"] == app_id
    assert "status" in pay_res.json()
    assert pay_res.json()["disbursement_mode"] == "MOCK_DBT"


    # 17. Create Notification and retrieve via /notifications/me
    notif_create = client.post(
        "/api/v1/notifications",
        json={
            "student_id": student_id,
            "application_id": app_id,
            "title": "Welcome to TribalSetu",
            "message": "Your application has been received.",
            "category": "APPLICATION_UPDATE",
        },
    )
    assert notif_create.status_code == 201
    notif_id = notif_create.json()["id"]

    my_notifs = client.get("/api/v1/notifications/me", headers=auth_headers)
    assert my_notifs.status_code == 200
    assert len(my_notifs.json()) == 1
    assert my_notifs.json()[0]["id"] == notif_id

    # 18. JAGO Assistant: Query status without providing application ID
    jago_res = client.post(
        "/api/v1/jago/conversations/conv-e2e-1/messages",
        headers=auth_headers,
        json={"message": "Check my application status"},
    )
    assert jago_res.status_code == 200
    jago_data = jago_res.json()
    assert jago_data["intent"] == "APPLICATION_STATUS"
    assert app_id in jago_data["message"]
    assert jago_data["data"]["id"] == app_id


def test_mismatch_verification_leads_to_deficiency_and_manual_review(client, seeded_db):
    """Verify document mismatch workflow:
    Upload TEST_MISMATCH -> Verify -> Status becomes MISMATCH -> Deficiencies endpoint flags it ->
    Enqueue for Manual Review -> Review is queued as OPEN.
    """
    # 1. Setup Student and Application
    u_res = client.post(
        "/api/v1/users",
        json={"name": "Review Applicant", "email": "review.app@example.com", "password": "Password123!"},
    )
    user_id = u_res.json()["id"]

    s_res = client.post(
        "/api/v1/students",
        json={"user_id": user_id, "name": "Review Applicant", "email": "review.app@example.com"},
    )
    student_id = s_res.json()["id"]

    sch_res = client.get("/api/v1/scholarships")
    scholarship_id = sch_res.json()[0]["id"]

    app_res = client.post(
        "/api/v1/applications",
        json={"student_id": student_id, "scholarship_id": scholarship_id},
    )
    app_id = app_res.json()["id"]

    # 2. Upload TEST_MISMATCH document
    doc_res = client.post(
        "/api/v1/documents",
        json={
            "student_id": student_id,
            "document_type": "TEST_MISMATCH",
            "document_name": "Discrepant Income Certificate",
        },
    )
    doc_id = doc_res.json()["id"]

    # 3. Link and verify
    client.post(f"/api/v1/applications/{app_id}/documents", json={"document_id": doc_id})
    verif_res = client.post(f"/api/v1/applications/{app_id}/verifications", json={"document_id": doc_id})
    verif_id = verif_res.json()["id"]

    exec_res = client.post(f"/api/v1/verifications/{verif_id}/execute")
    assert exec_res.status_code == 200
    assert exec_res.json()["status"] == "MISMATCH"

    # 4. Deficiencies endpoint detects mismatch
    defic_res = client.get(f"/api/v1/applications/{app_id}/deficiencies")
    assert defic_res.status_code == 200
    deficiencies = defic_res.json()
    assert len(deficiencies) >= 1
    assert any(d["status"] == "MISMATCH" for d in deficiencies)

    # 5. Enqueue for Manual Review
    mr_res = client.post(f"/api/v1/verifications/{verif_id}/manual-review")
    assert mr_res.status_code == 200
    assert mr_res.json()["status"] == "OPEN"
    assert mr_res.json()["verification_id"] == verif_id

    # 6. List manual reviews
    queue_res = client.get("/api/v1/manual-reviews")
    assert queue_res.status_code == 200
    assert any(r["verification_id"] == verif_id for r in queue_res.json())


def test_jago_unknown_and_invalid_application_handling(client, seeded_db):
    """Verify JAGO handles unknown inquiries and non-existent application queries gracefully."""
    # Unknown intent fallback
    unk_res = client.post(
        "/api/v1/jago/conversations/conv-unk-1/messages",
        json={"message": "What is the weather outside today?"},
    )
    assert unk_res.status_code == 200
    unk_data = unk_res.json()
    assert unk_data["intent"] == "UNKNOWN"
    assert len(unk_data["suggestions"]) >= 3

    # Status check with non-existent application UUID
    missing_uuid = "11111111-2222-3333-4444-555555555555"
    bad_app_res = client.post(
        "/api/v1/jago/conversations/conv-unk-2/messages",
        json={"message": f"Check status of application {missing_uuid}"},
    )
    assert bad_app_res.status_code == 200
    bad_app_data = bad_app_res.json()
    assert bad_app_data["intent"] == "APPLICATION_STATUS"
    assert "No application found" in bad_app_data["message"]
    assert bad_app_data["data"]["found"] is False


def test_data_isolation_between_authenticated_students(client, seeded_db):

    """Verify strict data ownership: Student A cannot view Student B's data."""
    # Student A
    ua_res = client.post("/api/v1/users", json={"name": "Student A", "email": "a@example.com", "password": "PasswordA1!"})
    user_a_id = ua_res.json()["id"]
    sa_res = client.post("/api/v1/students", json={"user_id": user_a_id, "name": "Student A", "email": "a@example.com"})
    student_a_id = sa_res.json()["id"]
    token_a = client.post("/api/v1/auth/login", json={"email": "a@example.com", "password": "PasswordA1!"}).json()["access_token"]
    headers_a = {"Authorization": f"Bearer {token_a}"}

    # Student B
    ub_res = client.post("/api/v1/users", json={"name": "Student B", "email": "b@example.com", "password": "PasswordB1!"})
    user_b_id = ub_res.json()["id"]
    sb_res = client.post("/api/v1/students", json={"user_id": user_b_id, "name": "Student B", "email": "b@example.com"})
    student_b_id = sb_res.json()["id"]
    token_b = client.post("/api/v1/auth/login", json={"email": "b@example.com", "password": "PasswordB1!"}).json()["access_token"]
    headers_b = {"Authorization": f"Bearer {token_b}"}

    # Create scholarship application for Student A and Student B
    sch_id = client.get("/api/v1/scholarships").json()[0]["id"]
    app_a = client.post("/api/v1/applications", json={"student_id": student_a_id, "scholarship_id": sch_id}).json()["id"]
    app_b = client.post("/api/v1/applications", json={"student_id": student_b_id, "scholarship_id": sch_id}).json()["id"]

    # Student A's /applications/me only sees app_a
    res_a = client.get("/api/v1/applications/me", headers=headers_a)
    assert res_a.status_code == 200
    app_ids_a = [a["id"] for a in res_a.json()]
    assert app_a in app_ids_a
    assert app_b not in app_ids_a

    # Student B's /applications/me only sees app_b
    res_b = client.get("/api/v1/applications/me", headers=headers_b)
    assert res_b.status_code == 200
    app_ids_b = [b["id"] for b in res_b.json()]
    assert app_b in app_ids_b
    assert app_a not in app_ids_b

    # JAGO context resolution: Student A's query resolves app_a, never app_b
    jago_a = client.post(
        "/api/v1/jago/conversations/conv-iso-1/messages",
        headers=headers_a,
        json={"message": "Check my application status"},
    )
    assert jago_a.json()["data"]["id"] == app_a

    jago_b = client.post(
        "/api/v1/jago/conversations/conv-iso-2/messages",
        headers=headers_b,
        json={"message": "Check my application status"},
    )
    assert jago_b.json()["data"]["id"] == app_b
