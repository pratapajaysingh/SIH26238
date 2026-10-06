from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user
from app.models.user import User
from app.schemas.student import StudentCreate, StudentResponse
from app.services.student_service import (
    add_student,
    list_students,
    get_student_by_user,
)

router = APIRouter(prefix="/students", tags=["Students"])


@router.post("", response_model=StudentResponse)
@router.post("/", response_model=StudentResponse, include_in_schema=False)
def add_student_api(
    student: StudentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    existing_student = get_student_by_user(db, current_user.id)
    if existing_student:
        raise HTTPException(
            status_code=409,
            detail="Student profile already exists for this user"
        )

    # Always set user_id = current_user.id, ignore any user_id in the payload
    student.user_id = current_user.id
    result = add_student(db, student)

    if result == "USER_NOT_FOUND":
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    if result == "STUDENT_ALREADY_EXISTS":
        raise HTTPException(
            status_code=409,
            detail="Student profile already exists for this user"
        )

    if result == "EMAIL_ALREADY_EXISTS":
        raise HTTPException(
            status_code=409,
            detail="Email already registered for another student"
        )

    return result


@router.get("", response_model=list[StudentResponse])
@router.get("/", response_model=list[StudentResponse], include_in_schema=False)
def list_students_api(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role.upper() != "ADMIN":
        raise HTTPException(
            status_code=403,
            detail="Access denied: Admin role required to view all students",
        )
    return list_students(db)


@router.get("/me", response_model=StudentResponse)
@router.get("/me/", response_model=StudentResponse, include_in_schema=False)
def get_current_student_api(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve the student profile belonging to the currently authenticated user."""
    student = get_student_by_user(db, current_user.id)
    if not student:
        raise HTTPException(
            status_code=404,
            detail="Student profile not found for authenticated user",
        )
    return student