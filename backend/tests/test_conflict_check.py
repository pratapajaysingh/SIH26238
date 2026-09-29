"""Tests for TASK 2 — Unified Eligibility/Conflict Check."""
from app.seed import DEMO_STUDENT_ID, DEMO_SCHOLARSHIPS, DEMO_APPLICATION_ID
from app.models.application import Application


def test_conflict_check_eligible_student(client, seeded_db):
    """Student with no active applications for a different scheme is eligible."""
    # Student2 has no applications at all
    from app.seed import DEMO_STUDENT_ID_2
    response = client.post(
        "/api/v1/eligibility/conflict-check",
        json={
            "student_id": DEMO_STUDENT_ID_2,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["eligible"] is True
    assert data["status"] == "ELIGIBLE"
    assert data["evaluation_mode"] == "MOCK"


def test_conflict_check_duplicate_application(client, seeded_db):
    """Same student, same scheme with active application → DUPLICATE_APPLICATION."""
    response = client.post(
        "/api/v1/eligibility/conflict-check",
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],  # POST_MATRIC — has DRAFT app
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["eligible"] is False
    assert data["status"] == "DUPLICATE_APPLICATION"
    assert data["existing_application_id"] is not None


def test_conflict_check_sanctioned_conflict(client, seeded_db):
    """Student with a SANCTIONED application for another scheme → blocked."""
    # DEMO_APPLICATION_ID_2 is SANCTIONED (PRE_MATRIC)
    # Trying to apply for NFST should be blocked
    response = client.post(
        "/api/v1/eligibility/conflict-check",
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[4]["id"],  # NATIONAL_FELLOWSHIP_ST
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["eligible"] is False
    assert data["status"] in {"SANCTIONED_SCHEME_CONFLICT", "ACTIVE_APPLICATION_EXISTS", "DUPLICATE_APPLICATION", "PENDING_DEFICIENCY"}


def test_conflict_check_terminal_rejected_allows_new(client, db_session, seeded_db):
    """Rejected/withdrawn application does NOT block new applications."""
    from app.seed import DEMO_STUDENT_ID_2
    # Create and reject an application for student2
    app = Application(
        student_id=DEMO_STUDENT_ID_2,
        scholarship_id=DEMO_SCHOLARSHIPS[0]["id"],
        status="REJECTED",
    )
    db_session.add(app)
    db_session.flush()

    response = client.post(
        "/api/v1/eligibility/conflict-check",
        json={
            "student_id": DEMO_STUDENT_ID_2,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["eligible"] is True
    assert data["status"] == "ELIGIBLE"


def test_conflict_check_student_not_found(client, seeded_db):
    response = client.post(
        "/api/v1/eligibility/conflict-check",
        json={
            "student_id": "non-existent-student",
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    assert response.status_code == 404


def test_conflict_check_scholarship_not_found(client, seeded_db):
    response = client.post(
        "/api/v1/eligibility/conflict-check",
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": "non-existent-scholarship",
        },
    )
    assert response.status_code == 404


def test_conflict_check_active_application_blocks_different_scheme(client, db_session, seeded_db):
    """Active (SUBMITTED) application for one scheme blocks application to another."""
    from app.seed import DEMO_STUDENT_ID_2
    # Create SUBMITTED application for student2
    app = Application(
        student_id=DEMO_STUDENT_ID_2,
        scholarship_id=DEMO_SCHOLARSHIPS[0]["id"],
        status="SUBMITTED",
    )
    db_session.add(app)
    db_session.flush()

    response = client.post(
        "/api/v1/eligibility/conflict-check",
        json={
            "student_id": DEMO_STUDENT_ID_2,
            "scholarship_id": DEMO_SCHOLARSHIPS[1]["id"],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["eligible"] is False
    assert data["status"] == "ACTIVE_APPLICATION_EXISTS"
