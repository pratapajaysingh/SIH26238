from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.schemas.application import (
    ApplicationCreate,
    ApplicationResponse,
    ApplicationStatusResponse,
    ApplicationDeficiencyResponse,
)
from app.schemas.application_document import ApplicationDocumentCreate, ApplicationDocumentResponse
from app.schemas.document import DocumentResponse
from app.schemas.payment import PaymentStatusResponse
from app.services.application_service import (
    create_application,
    list_applications,
    get_application_status,
    get_application_deficiencies,
)
from app.services.payment_service import get_payment_status
from app.services.application_document_service import (
    link_document_to_application,
    get_application_documents,
)

router = APIRouter(prefix="/applications", tags=["Applications"])


@router.post("", response_model=ApplicationResponse)
@router.post("/", response_model=ApplicationResponse, include_in_schema=False)
def create_application_api(
    application: ApplicationCreate,
    db: Session = Depends(get_db)
):
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
    db: Session = Depends(get_db)
):
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



