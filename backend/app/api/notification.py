from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user, get_db
from app.models.user import User

from app.schemas.notification import NotificationCreate, NotificationResponse
from app.services.notification_service import (
    create_notification,
    list_notifications,
    mark_as_read,
)
from app.services.student_service import get_student_by_user

from app.repositories.notification_repository import get_notification_by_id

router = APIRouter(tags=["Notifications"])


@router.get("/notifications/me", response_model=list[NotificationResponse])
@router.get("/notifications/me/", response_model=list[NotificationResponse], include_in_schema=False)
def get_my_notifications_api(
    unread_only: bool = False,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve notifications belonging to the currently authenticated student."""
    student = get_student_by_user(db, current_user.id)
    if not student:
        return []
    return list_notifications(db, student_id=student.id, unread_only=unread_only)


@router.get("/notifications", response_model=list[NotificationResponse])
@router.get("/notifications/", response_model=list[NotificationResponse], include_in_schema=False)
def get_notifications_api(
    student_id: str | None = None,
    unread_only: bool = False,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role.upper() != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied: Admin role required to view global notifications",
        )

    result = list_notifications(db, student_id=student_id, unread_only=unread_only)
    if result == "STUDENT_NOT_FOUND":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found",
        )
    return result



@router.get("/students/{student_id}/notifications", response_model=list[NotificationResponse])
@router.get("/students/{student_id}/notifications/", response_model=list[NotificationResponse], include_in_schema=False)
def get_student_notifications_api(
    student_id: str,
    unread_only: bool = False,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role.upper() != "ADMIN":
        student = get_student_by_user(db, current_user.id)
        if not student or student_id != student.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied: Cannot access another student's notifications",
            )

    result = list_notifications(db, student_id=student_id, unread_only=unread_only)
    if result == "STUDENT_NOT_FOUND":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found",
        )
    return result


@router.patch("/notifications/{notification_id}/read", response_model=NotificationResponse)
@router.patch("/notifications/{notification_id}/read/", response_model=NotificationResponse, include_in_schema=False)
@router.post("/notifications/{notification_id}/read", response_model=NotificationResponse, include_in_schema=False)
@router.post("/notifications/{notification_id}/read/", response_model=NotificationResponse, include_in_schema=False)
def mark_notification_read_api(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    notif = get_notification_by_id(db, notification_id)
    if not notif:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found",
        )

    if current_user.role.upper() != "ADMIN":
        student = get_student_by_user(db, current_user.id)
        if not student or notif.student_id != student.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied: Cannot modify another student's notification",
            )

    result = mark_as_read(db, notification_id)
    if result == "NOTIFICATION_NOT_FOUND":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found",
        )
    return result


@router.post("/notifications", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
@router.post("/notifications/", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
def create_notification_api(
    payload: NotificationCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role.upper() != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied: Admin role required to create notifications",
        )

    result = create_notification(db, payload)
    if result == "STUDENT_NOT_FOUND":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found",
        )
    if result == "APPLICATION_NOT_FOUND":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found",
        )
    return result
