"""Tests for TASK 3+9 — Unreached ST Student Identification & Analytics."""
from app.core.security import create_access_token
from app.seed import DEMO_USER_ID_2


def test_unreached_beneficiaries_endpoint(client, seeded_db, admin_headers):
    """GET /analytics/unreached-beneficiaries returns mock unreached students."""
    response = client.get("/api/v1/analytics/unreached-beneficiaries", headers=admin_headers)
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


def test_unreached_beneficiaries_all_endpoint(client, seeded_db, admin_headers):
    """GET /analytics/unreached-beneficiaries/all returns both matched and unreached."""
    response = client.get("/api/v1/analytics/unreached-beneficiaries/all", headers=admin_headers)
    assert response.status_code == 200
    data = response.json()
    statuses = {r["matched_status"] for r in data["results"]}
    assert "MATCHED" in statuses
    assert "UNREACHED" in statuses
    assert data["summary"]["total_enrolled"] == 5
    assert data["summary"]["total_unreached"] == 3  # 5 enrolled - 2 beneficiaries


def test_analytics_dashboard(client, seeded_db, admin_headers):
    """GET /analytics/dashboard returns ministry-side analytics."""
    response = client.get("/api/v1/analytics/dashboard", headers=admin_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["total_applications"] >= 1
    assert "scheme_wise_applications" in data
    assert "verification_summary" in data
    assert "manual_review_summary" in data
    assert "payment_summary" in data
    assert "unreached_beneficiary_summary" in data
    assert data["data_source"] == "MOCK_PROTOTYPE"


def test_unreached_summary_deterministic(client, seeded_db, admin_headers):
    """Summary counts are deterministic with mock data."""
    response = client.get("/api/v1/analytics/unreached-beneficiaries", headers=admin_headers)
    summary = response.json()["summary"]
    assert summary["total_enrolled"] == 5
    assert summary["total_matched"] == 2
    assert summary["total_unreached"] == 3
    assert summary["unreached_percentage"] == 60.0


def test_student_role_denied_access_to_analytics(client, seeded_db, auth_headers):
    """Authenticated student user must be rejected with 403 on ministry analytics."""
    # Student calls /analytics/dashboard
    dash_res = client.get(
        "/api/v1/analytics/dashboard",
        headers=auth_headers,
    )
    assert dash_res.status_code == 403
    assert "Admin role required" in dash_res.json()["detail"]

    # Student calls /analytics/unreached-beneficiaries
    unreached_res = client.get(
        "/api/v1/analytics/unreached-beneficiaries",
        headers=auth_headers,
    )
    assert unreached_res.status_code == 403


def test_admin_role_granted_access_to_analytics(client, seeded_db, admin_headers):
    """Authenticated Admin user can access ministry analytics."""
    dash_res = client.get(
        "/api/v1/analytics/dashboard",
        headers=admin_headers,
    )
    assert dash_res.status_code == 200
    data = dash_res.json()
    assert "total_applications" in data


def test_outreach_notification_appears_in_student_notifications(client, seeded_db, admin_headers):
    """Outreach dispatched by admin appears in target student's notification feed."""
    # 1. Admin sends outreach to unreached student (ENROL-ST-002 -> Student 2: Rani Marandi)
    outreach_res = client.post(
        "/api/v1/analytics/unreached-beneficiaries/outreach",
        json={
            "demo_id": "ENROL-ST-002",
            "title": "Special ST Scholarship Outreach",
            "message": "You are eligible for Pre-Matric and Post-Matric schemes.",
        },
        headers=admin_headers,
    )
    assert outreach_res.status_code == 201
    outreach_data = outreach_res.json()
    assert outreach_data["title"] == "Special ST Scholarship Outreach"
    assert outreach_data["is_read"] is False

    # 2. Student 2 fetches their notifications: GET /api/v1/notifications/me
    student_token = create_access_token({"sub": DEMO_USER_ID_2})
    notif_res = client.get(
        "/api/v1/notifications/me",
        headers={"Authorization": f"Bearer {student_token}"},
    )
    assert notif_res.status_code == 200
    notifs = notif_res.json()
    titles = [n["title"] for n in notifs]
    assert "Special ST Scholarship Outreach" in titles

