"""Tests for TASK 3+9 — Unreached ST Student Identification & Analytics."""


def test_unreached_beneficiaries_endpoint(client):
    """GET /analytics/unreached-beneficiaries returns mock unreached students."""
    response = client.get("/api/v1/analytics/unreached-beneficiaries")
    assert response.status_code == 200
    data = response.json()
    assert "results" in data
    assert "summary" in data
    assert data["data_source"] == "MOCK_PROTOTYPE"
    # There should be unreached students in mock data
    assert len(data["results"]) > 0
    for r in data["results"]:
        assert r["matched_status"] == "UNREACHED"
        assert "demo_id" in r
        assert "institution_code" in r
        assert "possible_reason" in r
        assert "next_action" in r


def test_unreached_beneficiaries_all_endpoint(client):
    """GET /analytics/unreached-beneficiaries/all returns both matched and unreached."""
    response = client.get("/api/v1/analytics/unreached-beneficiaries/all")
    assert response.status_code == 200
    data = response.json()
    statuses = {r["matched_status"] for r in data["results"]}
    assert "MATCHED" in statuses
    assert "UNREACHED" in statuses
    assert data["summary"]["total_enrolled"] == 5
    assert data["summary"]["total_unreached"] == 3  # 5 enrolled - 2 beneficiaries


def test_analytics_dashboard(client, seeded_db):
    """GET /analytics/dashboard returns ministry-side analytics."""
    response = client.get("/api/v1/analytics/dashboard")
    assert response.status_code == 200
    data = response.json()
    assert data["total_applications"] >= 1
    assert "scheme_wise_applications" in data
    assert "verification_summary" in data
    assert "manual_review_summary" in data
    assert "payment_summary" in data
    assert "unreached_beneficiary_summary" in data
    assert data["data_source"] == "MOCK_PROTOTYPE"


def test_unreached_summary_deterministic(client):
    """Summary counts are deterministic with mock data."""
    response = client.get("/api/v1/analytics/unreached-beneficiaries")
    summary = response.json()["summary"]
    assert summary["total_enrolled"] == 5
    assert summary["total_matched"] == 2
    assert summary["total_unreached"] == 3
    assert summary["unreached_percentage"] == 60.0
