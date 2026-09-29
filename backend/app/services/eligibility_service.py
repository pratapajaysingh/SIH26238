from sqlalchemy.orm import Session
from app.repositories.student_repository import get_student_by_id
from app.repositories.scholarship_repository import get_scholarship_by_id
from app.repositories.application_repository import get_applications_by_student_id
from app.schemas.eligibility import EligibilityCheckRequest, EligibilityCheckResponse, ConflictCheckResponse


# Terminal statuses that do NOT block future applications
TERMINAL_STATUSES = {"REJECTED", "WITHDRAWN", "COMPLETED"}

# Non-terminal statuses: application is still active/in-progress
NON_TERMINAL_STATUSES = {
    "DRAFT",
    "SUBMITTED",
    "IN_VERIFICATION",
    "DEFICIENCY",
    "RESUBMITTED",
    "MANUAL_REVIEW",
    "SANCTIONED",
    "PAYMENT_INITIATED",
    "DBT_SENT",
}



def evaluate_mock_eligibility(student, scholarship) -> dict:
    """Isolated mock eligibility evaluator for Phase 1.
    
    This is NOT an official government or MoTA rules engine.
    Official criteria (income, category, marks, age, etc.) are not configured.
    """
    return {
        "eligible": True,
        "reasons": [
            "Mock eligibility evaluation only; official scheme rules are not configured"
        ],
        "evaluation_mode": "MOCK",
    }


def check_eligibility(db: Session, request: EligibilityCheckRequest):
    student = get_student_by_id(db, request.student_id)
    if not student:
        return "STUDENT_NOT_FOUND"

    scholarship = get_scholarship_by_id(db, request.scholarship_id)
    if not scholarship:
        return "SCHOLARSHIP_NOT_FOUND"

    eval_result = evaluate_mock_eligibility(student, scholarship)

    return EligibilityCheckResponse(
        student_id=request.student_id,
        scholarship_id=request.scholarship_id,
        eligible=eval_result["eligible"],
        reasons=eval_result["reasons"],
        evaluation_mode=eval_result["evaluation_mode"],
    )


def check_conflict(db: Session, student_id: str, scholarship_id: str) -> ConflictCheckResponse | str:
    """Unified eligibility/conflict check per SIH requirement:
    A student can avail only one scholarship/fellowship scheme at a time.
    
    Checks:
    1. Student and scholarship exist
    2. Duplicate application for same scheme
    3. Existing active (non-terminal) application for another scheme
    4. Sanctioned scholarship conflict
    5. Deficiency/pending action
    """
    student = get_student_by_id(db, student_id)
    if not student:
        return "STUDENT_NOT_FOUND"

    scholarship = get_scholarship_by_id(db, scholarship_id)
    if not scholarship:
        return "SCHOLARSHIP_NOT_FOUND"

    existing_apps = get_applications_by_student_id(db, student_id)

    for app in existing_apps:
        # Skip terminal/historical applications — they don't block new ones
        if app.status in TERMINAL_STATUSES:
            continue

        # Check duplicate: same scheme, non-terminal
        if app.scholarship_id == scholarship_id:
            return ConflictCheckResponse(
                student_id=student_id,
                scholarship_id=scholarship_id,
                eligible=False,
                status="DUPLICATE_APPLICATION",
                reasons=[f"An active application already exists for this scheme (status: {app.status})"],
                existing_application_id=app.id,
                existing_scheme_code=getattr(scholarship, "code", None),
                evaluation_mode="MOCK",
            )

        # Check sanctioned conflict: another scheme is sanctioned
        if app.status == "SANCTIONED":
            # Resolve the other scheme's code for reporting
            other_scholarship = get_scholarship_by_id(db, app.scholarship_id)
            other_code = other_scholarship.code if other_scholarship else app.scholarship_id
            return ConflictCheckResponse(
                student_id=student_id,
                scholarship_id=scholarship_id,
                eligible=False,
                status="SANCTIONED_SCHEME_CONFLICT",
                reasons=[f"Already receiving benefits under scheme '{other_code}' (sanctioned)"],
                existing_application_id=app.id,
                existing_scheme_code=other_code,
                evaluation_mode="MOCK",
            )

        # Check deficiency: another application has a pending deficiency
        if app.status == "DEFICIENCY":
            other_scholarship = get_scholarship_by_id(db, app.scholarship_id)
            other_code = other_scholarship.code if other_scholarship else app.scholarship_id
            return ConflictCheckResponse(
                student_id=student_id,
                scholarship_id=scholarship_id,
                eligible=False,
                status="PENDING_DEFICIENCY",
                reasons=[f"Existing application for scheme '{other_code}' has pending deficiency action required"],
                existing_application_id=app.id,
                existing_scheme_code=other_code,
                evaluation_mode="MOCK",
            )

        # Check manual review: another application or this application is in manual review
        if app.status == "MANUAL_REVIEW":
            other_scholarship = get_scholarship_by_id(db, app.scholarship_id)
            other_code = other_scholarship.code if other_scholarship else app.scholarship_id
            return ConflictCheckResponse(
                student_id=student_id,
                scholarship_id=scholarship_id,
                eligible=False,
                status="REQUIRES_MANUAL_REVIEW",
                reasons=[f"Existing application for scheme '{other_code}' is currently undergoing manual review by a Nodal Officer"],
                existing_application_id=app.id,
                existing_scheme_code=other_code,
                evaluation_mode="MOCK",
            )


        # Check any other non-terminal active application for a different scheme
        if app.scholarship_id != scholarship_id:
            other_scholarship = get_scholarship_by_id(db, app.scholarship_id)
            other_code = other_scholarship.code if other_scholarship else app.scholarship_id
            return ConflictCheckResponse(
                student_id=student_id,
                scholarship_id=scholarship_id,
                eligible=False,
                status="ACTIVE_APPLICATION_EXISTS",
                reasons=[f"An active application exists for scheme '{other_code}' (status: {app.status})"],
                existing_application_id=app.id,
                existing_scheme_code=other_code,
                evaluation_mode="MOCK",
            )

    # No conflicts found — student is eligible
    return ConflictCheckResponse(
        student_id=student_id,
        scholarship_id=scholarship_id,
        eligible=True,
        status="ELIGIBLE",
        reasons=["No conflicting applications found; student may apply"],
        evaluation_mode="MOCK",
    )
