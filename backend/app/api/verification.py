from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user
from app.models.user import User
from app.repositories.application_repository import get_application_by_id
from app.repositories.verification_repository import get_verification_by_id
from app.schemas.verification import (
    VerificationCreate,
    VerificationRecordResponse,
    VerificationExecutionResponse,
)
from app.services.verification_service import (
    create_verification_record,
    get_application_verifications,
    execute_verification,
)
from app.services.student_service import get_student_by_user

router = APIRouter(tags=["Verification"])


@router.post("/applications/{application_id}/verifications", response_model=VerificationRecordResponse)
@router.post("/applications/{application_id}/verifications/", response_model=VerificationRecordResponse, include_in_schema=False)
def create_verification_api(
    application_id: str,
    payload: VerificationCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    app = get_application_by_id(db, application_id)
    if not app:
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    if current_user.role.upper() != "ADMIN":
        student = get_student_by_user(db, current_user.id)
        if not student or app.student_id != student.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied: Cannot create verifications on another student's application",
            )

    result = create_verification_record(db, application_id, payload.document_id)

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

    if result == "DOCUMENT_NOT_LINKED":
        raise HTTPException(
            status_code=409,
            detail="Document is not linked to application"
        )

    if result == "VERIFICATION_ALREADY_EXISTS":
        raise HTTPException(
            status_code=409,
            detail="Verification record already exists"
        )

    return result


@router.get("/applications/{application_id}/verifications", response_model=list[VerificationRecordResponse])
@router.get("/applications/{application_id}/verifications/", response_model=list[VerificationRecordResponse], include_in_schema=False)
def list_application_verifications_api(
    application_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    app = get_application_by_id(db, application_id)
    if not app:
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    if current_user.role.upper() != "ADMIN":
        student = get_student_by_user(db, current_user.id)
        if not student or app.student_id != student.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied: Cannot view verifications on another student's application",
            )

    result = get_application_verifications(db, application_id)
    return result


@router.post("/verifications/{verification_id}/execute", response_model=VerificationExecutionResponse)
@router.post("/verifications/{verification_id}/execute/", response_model=VerificationExecutionResponse, include_in_schema=False)
def execute_verification_api(
    verification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    verif = get_verification_by_id(db, verification_id)
    if not verif:
        raise HTTPException(
            status_code=404,
            detail="Verification record not found"
        )

    if current_user.role.upper() != "ADMIN":
        student = get_student_by_user(db, current_user.id)
        if not student:
            raise HTTPException(
                status_code=403,
                detail="Access denied: No student profile associated with user",
            )
        app = get_application_by_id(db, verif.application_id)
        if not app or app.student_id != student.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied: Cannot execute verification on another student's application",
            )

    result = execute_verification(db, verification_id)

    if result == "VERIFICATION_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Verification record not found"
        )

    if result == "NOT_PENDING":
        raise HTTPException(
            status_code=409,
            detail="Verification record is not pending"
        )

    if result == "DOCUMENT_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Document not found"
        )

    return result
