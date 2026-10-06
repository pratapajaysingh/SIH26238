"""Tests for TASK 4 — Unified Verification Flow with manual review routing."""
from app.seed import DEMO_APPLICATION_ID, DEMO_APPLICATION_ID_3, DEMO_DOCUMENTS
from app.models.document import Document
from app.models.application_document import ApplicationDocument


def test_verification_unavailable_source_routes_to_mismatch(client, seeded_db, admin_headers):
    """TEST_UNAVAILABLE document type simulates source unavailability → MISMATCH → eligible for manual review."""
    unavail_doc_id = DEMO_DOCUMENTS[3]["id"]  # TEST_UNAVAILABLE

    # Link to application first
    client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/documents",
        headers=admin_headers,
        json={"document_id": unavail_doc_id},
    )

    # Create verification record
    create_res = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/verifications",
        headers=admin_headers,
        json={"document_id": unavail_doc_id},
    )
    assert create_res.status_code == 200
    verif_id = create_res.json()["id"]

    # Execute verification
    exec_res = client.post(f"/api/v1/verifications/{verif_id}/execute", headers=admin_headers)
    assert exec_res.status_code == 200
    data = exec_res.json()
    assert data["status"] == "MISMATCH"  # Unavailable routes to MISMATCH for manual review
    assert data["evaluation_mode"] == "MOCK"
    assert "unavailable" in data["message"].lower() or "manual review" in data["message"].lower()


def test_mismatch_triggers_manual_review(client, seeded_db, admin_headers):
    """MISMATCH verification can trigger manual review."""
    mismatch_doc_id = DEMO_DOCUMENTS[2]["id"]  # TEST_MISMATCH — linked to app3

    # Create verification for the mismatch doc on app3
    create_res = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID_3}/verifications",
        headers=admin_headers,
        json={"document_id": mismatch_doc_id},
    )
    assert create_res.status_code == 200
    verif_id = create_res.json()["id"]

    # Execute → should result in MISMATCH
    exec_res = client.post(f"/api/v1/verifications/{verif_id}/execute", headers=admin_headers)
    assert exec_res.status_code == 200
    assert exec_res.json()["status"] == "MISMATCH"

    # Create manual review from MISMATCH verification
    review_res = client.post(f"/api/v1/verifications/{verif_id}/manual-review", headers=admin_headers)
    assert review_res.status_code == 200
    review_data = review_res.json()
    assert review_data["status"] == "OPEN"
    assert review_data["verification_id"] == verif_id


def test_verified_status_no_manual_review(client, seeded_db, admin_headers):
    """VERIFIED verification should NOT be eligible for manual review."""
    # Create verification for TEST_VERIFIED doc
    create_res = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/verifications",
        headers=admin_headers,
        json={"document_id": DEMO_DOCUMENTS[1]["id"]},
    )
    assert create_res.status_code == 200
    verif_id = create_res.json()["id"]

    # Execute → VERIFIED
    exec_res = client.post(f"/api/v1/verifications/{verif_id}/execute", headers=admin_headers)
    assert exec_res.status_code == 200
    assert exec_res.json()["status"] == "VERIFIED"

    # Try manual review → should fail (not MISMATCH)
    review_res = client.post(f"/api/v1/verifications/{verif_id}/manual-review", headers=admin_headers)
    assert review_res.status_code == 409
