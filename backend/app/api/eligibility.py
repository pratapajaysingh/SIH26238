from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user
from app.models.user import User
from app.schemas.eligibility import EligibilityCheckRequest, EligibilityCheckResponse, ConflictCheckResponse
from app.services.eligibility_service import check_eligibility, check_conflict
from app.services.student_service import get_student_by_user

router = APIRouter(prefix="/eligibility", tags=["Eligibility"])


@router.post("/check", response_model=EligibilityCheckResponse)
@router.post("/check/", response_model=EligibilityCheckResponse, include_in_schema=False)
def check_eligibility_api(
    payload: EligibilityCheckRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role.upper() != "ADMIN":
        student = get_student_by_user(db, current_user.id)
        if not student or payload.student_id != student.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied: Cannot check eligibility for another student",
            )

    result = check_eligibility(db, payload)

    if result == "STUDENT_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Student not found"
        )

    if result == "SCHOLARSHIP_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Scholarship not found"
        )

    return result


@router.post("/conflict-check", response_model=ConflictCheckResponse)
@router.post("/conflict-check/", response_model=ConflictCheckResponse, include_in_schema=False)
def check_conflict_api(
    payload: EligibilityCheckRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Unified eligibility/conflict check per SIH requirement.
    
    Checks whether a student can apply for a new scheme given their existing
    active applications and sanctioned scholarships. A student can avail
    only one scholarship/fellowship scheme at a time.
    """
    if current_user.role.upper() != "ADMIN":
        student = get_student_by_user(db, current_user.id)
        if not student or payload.student_id != student.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied: Cannot check eligibility for another student",
            )

    result = check_conflict(db, payload.student_id, payload.scholarship_id)

    if result == "STUDENT_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Student not found"
        )

    if result == "SCHOLARSHIP_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Scholarship not found"
        )

    return result
