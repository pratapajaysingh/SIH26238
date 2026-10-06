import uuid
import pytest
from app.core.security import hash_password
from app.models.user import User


def test_user_creation_and_db_fixture(client, db_session):
    user = User(
        id=str(uuid.uuid4()),
        name="Test Applicant",
        email="applicant.test@example.com",
        password=hash_password("UnusableSecret123!"),
        role="STUDENT",
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)

    assert user.id is not None
    assert user.email == "applicant.test@example.com"
    assert user.role == "STUDENT"


def test_student_creation_and_listing(client, db_session):
    # Create user first via DB fixture
    user = User(
        id=str(uuid.uuid4()),
        name="Student User",
        email="student.profile@example.com",
        password=hash_password("UnusableSecret123!"),
        role="STUDENT",
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    user_id = user.id

    # Create student profile
    student_res = client.post(
        "/api/v1/students",
        json={
            "user_id": user_id,
            "name": "Student Profile",
            "email": "student.profile@example.com",
        },
    )
    assert student_res.status_code == 200
    student_data = student_res.json()
    assert student_data["user_id"] == user_id

    # List students
    list_res = client.get("/api/v1/students")
    assert list_res.status_code == 200
    assert len(list_res.json()) >= 1
