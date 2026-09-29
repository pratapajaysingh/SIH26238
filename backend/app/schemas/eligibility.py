from pydantic import BaseModel


class EligibilityCheckRequest(BaseModel):
    student_id: str
    scholarship_id: str


class EligibilityCheckResponse(BaseModel):
    student_id: str
    scholarship_id: str
    eligible: bool
    reasons: list[str]
    evaluation_mode: str


class ConflictCheckResponse(BaseModel):
    """Structured eligibility/conflict check response per SIH requirements.
    
    Checks whether a student can apply for a new scheme given their
    existing active applications and sanctioned scholarships.
    """
    student_id: str
    scholarship_id: str
    eligible: bool
    status: str  # ELIGIBLE, ACTIVE_APPLICATION_EXISTS, SANCTIONED_SCHEME_CONFLICT, DUPLICATE_APPLICATION, PENDING_DEFICIENCY, REQUIRES_MANUAL_REVIEW
    reasons: list[str]
    existing_application_id: str | None = None
    existing_scheme_code: str | None = None
    evaluation_mode: str = "MOCK"
