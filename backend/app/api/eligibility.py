from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.schemas.eligibility import EligibilityCheckRequest, EligibilityCheckResponse, ConflictCheckResponse
from app.services.eligibility_service import check_eligibility, check_conflict

router = APIRouter(prefix="/eligibility", tags=["Eligibility"])


@router.post("/check", response_model=EligibilityCheckResponse)
@router.post("/check/", response_model=EligibilityCheckResponse, include_in_schema=False)
def check_eligibility_api(
    payload: EligibilityCheckRequest,
    db: Session = Depends(get_db)
):
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
    db: Session = Depends(get_db)
):
    """Unified eligibility/conflict check per SIH requirement.
    
    Checks whether a student can apply for a new scheme given their existing
    active applications and sanctioned scholarships. A student can avail
    only one scholarship/fellowship scheme at a time.
    """
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
