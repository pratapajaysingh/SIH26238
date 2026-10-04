from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user
from app.models.user import User
from app.schemas.document import DocumentCreate, DocumentResponse
from app.services.document_service import create_document, list_documents, list_student_documents
from app.services.student_service import get_student_by_user

router = APIRouter(prefix="/documents", tags=["Documents"])


@router.post("", response_model=DocumentResponse)
@router.post("/", response_model=DocumentResponse, include_in_schema=False)
def create_document_api(
    document: DocumentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role.upper() != "ADMIN":
        student = get_student_by_user(db, current_user.id)
        if not student or document.student_id != student.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied: Cannot upload documents for another student",
            )

    result = create_document(db, document)

    if result == "STUDENT_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="Student not found"
        )

    return result


@router.get("", response_model=list[DocumentResponse])
@router.get("/", response_model=list[DocumentResponse], include_in_schema=False)
def list_documents_api(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role.upper() == "ADMIN":
        return list_documents(db)
    student = get_student_by_user(db, current_user.id)
    if not student:
        return []
    return list_student_documents(db, student.id)
