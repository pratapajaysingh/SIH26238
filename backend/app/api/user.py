from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.user import UserResponse


router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserResponse)
@router.get("/me/", response_model=UserResponse, include_in_schema=False)
def get_current_user_api(
    current_user: User = Depends(get_current_user),
):
    """Retrieve profile of the currently authenticated user."""
    return current_user