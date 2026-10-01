from sqlalchemy.orm import Session
from app.repositories.verification_repository import (
    get_verification_by_id,
    update_verification_status,
)
from app.repositories.manual_review_repository import (
    get_manual_review_by_verification_id,
    create_manual_review as repo_create_manual_review,
    get_manual_reviews as repo_get_manual_reviews,
)


def create_manual_review(db: Session, verification_id: str):
    # 1. get verification by id
    verification = get_verification_by_id(db, verification_id)
    if not verification:
        return "VERIFICATION_NOT_FOUND"

    # 2. if status != MISMATCH -> NOT_ELIGIBLE
    if verification.status != "MISMATCH":
        return "NOT_ELIGIBLE"

    # 3. check existing review
    existing = get_manual_review_by_verification_id(db, verification_id)
    if existing:
        return "REVIEW_ALREADY_EXISTS"

    # 4. Atomic transaction: create ManualReview (OPEN) + update VerificationRecord (MANUAL_REVIEW)
    try:
        # 1. add ManualReview
        review = repo_create_manual_review(
            db,
            application_id=verification.application_id,
            verification_id=verification_id,
            commit=False,
        )
        # 2. set VerificationRecord.status = "MANUAL_REVIEW"
        update_verification_status(db, verification, "MANUAL_REVIEW", commit=False)
        # 3. commit once
        db.commit()
        # 4. refresh ManualReview
        db.refresh(review)
        return review
    except Exception:
        db.rollback()
        raise


def get_manual_reviews(db: Session):
    return repo_get_manual_reviews(db)


def decide_manual_review(db: Session, review_id: str, action: str, remarks: str | None = None):
    from app.models.manual_review import ManualReview
    review = db.query(ManualReview).filter(ManualReview.id == review_id).first()
    if not review:
        return "NOT_FOUND"

    action_norm = (action or "").strip().upper()
    if action_norm not in {"APPROVE", "APPROVED", "REJECT", "REJECTED"}:
        return "INVALID_ACTION"

    verification = get_verification_by_id(db, review.verification_id)
    if action_norm in {"APPROVE", "APPROVED"}:
        review.status = "RESOLVED"
        if verification:
            update_verification_status(db, verification, "VERIFIED", commit=False)
    else:
        review.status = "REJECTED"
        if verification:
            update_verification_status(db, verification, "REJECTED", commit=False)

    db.commit()
    db.refresh(review)
    return review
