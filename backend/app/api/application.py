from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user, get_current_user_optional
from app.models.user import User
from app.repositories.application_repository import get_application_by_id
from app.schemas.application import (
    ApplicationCreate,
    ApplicationResponse,
    ApplicationStatusResponse,
    ApplicationDeficiencyResponse,
    TimelineEventResponse,
    ApplicationStatusTransitionRequest,
    ApplicationTransitionResponse,
)
from app.schemas.application_document import ApplicationDocumentCreate, ApplicationDocumentResponse
from app.schemas.document import DocumentResponse
from app.schemas.payment import PaymentStatusResponse
from app.services.application_service import (
    create_application,
    list_applications,
    list_student_applications,
    get_application_status,
    get_application_deficiencies,
    get_application_timeline,
    transition_application_status,
    ALLOWED_APPLICATION_STATUSES,
    VALID_STATUS_TRANSITIONS,
)
from app.services.student_service import get_student_by_user
from app.services.payment_service import get_payment_status
from app.services.application_document_service import (
    link_document_to_application,
    get_application_documents,
)

router = APIRouter(prefix="/applications", tags=["Applications"])


@router.get("/me", response_model=list[ApplicationResponse])
@router.get("/me/", response_model=list[ApplicationResponse], include_in_schema=False)
def get_my_applications_api(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve all applications belonging to the currently authenticated student."""
    student = get_student_by_user(db, current_user.id)
    if not student:
        return []
    return list_student_applications(db, student.id)



@router.post("", response_model=ApplicationResponse)
@router.post("/", response_model=ApplicationResponse, include_in_schema=False)
def create_application_api(
    application: ApplicationCreate,
    current_user: User | None = Depends(get_current_user_optional),
    db: Session = Depends(get_db)
):
    if current_user:
        student = get_student_by_user(db, current_user.id)
        if not student or application.student_id != student.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied: Cannot create application for another student",
            )

    result = create_application(db, application)

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


@router.get("", response_model=list[ApplicationResponse])
@router.get("/", response_model=list[ApplicationResponse], include_in_schema=False)
def list_applications_api(db: Session = Depends(get_db)):
    return list_applications(db)



@router.post("/{application_id}/documents", response_model=ApplicationDocumentResponse)
@router.post("/{application_id}/documents/", response_model=ApplicationDocumentResponse, include_in_schema=False)
def link_application_document_api(
    application_id: str,
    payload: ApplicationDocumentCreate,
    current_user: User | None = Depends(get_current_user_optional),
    db: Session = Depends(get_db)
):
    if current_user:
        student = get_student_by_user(db, current_user.id)
        if not student:
            raise HTTPException(
                status_code=403,
                detail="Access denied: No student profile associated with user",
            )
        app = get_application_by_id(db, application_id)
        if app and app.student_id != student.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied: Cannot modify another student's application",
            )

    result = link_document_to_application(db, application_id, payload.document_id)

    if result == "APPLICATION_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    if result == "DOCUMENT_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Document not found"
        )

    if result == "STUDENT_MISMATCH":
        raise HTTPException(
            status_code=409,
            detail="Document does not belong to application student"
        )

    if result == "ALREADY_LINKED":
        raise HTTPException(
            status_code=409,
            detail="Document already linked to application"
        )

    return result


@router.get("/{application_id}/documents", response_model=list[DocumentResponse])
@router.get("/{application_id}/documents/", response_model=list[DocumentResponse], include_in_schema=False)
def list_application_documents_api(
    application_id: str,
    db: Session = Depends(get_db)
):
    result = get_application_documents(db, application_id)

    if result == "APPLICATION_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    return result


@router.get("/{application_id}/status", response_model=ApplicationStatusResponse)
@router.get("/{application_id}/status/", response_model=ApplicationStatusResponse, include_in_schema=False)
def get_application_status_api(
    application_id: str,
    db: Session = Depends(get_db)
):
    result = get_application_status(db, application_id)

    if result == "APPLICATION_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    return result


@router.get("/{application_id}/deficiencies", response_model=list[ApplicationDeficiencyResponse])
@router.get("/{application_id}/deficiencies/", response_model=list[ApplicationDeficiencyResponse], include_in_schema=False)
def get_application_deficiencies_api(
    application_id: str,
    db: Session = Depends(get_db)
):
    result = get_application_deficiencies(db, application_id)

    if result == "APPLICATION_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    return result


@router.get("/{application_id}/payment-status", response_model=PaymentStatusResponse)
@router.get("/{application_id}/payment-status/", response_model=PaymentStatusResponse, include_in_schema=False)
def get_payment_status_api(
    application_id: str,
    db: Session = Depends(get_db)
):
    result = get_payment_status(db, application_id)

    if result == "APPLICATION_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    return result


@router.get("/{application_id}/timeline", response_model=list[TimelineEventResponse])
@router.get("/{application_id}/timeline/", response_model=list[TimelineEventResponse], include_in_schema=False)
def get_application_timeline_api(
    application_id: str,
    db: Session = Depends(get_db)
):
    result = get_application_timeline(db, application_id)

    if result == "APPLICATION_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    return result


@router.get("/{application_id}/payments", response_model=PaymentStatusResponse, include_in_schema=False)
@router.get("/{application_id}/payments/", response_model=PaymentStatusResponse, include_in_schema=False)
def get_payment_status_legacy_alias_api(
    application_id: str,
    db: Session = Depends(get_db)
):
    """Compatibility alias for legacy documentation referencing /payments instead of /payment-status."""
    return get_payment_status_api(application_id, db)


@router.post("/{application_id}/transition", response_model=ApplicationTransitionResponse)
@router.post("/{application_id}/transition/", response_model=ApplicationTransitionResponse, include_in_schema=False)
@router.patch("/{application_id}/status", response_model=ApplicationTransitionResponse, include_in_schema=False)
@router.patch("/{application_id}/status/", response_model=ApplicationTransitionResponse, include_in_schema=False)
def transition_application_status_api(
    application_id: str,
    payload: ApplicationStatusTransitionRequest,
    current_user: User | None = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    """Execute a validated lifecycle state transition for an application.

    Atomically updates the current application status and records a corresponding
    chronological timeline event.
    """
    if current_user:
        student = get_student_by_user(db, current_user.id)
        if not student:
            raise HTTPException(
                status_code=403,
                detail="Access denied: No student profile associated with user",
            )
        app = get_application_by_id(db, application_id)
        if app and app.student_id != student.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied: Cannot transition another student's application",
            )

    result = transition_application_status(
        db,
        application_id=application_id,
        target_status=payload.status,
        message=payload.message,
    )

    if result == "APPLICATION_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Application not found",
        )

    if result == "INVALID_STATUS":
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status '{payload.status}'. Allowed statuses: {', '.join(sorted(ALLOWED_APPLICATION_STATUSES))}",
        )

    if result == "INVALID_TRANSITION":
        current_status_res = get_application_status(db, application_id)
        curr_str = current_status_res.get("status", "UNKNOWN") if isinstance(current_status_res, dict) else "UNKNOWN"
        allowed = sorted(list(VALID_STATUS_TRANSITIONS.get(curr_str, set())))
        raise HTTPException(
            status_code=400,
            detail=f"Cannot transition application from '{curr_str}' to '{payload.status}'. Allowed next states: {allowed}",
        )

    return result



