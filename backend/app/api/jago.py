from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user_optional, get_db
from app.models.user import User
from app.schemas.jago import JagoMessageRequest, JagoMessageResponse
from app.services.jago_service import process_jago_message

router = APIRouter(prefix="/jago", tags=["JAGO Assistant"])


@router.post(
    "/conversations/{conversation_id}/messages",
    response_model=JagoMessageResponse,
)
@router.post(
    "/conversations/{conversation_id}/messages/",
    response_model=JagoMessageResponse,
    include_in_schema=False,
)
def send_jago_message_api(
    conversation_id: str,
    payload: JagoMessageRequest,
    current_user: User | None = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    """JAGO Assistant conversation endpoint.
    
    Accepts user inquiries and orchestrates responses via approved core services.
    Automatically resolves authenticated student context when a Bearer token is provided.
    """
    return process_jago_message(db, conversation_id, payload, current_user=current_user)

