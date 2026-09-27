from typing import Any
from pydantic import BaseModel, Field


class JagoMessageContext(BaseModel):
    application_id: str | None = None
    student_id: str | None = None
    scholarship_id: str | None = None


class JagoMessageRequest(BaseModel):
    message: str = Field(..., description="User query or message text")
    intent: str | None = Field(None, description="Optional explicit intent override")
    application_id: str | None = Field(None, description="Optional target application ID")
    student_id: str | None = Field(None, description="Optional target student ID")
    scholarship_id: str | None = Field(None, description="Optional target scholarship scheme ID")
    context: dict[str, Any] | None = Field(None, description="Optional additional context object")


class JagoMessageResponse(BaseModel):
    conversation_id: str
    intent: str
    message: str
    data: Any | None = None
    source: str | None = None
    suggestions: list[str] = Field(default_factory=list)
