from pydantic import BaseModel


class ScholarshipResponse(BaseModel):
    id: str
    code: str
    name: str
    description: str | None = None
    ministry: str | None = None
    benefit_amount: str | None = None
    education_level: str | None = None
    source: str = "Ministry of Tribal Affairs"
    last_updated: str = "2026-04-01"
    structured_benefits: dict | None = None

    class Config:
        from_attributes = True

