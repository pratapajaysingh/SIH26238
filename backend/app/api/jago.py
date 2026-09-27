from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
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
    db: Session = Depends(get_db),
):
    """JAGO Assistant conversation endpoint.
    
    Accepts user inquiries and orchestrates responses via approved core services.
    """
    return process_jago_message(db, conversation_id, payload)
