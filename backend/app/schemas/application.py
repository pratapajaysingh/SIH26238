from pydantic import BaseModel


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

