"""Analytics API Router — Ministry-side visibility and unreached beneficiary identification.

PROTOTYPE: Uses mock/demo data. No real UDISE+, APAAR, or OTR APIs are called.
"""

from datetime import datetime
import uuid
from pydantic import BaseModel
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user
from app.models.user import User
from app.models.student import Student
from app.models.notification import Notification
from app.schemas.notification import NotificationResponse
from app.seed import DEMO_STUDENT_ID, DEMO_STUDENT_ID_2, DEMO_STUDENT_ID_3, DEMO_STUDENT_ID_4
from app.services.unreached_service import (
    identify_unreached_beneficiaries,
    get_unreached_only,
    get_unreached_summary,
)
from app.services.analytics_service import get_dashboard_analytics

router = APIRouter(prefix="/analytics", tags=["Analytics (Prototype)"])


class OutreachRequest(BaseModel):
    demo_id: str | None = None
    student_id: str | None = None
    title: str = "Scholarship Outreach Notice"
    message: str = "Ministry of Tribal Affairs has identified you as potentially eligible for scholarship schemes. Open TribalSetu to apply."


def _assert_admin(current_user: User) -> None:
    """Enforces admin role guard: authenticated students are rejected with 403."""
    if current_user.role.upper() != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied: Admin role required for ministry analytics",
        )


@router.get("/unreached-beneficiaries")
@router.get("/unreached-beneficiaries/", include_in_schema=False)
def get_unreached_beneficiaries_api(
    current_user: User = Depends(get_current_user),
):
    """Identify ST students who are enrolled but not receiving scholarship benefits.
    
    PROTOTYPE: Uses mock UDISE+/APAAR/OTR data. No real government APIs are called.
    """
    _assert_admin(current_user)
    return {
        "results": get_unreached_only(),
        "summary": get_unreached_summary(),
        "data_source": "MOCK_PROTOTYPE",
    }


@router.get("/unreached-beneficiaries/all")
@router.get("/unreached-beneficiaries/all/", include_in_schema=False)
def get_all_beneficiary_matching_api(
    current_user: User = Depends(get_current_user),
):
    """Full matching results for all enrolled students (matched + unreached).
    
    PROTOTYPE: Uses mock UDISE+/APAAR/OTR data. No real government APIs are called.
    """
    _assert_admin(current_user)
    return {
        "results": identify_unreached_beneficiaries(),
        "summary": get_unreached_summary(),
        "data_source": "MOCK_PROTOTYPE",
    }


@router.get("/dashboard")
@router.get("/dashboard/", include_in_schema=False)
def get_dashboard_analytics_api(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Ministry-side dashboard analytics.
    
    Provides scheme-wise application counts, sanctions, payments, deficiency,
    verification/manual-review counts, and unreached beneficiary summary.
    
    PROTOTYPE: Uses mock/demo data.
    """
    _assert_admin(current_user)
    return get_dashboard_analytics(db)


@router.post("/unreached-beneficiaries/outreach", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
@router.post("/unreached-beneficiaries/outreach/", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
def send_outreach_notification_api(
    payload: OutreachRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Dispatch scholarship awareness outreach notification to an unreached ST student."""
    _assert_admin(current_user)

    target_student: Student | None = None
    if payload.student_id:
        target_student = db.query(Student).filter(Student.id == payload.student_id).first()

    if not target_student and payload.demo_id:
        # Map unreached demo IDs to seeded students
        demo_map = {
            "ENROL-ST-002": DEMO_STUDENT_ID_2,
            "ENROL-ST-003": DEMO_STUDENT_ID_3,
            "ENROL-ST-005": DEMO_STUDENT_ID_2,
            "ENROL-ST-001": DEMO_STUDENT_ID,
            "ENROL-ST-004": DEMO_STUDENT_ID_4,
        }
        mapped_id = demo_map.get(payload.demo_id, DEMO_STUDENT_ID_2)
        target_student = db.query(Student).filter(Student.id == mapped_id).first()

    if not target_student:
        target_student = db.query(Student).filter(Student.id == DEMO_STUDENT_ID_2).first() or db.query(Student).first()

    if not target_student:
        raise HTTPException(status_code=404, detail="Target student record not found")

    notif = Notification(
        id=str(uuid.uuid4()),
        student_id=target_student.id,
        application_id=None,
        title=payload.title,
        message=payload.message,
        is_read=False,
        created_at=datetime.utcnow(),
    )
    db.add(notif)
    db.commit()
    db.refresh(notif)
    return notif
