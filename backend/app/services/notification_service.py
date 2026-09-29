import uuid
from sqlalchemy.orm import Session

from app.models.notification import Notification
from app.schemas.notification import NotificationCreate
from app.repositories.student_repository import get_student_by_id
from app.repositories.application_repository import get_application_by_id
from app.repositories.notification_repository import (
    create_notification as repo_create_notification,
    get_notification_by_id,
    get_notifications_by_student_id,
    get_all_notifications,
    update_notification_read_status,
)

VALID_CATEGORIES = {
    "APPLICATION_UPDATE",
    "DEFICIENCY",
    "VERIFICATION",
    "PAYMENT",
    "SANCTION",
    "ACTION_REQUIRED",
}


def create_notification(db: Session, data: NotificationCreate):
    student = get_student_by_id(db, data.student_id)
    if not student:
        return "STUDENT_NOT_FOUND"

    if data.application_id:
        application = get_application_by_id(db, data.application_id)
        if not application:
            return "APPLICATION_NOT_FOUND"

    category = data.category.strip().upper() if data.category else "APPLICATION_UPDATE"
    if category not in VALID_CATEGORIES:
        category = "APPLICATION_UPDATE"

    new_notification = Notification(
        id=str(uuid.uuid4()),
        student_id=data.student_id,
        application_id=data.application_id,
        title=data.title.strip(),
        message=data.message.strip(),
        category=category,
        is_read=False,
    )

    return repo_create_notification(db, new_notification)


def list_notifications(
    db: Session,
    student_id: str | None = None,
    unread_only: bool = False,
):
    if student_id:
        student = get_student_by_id(db, student_id)
        if not student:
            return "STUDENT_NOT_FOUND"
        return get_notifications_by_student_id(db, student_id, unread_only=unread_only)

    return get_all_notifications(db, unread_only=unread_only)


def mark_as_read(db: Session, notification_id: str):
    notification = get_notification_by_id(db, notification_id)
    if not notification:
        return "NOTIFICATION_NOT_FOUND"

    return update_notification_read_status(db, notification, is_read=True)
