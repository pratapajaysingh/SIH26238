from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user_optional
from app.models.user import User
from app.repositories.application_repository import get_application_by_id
from app.repositories.verification_repository import get_verification_by_id
from app.schemas.manual_review import ManualReviewResponse, ManualReviewDecisionRequest
from app.services.manual_review_service import (
    create_manual_review,
    get_manual_reviews,
    decide_manual_review,
)
from app.services.student_service import get_student_by_user

router = APIRouter(tags=["Manual Review"])


@router.post(
    "/verifications/{verification_id}/manual-review",
    response_model=ManualReviewResponse,
)
@router.post(
    "/verifications/{verification_id}/manual-review/",
    response_model=ManualReviewResponse,
    include_in_schema=False,
)
def create_manual_review_api(
    verification_id: str,
    current_user: User | None = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    if current_user:
        student = get_student_by_user(db, current_user.id)
        if not student:
            raise HTTPException(
                status_code=403,
                detail="Access denied: No student profile associated with user",
            )
        verif = get_verification_by_id(db, verification_id)
        if verif:
            app = get_application_by_id(db, verif.application_id)
            if app and app.student_id != student.id:
                raise HTTPException(
                    status_code=403,
                    detail="Access denied: Cannot enqueue manual review for another student's application",
                )

    result = create_manual_review(db, verification_id)

    if result == "VERIFICATION_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Verification record not found",
        )

    if result == "NOT_ELIGIBLE":
        raise HTTPException(
            status_code=409,
            detail="Verification record is not eligible for manual review",
        )

    if result == "REVIEW_ALREADY_EXISTS":
        raise HTTPException(
            status_code=409,
            detail="Manual review already exists",
        )

    return result


@router.get(
    "/manual-reviews",
    response_model=list[ManualReviewResponse],
)
@router.get(
    "/manual-reviews/",
    response_model=list[ManualReviewResponse],
    include_in_schema=False,
)
def list_manual_reviews_api(
    current_user: User | None = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    if current_user and getattr(current_user, "role", "STUDENT") == "STUDENT":
        raise HTTPException(
            status_code=403,
            detail="Access denied: Student accounts cannot access the manual review queue",
        )
    return get_manual_reviews(db)


@router.post(
    "/manual-reviews/{review_id}/decide",
    response_model=ManualReviewResponse,
)
@router.post(
    "/manual-reviews/{review_id}/decide/",
    response_model=ManualReviewResponse,
    include_in_schema=False,
)
def decide_manual_review_api(
    review_id: str,
    payload: ManualReviewDecisionRequest,
    current_user: User | None = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    if current_user and getattr(current_user, "role", "STUDENT") == "STUDENT":
        raise HTTPException(
            status_code=403,
            detail="Access denied: Student accounts cannot resolve manual reviews",
        )
    result = decide_manual_review(db, review_id, payload.action, payload.remarks)
    if result == "NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Manual review record not found",
        )
    if result == "INVALID_ACTION":
        raise HTTPException(
            status_code=400,
            detail="Invalid action. Use APPROVE or REJECT.",
        )
    return result
