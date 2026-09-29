from sqlalchemy.orm import Session
from app.models.application import Application
from app.models.application_timeline import ApplicationTimeline
from app.schemas.application import ApplicationCreate
from app.repositories.application_repository import (
    create_application as repo_create_application,
    get_applications,
    get_application_by_id,
    get_applications_by_student_id,
    get_student_by_id,
    get_scholarship_by_id,
    update_application_status as repo_update_application_status,
)
from app.repositories.application_timeline_repository import (
    create_timeline_entry as repo_create_timeline_entry,
    get_timeline_by_application_id as repo_get_timeline_by_application_id,
)

from app.repositories.verification_repository import (
    get_verifications_by_application_id,
)
from app.repositories.document_repository import (
    get_document_by_id,
)
from app.repositories.application_document_repository import (
    get_documents_by_application_id,
)
from app.repositories.manual_review_repository import (
    get_manual_review_by_verification_id,
)

ALLOWED_APPLICATION_STATUSES = {
    "DRAFT",
    "SUBMITTED",
    "IN_VERIFICATION",
    "DEFICIENCY",
    "RESUBMITTED",
    "MANUAL_REVIEW",
    "SANCTIONED",
    "PAYMENT_INITIATED",
    "DBT_SENT",
    "REJECTED",
    "WITHDRAWN",
    "COMPLETED",
}

VALID_STATUS_TRANSITIONS: dict[str, set[str]] = {
    "DRAFT": {"SUBMITTED", "WITHDRAWN"},
    "SUBMITTED": {"IN_VERIFICATION", "DEFICIENCY", "REJECTED", "WITHDRAWN"},
    "IN_VERIFICATION": {"DEFICIENCY", "MANUAL_REVIEW", "SANCTIONED", "REJECTED", "WITHDRAWN"},
    "DEFICIENCY": {"RESUBMITTED", "SUBMITTED", "IN_VERIFICATION", "REJECTED", "WITHDRAWN"},
    "RESUBMITTED": {"IN_VERIFICATION", "MANUAL_REVIEW", "DEFICIENCY", "REJECTED", "WITHDRAWN"},
    "MANUAL_REVIEW": {"SANCTIONED", "DEFICIENCY", "IN_VERIFICATION", "REJECTED", "WITHDRAWN"},
    "SANCTIONED": {"PAYMENT_INITIATED", "DBT_SENT", "COMPLETED", "REJECTED"},
    "PAYMENT_INITIATED": {"DBT_SENT", "COMPLETED", "REJECTED"},
    "DBT_SENT": {"COMPLETED", "REJECTED"},
    "REJECTED": set(),
    "WITHDRAWN": set(),
    "COMPLETED": set(),
}



def create_application(db: Session, application: ApplicationCreate):
    student = get_student_by_id(db, application.student_id)
    if not student:
        return "STUDENT_NOT_FOUND"

    scholarship = get_scholarship_by_id(db, application.scholarship_id)
    if not scholarship:
        return "SCHOLARSHIP_NOT_FOUND"

    new_application = Application(
        student_id=application.student_id,
        scholarship_id=application.scholarship_id,
        status="DRAFT"
    )

    created = repo_create_application(db, new_application)

    # Automatically record initial DRAFT timeline event
    initial_timeline = ApplicationTimeline(
        application_id=created.id,
        status="DRAFT",
        message="Application initialized in DRAFT status",
    )
    repo_create_timeline_entry(db, initial_timeline)

    return created


def list_applications(db: Session):
    return get_applications(db)


def list_student_applications(db: Session, student_id: str):
    return get_applications_by_student_id(db, student_id)



def get_application_status(db: Session, application_id: str):
    application = get_application_by_id(db, application_id)
    if not application:
        return "APPLICATION_NOT_FOUND"

    return {
        "id": application.id,
        "status": application.status,
    }


def get_application_deficiencies(db: Session, application_id: str):
    application = get_application_by_id(db, application_id)
    if not application:
        return "APPLICATION_NOT_FOUND"

    deficiencies = []
    doc_ids_with_deficiency = set()

    # 1. Check verification records for attached documents
    verifications = get_verifications_by_application_id(db, application_id)
    for verif in verifications:
        doc = get_document_by_id(db, verif.document_id)
        doc_name = doc.document_name if doc else verif.document_id
        doc_type = doc.document_type if doc else None

        if verif.status == "MISMATCH":
            doc_ids_with_deficiency.add(verif.document_id)
            msg = f"Attributes for document '{doc_name}' do not match student records"
            deficiencies.append({
                "id": f"def-verif-{verif.id}",
                "application_id": application_id,
                "deficiency_type": "DOCUMENT_MISMATCH",
                "type": "DOCUMENT_MISMATCH",
                "category": "VERIFICATION",
                "document_id": verif.document_id,
                "document_name": doc_name,
                "document_type": doc_type,
                "verification_id": verif.id,
                "status": "MISMATCH",
                "severity": "HIGH",
                "message": msg,
                "reason": msg,
            })
        elif verif.status == "FAILED":
            doc_ids_with_deficiency.add(verif.document_id)
            msg = f"Verification failed for document '{doc_name}' against simulated issuer registry"
            deficiencies.append({
                "id": f"def-verif-{verif.id}",
                "application_id": application_id,
                "deficiency_type": "VERIFICATION_FAILED",
                "type": "VERIFICATION_FAILED",
                "category": "VERIFICATION",
                "document_id": verif.document_id,
                "document_name": doc_name,
                "document_type": doc_type,
                "verification_id": verif.id,
                "status": "FAILED",
                "severity": "CRITICAL",
                "message": msg,
                "reason": msg,
            })
        elif verif.status == "MANUAL_REVIEW":
            doc_ids_with_deficiency.add(verif.document_id)
            review = get_manual_review_by_verification_id(db, verif.id)
            if not review or review.status != "RESOLVED":
                review_status = review.status if review else "OPEN"
                msg = f"Document '{doc_name}' requires manual review (review status: {review_status})"
                deficiencies.append({
                    "id": f"def-verif-{verif.id}",
                    "application_id": application_id,
                    "deficiency_type": "MANUAL_REVIEW_REQUIRED",
                    "type": "MANUAL_REVIEW_REQUIRED",
                    "category": "MANUAL_REVIEW",
                    "document_id": verif.document_id,
                    "document_name": doc_name,
                    "document_type": doc_type,
                    "verification_id": verif.id,
                    "status": "MANUAL_REVIEW",
                    "severity": "MEDIUM",
                    "message": msg,
                    "reason": msg,
                })

    # 2. Check attached documents for REJECTED status
    attached_docs = get_documents_by_application_id(db, application_id)
    for doc in attached_docs:
        if doc.status == "REJECTED" and doc.id not in doc_ids_with_deficiency:
            msg = f"Document '{doc.document_name}' has been rejected"
            deficiencies.append({
                "id": f"def-doc-{doc.id}",
                "application_id": application_id,
                "deficiency_type": "DOCUMENT_REJECTED",
                "type": "DOCUMENT_REJECTED",
                "category": "DOCUMENT",
                "document_id": doc.id,
                "document_name": doc.document_name,
                "document_type": doc.document_type,
                "verification_id": None,
                "status": "REJECTED",
                "severity": "HIGH",
                "message": msg,
                "reason": msg,
            })

    # 3. Check application status DEFICIENCY
    if application.status == "DEFICIENCY":
        msg = "Application has been flagged for deficiencies"
        deficiencies.append({
            "id": f"def-app-{application.id}",
            "application_id": application.id,
            "deficiency_type": "APPLICATION_DEFICIENCY",
            "type": "APPLICATION_DEFICIENCY",
            "category": "APPLICATION",
            "document_id": None,
            "document_name": None,
            "document_type": None,
            "verification_id": None,
            "status": "DEFICIENCY",
            "severity": "HIGH",
            "message": msg,
            "reason": msg,
        })

    return deficiencies


def get_application_timeline(db: Session, application_id: str):
    """Retrieve ordered status history / timeline events for an application."""
    application = get_application_by_id(db, application_id)
    if not application:
        return "APPLICATION_NOT_FOUND"

    return repo_get_timeline_by_application_id(db, application_id)


def add_application_timeline_entry(
    db: Session,
    application_id: str,
    status: str,
    message: str | None = None,
):
    """Append a new status transition / timeline event to an existing application."""
    application = get_application_by_id(db, application_id)
    if not application:
        return "APPLICATION_NOT_FOUND"

    if status not in ALLOWED_APPLICATION_STATUSES:
        raise ValueError(
            f"Invalid application status '{status}'. Must be one of: {', '.join(sorted(ALLOWED_APPLICATION_STATUSES))}"
        )

    entry = ApplicationTimeline(
        application_id=application_id,
        status=status,
        message=message,
    )
    return repo_create_timeline_entry(db, entry)


def transition_application_status(
    db: Session,
    application_id: str,
    target_status: str,
    message: str | None = None,
):
    """Execute a validated lifecycle state transition for an application.

    Validates:
    1. Application exists.
    2. Target status is in ALLOWED_APPLICATION_STATUSES.
    3. Transition from current_status to target_status is permitted in VALID_STATUS_TRANSITIONS.

    Upon validation, atomically:
    1. Updates Application.status.
    2. Creates a chronological ApplicationTimeline record.
    """
    application = get_application_by_id(db, application_id)
    if not application:
        return "APPLICATION_NOT_FOUND"

    normalized_status = target_status.strip().upper() if isinstance(target_status, str) else target_status
    if normalized_status not in ALLOWED_APPLICATION_STATUSES:
        return "INVALID_STATUS"

    current_status = application.status
    allowed_transitions = VALID_STATUS_TRANSITIONS.get(current_status, set())
    if normalized_status not in allowed_transitions:
        return "INVALID_TRANSITION"

    transition_msg = message or f"Application transitioned from {current_status} to {normalized_status}"

    # Atomic update and timeline recording
    application.status = normalized_status
    timeline_entry = ApplicationTimeline(
        application_id=application.id,
        status=normalized_status,
        message=transition_msg,
    )
    db.add(timeline_entry)
    db.commit()
    db.refresh(application)

    return {
        "id": application.id,
        "status": application.status,
        "previous_status": current_status,
        "message": transition_msg,
    }

