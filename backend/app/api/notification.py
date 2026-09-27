from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.schemas.notification import NotificationCreate, NotificationResponse
from app.services.notification_service import (
    create_notification,
    list_notifications,
    mark_as_read,
)

router = APIRouter(tags=["Notifications"])


@router.get("/notifications", response_model=list[NotificationResponse])
@router.get("/notifications/", response_model=list[NotificationResponse], include_in_schema=False)
def get_notifications_api(
    student_id: str | None = None,
    unread_only: bool = False,
    db: Session = Depends(get_db),
):
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
    db: Session = Depends(get_db),
):
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
    db: Session = Depends(get_db),
):
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
    db: Session = Depends(get_db),
):
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
