from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.schemas.scholarship import ScholarshipResponse
from app.services.scholarship_service import list_scholarships, get_scholarship_details

router = APIRouter(prefix="/scholarships", tags=["Scholarships"])


@router.get("", response_model=list[ScholarshipResponse])
@router.get("/", response_model=list[ScholarshipResponse], include_in_schema=False)
def list_scholarships_api(db: Session = Depends(get_db)):
    return list_scholarships(db)


@router.get("/{scholarship_id}", response_model=ScholarshipResponse)
@router.get("/{scholarship_id}/", response_model=ScholarshipResponse, include_in_schema=False)
def get_scholarship_api(scholarship_id: str, db: Session = Depends(get_db)):
    details = get_scholarship_details(db, scholarship_id)
    if not details:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Scholarship scheme '{scholarship_id}' not found",
        )
    return details

