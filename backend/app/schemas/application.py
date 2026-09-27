from datetime import datetime
from pydantic import BaseModel, model_validator


class ApplicationCreate(BaseModel):
    student_id: str
    scholarship_id: str


class ApplicationResponse(BaseModel):
    id: str
    student_id: str
    scholarship_id: str
    status: str

    class Config:
        from_attributes = True


class ApplicationStatusResponse(BaseModel):
    id: str
    status: str

    class Config:
        from_attributes = True


class ApplicationDeficiencyResponse(BaseModel):
    id: str
    application_id: str
    deficiency_type: str
    type: str
    category: str
    document_id: str | None = None
    document_name: str | None = None
    document_type: str | None = None
    verification_id: str | None = None
    status: str
    severity: str
    message: str
    reason: str

    class Config:
        from_attributes = True


class TimelineEventResponse(BaseModel):
    id: str
    application_id: str
    status: str
    message: str | None = None
    created_at: datetime | str
    timestamp: datetime | str | None = None

    class Config:
        from_attributes = True

    @model_validator(mode="after")
    def populate_timestamp(self):
        if not self.timestamp:
            self.timestamp = self.created_at
        return self


class ApplicationStatusTransitionRequest(BaseModel):
    status: str
    message: str | None = None


class ApplicationTransitionResponse(BaseModel):
    id: str
    status: str
    previous_status: str
    message: str | None = None

    class Config:
        from_attributes = True

