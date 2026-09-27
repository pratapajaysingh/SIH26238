from app.seed import DEMO_STUDENT_ID, DEMO_APPLICATION_ID
from app.schemas.notification import NotificationCreate
from app.services.notification_service import (
    create_notification as service_create_notification,
    list_notifications as service_list_notifications,
    mark_as_read as service_mark_as_read,
)


def test_list_notifications_seeded(client, seeded_db):
    response = client.get("/api/v1/notifications")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 3

    # Verify fields of a notification
    item = data[0]
    assert "id" in item
    assert "student_id" in item
    assert "title" in item
    assert "message" in item
    assert "category" in item
    assert "notification_type" in item
    assert "is_read" in item
    assert "created_at" in item


def test_list_notifications_by_student_and_endpoint(client, seeded_db):
    # Query via query parameter
    res1 = client.get(f"/api/v1/notifications?student_id={DEMO_STUDENT_ID}")
    assert res1.status_code == 200
    data1 = res1.json()
    assert len(data1) >= 3

    # Query via student sub-resource endpoint
    res2 = client.get(f"/api/v1/students/{DEMO_STUDENT_ID}/notifications")
    assert res2.status_code == 200
    data2 = res2.json()
    assert len(data2) == len(data1)

    # Query with unread_only=true
    res_unread = client.get(f"/api/v1/notifications?student_id={DEMO_STUDENT_ID}&unread_only=true")
    assert res_unread.status_code == 200
    unreads = res_unread.json()
    assert all(not n["is_read"] for n in unreads)


def test_create_notification_api(client, seeded_db):
    payload = {
        "student_id": DEMO_STUDENT_ID,
        "application_id": DEMO_APPLICATION_ID,
        "title": "Scholarship Review Update",
        "message": "Your scholarship review has moved to manual inspection.",
        "category": "VERIFICATION",
    }
    response = client.post("/api/v1/notifications", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["student_id"] == DEMO_STUDENT_ID
    assert data["application_id"] == DEMO_APPLICATION_ID
    assert data["title"] == payload["title"]
    assert data["message"] == payload["message"]
    assert data["category"] == "VERIFICATION"
    assert data["notification_type"] == "VERIFICATION"
    assert data["is_read"] is False


def test_create_notification_student_not_found(client, seeded_db):
    payload = {
        "student_id": "non-existent-student-id",
        "title": "Test Title",
        "message": "Test Message",
        "category": "APPLICATION_UPDATE",
    }
    response = client.post("/api/v1/notifications", json=payload)
    assert response.status_code == 404
    assert response.json()["detail"] == "Student not found"


def test_create_notification_application_not_found(client, seeded_db):
    payload = {
        "student_id": DEMO_STUDENT_ID,
        "application_id": "non-existent-app-id",
        "title": "Test Title",
        "message": "Test Message",
        "category": "APPLICATION_UPDATE",
    }
    response = client.post("/api/v1/notifications", json=payload)
    assert response.status_code == 404
    assert response.json()["detail"] == "Application not found"


def test_mark_notification_as_read_api(client, seeded_db):
    # Create fresh unread notification
    create_res = client.post(
        "/api/v1/notifications",
        json={
            "student_id": DEMO_STUDENT_ID,
            "title": "Unread Notification",
            "message": "Please read this update.",
            "category": "DEFICIENCY",
        },
    )
    assert create_res.status_code == 201
    notif_id = create_res.json()["id"]
    assert create_res.json()["is_read"] is False

    # Mark as read using PATCH
    patch_res = client.patch(f"/api/v1/notifications/{notif_id}/read")
    assert patch_res.status_code == 200
    assert patch_res.json()["is_read"] is True

    # Re-fetch via list and confirm is_read
    list_res = client.get(f"/api/v1/notifications?student_id={DEMO_STUDENT_ID}")
    item = next(n for n in list_res.json() if n["id"] == notif_id)
    assert item["is_read"] is True


def test_mark_notification_not_found(client, seeded_db):
    response = client.patch("/api/v1/notifications/non-existent-notif-id/read")
    assert response.status_code == 404
    assert response.json()["detail"] == "Notification not found"


def test_notification_service_direct(db_session, seeded_db):
    # Direct service function invocation
    create_dto = NotificationCreate(
        student_id=DEMO_STUDENT_ID,
        application_id=DEMO_APPLICATION_ID,
        title="Direct Service Notification",
        message="Created directly via notification service.",
        category="PAYMENT",
    )
    notif = service_create_notification(seeded_db, create_dto)
    assert notif.id is not None
    assert notif.category == "PAYMENT"
    assert notif.is_read is False

    # Mark as read directly via service
    updated = service_mark_as_read(seeded_db, notif.id)
    assert updated.is_read is True

    # List via service
    results = service_list_notifications(seeded_db, student_id=DEMO_STUDENT_ID)
    assert any(n.id == notif.id for n in results)
