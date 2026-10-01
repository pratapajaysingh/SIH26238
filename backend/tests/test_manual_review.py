from app.seed import DEMO_APPLICATION_ID, DEMO_DOCUMENTS


def test_list_manual_reviews_empty_initially(client, seeded_db):
    response = client.get("/api/v1/manual-reviews")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_manual_review_lifecycle(client, seeded_db):
    # Link doc 2 (TEST_MISMATCH) to DEMO_APPLICATION_ID
    doc_id = DEMO_DOCUMENTS[2]["id"]
    client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/documents",
        json={"document_id": doc_id},
    )

    # Create verification record
    v_res = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/verifications",
        json={"document_id": doc_id},
    )
    assert v_res.status_code == 200
    verif_id = v_res.json()["id"]

    # Attempt manual review before execution (status is PENDING, not MISMATCH)
    early_review_res = client.post(f"/api/v1/verifications/{verif_id}/manual-review")
    assert early_review_res.status_code == 409
    assert early_review_res.json()["detail"] == "Verification record is not eligible for manual review"

    # Execute verification -> produces MISMATCH
    exec_res = client.post(f"/api/v1/verifications/{verif_id}/execute")
    assert exec_res.status_code == 200
    assert exec_res.json()["status"] == "MISMATCH"

    # Now enqueue for manual review
    review_res = client.post(f"/api/v1/verifications/{verif_id}/manual-review")
    assert review_res.status_code == 200
    review_data = review_res.json()
    assert review_data["application_id"] == DEMO_APPLICATION_ID
    assert review_data["verification_id"] == verif_id
    assert review_data["status"] == "OPEN"

    # Subsequent attempt to queue again should return 409
    dup_review_res = client.post(f"/api/v1/verifications/{verif_id}/manual-review")
    assert dup_review_res.status_code == 409

    # 1. Verify student cannot access the manual review queue
    student_login = client.post(
        "/api/v1/auth/login",
        json={"email": "demo.student@example.com", "password": "DemoPassword123!"},
    )
    assert student_login.status_code == 200
    st_token = student_login.json()["access_token"]
    st_queue_res = client.get(
        "/api/v1/manual-reviews",
        headers={"Authorization": f"Bearer {st_token}"},
    )
    assert st_queue_res.status_code == 403
    assert "Student accounts cannot access" in st_queue_res.json()["detail"]

    # 2. Verify student cannot decide/resolve manual review
    st_decide_res = client.post(
        f"/api/v1/manual-reviews/{review_data['id']}/decide",
        json={"action": "APPROVE", "remarks": "Trying to bypass as student"},
        headers={"Authorization": f"Bearer {st_token}"},
    )
    assert st_decide_res.status_code == 403

    # 3. Verify Admin can access queue and approve the manual review
    admin_login = client.post(
        "/api/v1/auth/login",
        json={"email": "admin.mota@tribalsetu.gov.in", "password": "AdminSecret123!"},
    )
    assert admin_login.status_code == 200
    admin_token = admin_login.json()["access_token"]

    admin_queue_res = client.get(
        "/api/v1/manual-reviews",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert admin_queue_res.status_code == 200
    reviews = admin_queue_res.json()
    assert any(r["id"] == review_data["id"] for r in reviews)

    # Admin approves
    admin_decide_res = client.post(
        f"/api/v1/manual-reviews/{review_data['id']}/decide",
        json={"action": "APPROVE", "remarks": "Income document verified manually via tehsildar stamp"},
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert admin_decide_res.status_code == 200
    assert admin_decide_res.json()["status"] == "RESOLVED"

