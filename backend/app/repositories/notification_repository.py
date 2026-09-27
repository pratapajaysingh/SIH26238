from sqlalchemy.orm import Session
from app.models.notification import Notification


def create_notification(db: Session, notification: Notification) -> Notification:
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification


def get_notification_by_id(db: Session, notification_id: str) -> Notification | None:
    return db.query(Notification).filter(Notification.id == notification_id).first()


def get_notifications_by_student_id(
    db: Session,
    student_id: str,
    unread_only: bool = False,
) -> list[Notification]:
    query = db.query(Notification).filter(Notification.student_id == student_id)
    if unread_only:
        query = query.filter(Notification.is_read == False)
    return query.order_by(Notification.created_at.desc()).all()


def get_all_notifications(db: Session, unread_only: bool = False) -> list[Notification]:
    query = db.query(Notification)
    if unread_only:
        query = query.filter(Notification.is_read == False)
    return query.order_by(Notification.created_at.desc()).all()


def update_notification_read_status(
    db: Session,
    notification: Notification,
    is_read: bool = True,
) -> Notification:
    notification.is_read = is_read
    db.commit()
    db.refresh(notification)
    return notification
