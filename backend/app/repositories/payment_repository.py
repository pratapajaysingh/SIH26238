from sqlalchemy.orm import Session
from app.repositories.application_repository import get_application_by_id


def get_payment_record_by_application_id(db: Session, application_id: str):
    """Retrieve application record for payment status determination.
    
    Adheres to Router -> Service -> Repository architecture.
    """
    return get_application_by_id(db, application_id)
