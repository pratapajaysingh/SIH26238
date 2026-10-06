import pytest
from app.core.security import hash_password
from app.models.user import User
from app.seed import DEMO_APPLICATION_ID, DEMO_DOCUMENTS




def test_list_manual_reviews_empty_initially(client, seeded_db, admin_headers):
    response = client.get("/api/v1/manual-reviews", headers=admin_headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_manual_review_lifecycle(client, seeded_db, auth_headers, admin_headers):
    # Link doc 2 (TEST_MISMATCH) to DEMO_APPLICATION_ID
    doc_id = DEMO_DOCUMENTS[2]["id"]
    client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/documents",
        headers=auth_headers,
        json={"document_id": doc_id},
    )

    # Create verification record
    v_res = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/verifications",
        headers=auth_headers,
        json={"document_id": doc_id},
    )
    assert v_res.status_code == 200
    verif_id = v_res.json()["id"]

    # Attempt manual review before execution (status is PENDING, not MISMATCH)
    early_review_res = client.post(f"/api/v1/verifications/{verif_id}/manual-review", headers=auth_headers)
    assert early_review_res.status_code == 409
    assert early_review_res.json()["detail"] == "Verification record is not eligible for manual review"

    # Execute verification -> produces MISMATCH
    exec_res = client.post(f"/api/v1/verifications/{verif_id}/execute", headers=auth_headers)
    assert exec_res.status_code == 200
    assert exec_res.json()["status"] == "MISMATCH"

    # Now enqueue for manual review
    review_res = client.post(f"/api/v1/verifications/{verif_id}/manual-review", headers=auth_headers)
    assert review_res.status_code == 200
    review_data = review_res.json()
    assert review_data["application_id"] == DEMO_APPLICATION_ID
    assert review_data["verification_id"] == verif_id
    assert review_data["status"] == "OPEN"

    # Subsequent attempt to queue again should return 409
    dup_review_res = client.post(f"/api/v1/verifications/{verif_id}/manual-review", headers=auth_headers)
    assert dup_review_res.status_code == 409

    # 1. Verify student cannot access the manual review queue
    st_queue_res = client.get(
        "/api/v1/manual-reviews",
        headers=auth_headers,
    )
    assert st_queue_res.status_code == 403
    assert "Student accounts cannot access" in st_queue_res.json()["detail"]

    # 2. Verify student cannot decide/resolve manual review
    st_decide_res = client.post(
        f"/api/v1/manual-reviews/{review_data['id']}/decide",
        json={"action": "APPROVE", "remarks": "Trying to bypass as student"},
        headers=auth_headers,
    )
    assert st_decide_res.status_code == 403

    # 3. Verify Admin can access queue and approve the manual review
    admin_queue_res = client.get(
        "/api/v1/manual-reviews",
        headers=admin_headers,
    )
    assert admin_queue_res.status_code == 200
    reviews = admin_queue_res.json()
    assert any(r["id"] == review_data["id"] for r in reviews)

    # Admin approves
    admin_decide_res = client.post(
        f"/api/v1/manual-reviews/{review_data['id']}/decide",
        json={"action": "APPROVE", "remarks": "Income document verified manually via tehsildar stamp"},
        headers=admin_headers,
    )
    assert admin_decide_res.status_code == 200
    assert admin_decide_res.json()["status"] == "RESOLVED"

