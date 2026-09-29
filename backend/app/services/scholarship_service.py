from sqlalchemy.orm import Session
from app.repositories.scholarship_repository import get_scholarships, get_scholarship_by_id
from app.core.scholarship_knowledge import get_scheme_by_code


def list_scholarships(db: Session):
    return get_scholarships(db)


def get_scholarship_details(db: Session, scholarship_id: str):
    scholarship = get_scholarship_by_id(db, scholarship_id)
    if not scholarship:
        return None

    # Attach structured benefits from official MoTA scheme knowledge if available
    scheme_knowledge = get_scheme_by_code(scholarship.code)
    structured_benefits = scheme_knowledge.get("structured_benefits") if scheme_knowledge else None

    return {
        "id": scholarship.id,
        "code": scholarship.code,
        "name": scholarship.name,
        "description": scholarship.description,
        "ministry": scholarship.ministry or "Ministry of Tribal Affairs",
        "benefit_amount": scholarship.benefit_amount,
        "education_level": scholarship.education_level,
        "source": scheme_knowledge.get("source", "Ministry of Tribal Affairs") if scheme_knowledge else "Ministry of Tribal Affairs",
        "last_updated": scheme_knowledge.get("last_updated", "2026-04-01") if scheme_knowledge else "2026-04-01",
        "structured_benefits": structured_benefits,
    }

