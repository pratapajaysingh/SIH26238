import pytest
from app.seed import DEMO_APPLICATION_ID, DEMO_STUDENT_ID, DEMO_SCHOLARSHIPS, seed_database
from app.services.application_service import add_application_timeline_entry
from app.integrations import (
    MockNSPAdapter,
    MockSFMPAdapter,
    MockNOSAdapter,
    MockAPAARAdapter,
    MockUDISEAdapter,
    MockAISHEAdapter,
    MockUIDAIAdapter,
    MockStateEDistrictAdapter,
    MockUGCNTAAdapter,
)


def test_timeline_seeded_demo_application(client, seeded_db, auth_headers):
    response = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/timeline", headers=auth_headers)
    assert response.status_code == 200
    timeline = response.json()
    assert isinstance(timeline, list)
    assert len(timeline) >= 1
    first_event = timeline[0]
    assert first_event["application_id"] == DEMO_APPLICATION_ID
    assert first_event["status"] == "DRAFT"
    assert "created_at" in first_event
    assert "timestamp" in first_event


def test_timeline_nonexistent_application_returns_404(client, seeded_db, admin_headers):
    response = client.get("/api/v1/applications/non-existent-app-id/timeline", headers=admin_headers)
    assert response.status_code == 404
    assert response.json()["detail"] == "Application not found"


def test_create_application_creates_initial_draft_timeline(client, seeded_db, auth_headers):
    # 1. Create a new application
    create_resp = client.post(
        "/api/v1/applications",
        headers=auth_headers,
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[2]["id"],
        },
    )
    assert create_resp.status_code == 200
    app_id = create_resp.json()["id"]

    # 2. Fetch timeline
    timeline_resp = client.get(f"/api/v1/applications/{app_id}/timeline", headers=auth_headers)
    assert timeline_resp.status_code == 200
    timeline = timeline_resp.json()
    assert len(timeline) == 1
    assert timeline[0]["status"] == "DRAFT"
    assert timeline[0]["application_id"] == app_id
    assert "initialized in DRAFT status" in (timeline[0]["message"] or "")


def test_timeline_ordering_and_append(client, seeded_db, db_session, auth_headers):
    # 1. Create application
    create_resp = client.post(
        "/api/v1/applications",
        headers=auth_headers,
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    app_id = create_resp.json()["id"]

    # 2. Append subsequent events in order
    add_application_timeline_entry(
        db_session,
        app_id,
        status="SUBMITTED",
        message="Application submitted by student",
    )
    add_application_timeline_entry(
        db_session,
        app_id,
        status="IN_VERIFICATION",
        message="Documents enqueued for verification",
    )
    add_application_timeline_entry(
        db_session,
        app_id,
        status="DEFICIENCY",
        message="Deficiency flagged on income certificate",
    )

    # 3. Retrieve timeline via API
    resp = client.get(f"/api/v1/applications/{app_id}/timeline", headers=auth_headers)
    assert resp.status_code == 200
    events = resp.json()
    assert len(events) == 4

    statuses = [e["status"] for e in events]
    assert statuses == ["DRAFT", "SUBMITTED", "IN_VERIFICATION", "DEFICIENCY"]


def test_add_timeline_entry_invalid_status_raises_error(db_session, seeded_db):
    with pytest.raises(ValueError, match="Invalid application status 'INVALID_STATUS'"):
        add_application_timeline_entry(
            db_session,
            DEMO_APPLICATION_ID,
            status="INVALID_STATUS",
            message="This should fail",
        )


def test_add_timeline_entry_nonexistent_application(db_session, seeded_db):
    result = add_application_timeline_entry(
        db_session,
        "non-existent-app-id",
        status="SUBMITTED",
        message="Should return error",
    )
    assert result == "APPLICATION_NOT_FOUND"


def test_seed_idempotence_with_timeline(db_session):
    # First seed
    res1 = seed_database(db_session, reset=False)
    # Second seed should not error or duplicate existing demo records
    res2 = seed_database(db_session, reset=False)
    assert res2["application_timeline"] == 0


def test_payment_compatibility_alias(client, seeded_db, auth_headers):
    # Canonical endpoint
    canonical_resp = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/payment-status", headers=auth_headers)
    assert canonical_resp.status_code == 200

    # Compatibility alias endpoint
    alias_resp = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/payments", headers=auth_headers)
    assert alias_resp.status_code == 200

    assert canonical_resp.json() == alias_resp.json()
    assert canonical_resp.json()["evaluation_mode"] == "MOCK"


def test_government_integration_mock_adapters():
    # 1. NSP
    nsp_res = MockNSPAdapter.check_scheme_status("test-app-id")
    assert nsp_res["portal"] == "NSP"
    assert nsp_res["evaluation_mode"] == "MOCK"

    # 2. SFMP / PFMS
    sfmp_res = MockSFMPAdapter.get_disbursement_status("test-app-id")
    assert sfmp_res["system"] == "SFMP/PFMS"
    assert sfmp_res["evaluation_mode"] == "MOCK"

    # 3. NOS
    nos_res = MockNOSAdapter.verify_candidate_clearance("test-std-id")
    assert nos_res["system"] == "NOS"
    assert nos_res["status"] == "VERIFIED"
    assert nos_res["evaluation_mode"] == "MOCK"

    # 4. APAAR
    apaar_res = MockAPAARAdapter.fetch_academic_record("apaar-123")
    assert apaar_res["system"] == "APAAR"
    assert apaar_res["evaluation_mode"] == "MOCK"

    # 5. UDISE+
    udise_res = MockUDISEAdapter.verify_school("udise-456")
    assert udise_res["system"] == "UDISE+"
    assert udise_res["evaluation_mode"] == "MOCK"

    # 6. AISHE
    aishe_res = MockAISHEAdapter.verify_institution("aishe-789")
    assert aishe_res["system"] == "AISHE"
    assert aishe_res["evaluation_mode"] == "MOCK"

    # 7. UIDAI
    uidai_res = MockUIDAIAdapter.verify_demographics("aadhaar-ref", "Ravi Kumar")
    assert uidai_res["system"] == "UIDAI"
    assert uidai_res["match_score"] == 100
    assert uidai_res["evaluation_mode"] == "MOCK"

    # 8. State e-District
    edist_res = MockStateEDistrictAdapter.verify_certificate("CERT-999", "Odisha")
    assert edist_res["system"] == "STATE_E_DISTRICT"
    assert edist_res["state"] == "Odisha"
    assert edist_res["evaluation_mode"] == "MOCK"

    # 9. UGC / NTA
    nta_res = MockUGCNTAAdapter.verify_exam_score("NTA-2026-01", "UGC-NET")
    assert nta_res["system"] == "UGC_NTA"
    assert nta_res["percentile"] == 96.5
    assert nta_res["evaluation_mode"] == "MOCK"


def test_transition_application_status_valid_flow(client, seeded_db, auth_headers):
    # 1. Create app (starts DRAFT)
    create_resp = client.post(
        "/api/v1/applications",
        headers=auth_headers,
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    assert create_resp.status_code == 200
    app_id = create_resp.json()["id"]

    # 2. DRAFT -> SUBMITTED
    t1 = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "SUBMITTED", "message": "Submitted by applicant"},
    )
    assert t1.status_code == 200
    assert t1.json()["status"] == "SUBMITTED"
    assert t1.json()["previous_status"] == "DRAFT"

    # Check status endpoint
    st1 = client.get(f"/api/v1/applications/{app_id}/status", headers=auth_headers)
    assert st1.json()["status"] == "SUBMITTED"

    # 3. SUBMITTED -> IN_VERIFICATION
    t2 = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "IN_VERIFICATION"},
    )
    assert t2.status_code == 200
    assert t2.json()["status"] == "IN_VERIFICATION"
    assert t2.json()["previous_status"] == "SUBMITTED"

    # 4. IN_VERIFICATION -> DEFICIENCY
    t3 = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "DEFICIENCY", "message": "Document mismatch found"},
    )
    assert t3.status_code == 200
    assert t3.json()["status"] == "DEFICIENCY"

    # 5. DEFICIENCY -> IN_VERIFICATION (re-upload)
    t4 = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "IN_VERIFICATION", "message": "Document re-uploaded"},
    )
    assert t4.status_code == 200
    assert t4.json()["status"] == "IN_VERIFICATION"

    # 6. IN_VERIFICATION -> SANCTIONED
    t5 = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "SANCTIONED", "message": "Scholarship awarded"},
    )
    assert t5.status_code == 200
    assert t5.json()["status"] == "SANCTIONED"

    # 7. SANCTIONED -> COMPLETED
    t6 = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "COMPLETED", "message": "DBT funds disbursed"},
    )
    assert t6.status_code == 200
    assert t6.json()["status"] == "COMPLETED"

    # 8. Verify timeline reflects entire history in order
    tl_resp = client.get(f"/api/v1/applications/{app_id}/timeline", headers=auth_headers)
    assert tl_resp.status_code == 200
    events = tl_resp.json()
    assert len(events) == 7
    expected_order = [
        "DRAFT",
        "SUBMITTED",
        "IN_VERIFICATION",
        "DEFICIENCY",
        "IN_VERIFICATION",
        "SANCTIONED",
        "COMPLETED",
    ]
    assert [e["status"] for e in events] == expected_order


def test_transition_application_status_invalid_transition(client, seeded_db, auth_headers):
    # 1. Create app (starts DRAFT)
    create_resp = client.post(
        "/api/v1/applications",
        headers=auth_headers,
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    app_id = create_resp.json()["id"]

    # 2. Try illegal direct transition DRAFT -> SANCTIONED
    bad1 = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "SANCTIONED"},
    )
    assert bad1.status_code == 400
    assert "Cannot transition application from 'DRAFT' to 'SANCTIONED'" in bad1.json()["detail"]

    # 3. Transition DRAFT -> WITHDRAWN (valid)
    good_withdraw = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "WITHDRAWN"},
    )
    assert good_withdraw.status_code == 200

    # 4. Try transition from terminal WITHDRAWN -> SUBMITTED (invalid)
    bad2 = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "SUBMITTED"},
    )
    assert bad2.status_code == 400
    assert "Cannot transition application from 'WITHDRAWN' to 'SUBMITTED'" in bad2.json()["detail"]


def test_transition_application_status_invalid_status_string(client, seeded_db, auth_headers):
    create_resp = client.post(
        "/api/v1/applications",
        headers=auth_headers,
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    app_id = create_resp.json()["id"]

    resp = client.post(
        f"/api/v1/applications/{app_id}/transition",
        headers=auth_headers,
        json={"status": "UNAPPROVED_STATUS_STRING"},
    )
    assert resp.status_code == 400
    assert "Invalid status 'UNAPPROVED_STATUS_STRING'" in resp.json()["detail"]


def test_transition_application_status_nonexistent_application(client, seeded_db, admin_headers):
    resp = client.post(
        "/api/v1/applications/non-existent-app-id/transition",
        headers=admin_headers,
        json={"status": "SUBMITTED"},
    )
    assert resp.status_code == 404
    assert resp.json()["detail"] == "Application not found"


def test_transition_application_status_patch_alias(client, seeded_db, auth_headers):
    create_resp = client.post(
        "/api/v1/applications",
        headers=auth_headers,
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    app_id = create_resp.json()["id"]

    resp = client.patch(
        f"/api/v1/applications/{app_id}/status",
        headers=auth_headers,
        json={"status": "SUBMITTED", "message": "Via patch alias"},
    )
    assert resp.status_code == 200
    assert resp.json()["status"] == "SUBMITTED"
    assert resp.json()["previous_status"] == "DRAFT"
