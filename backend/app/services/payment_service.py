from sqlalchemy.orm import Session
from app.repositories.payment_repository import get_payment_record_by_application_id


def get_payment_status(db: Session, application_id: str):
    """Retrieve synthetic/mock payment and DBT disbursement status for an application.
    
    Provides simulated DBT gateway status. Never calls real PFMS/bank APIs
    and never exposes sensitive bank or financial identifiers.
    """
    application = get_payment_record_by_application_id(db, application_id)
    if not application:
        return "APPLICATION_NOT_FOUND"

    app_status = getattr(application, "status", "DRAFT")

    if app_status == "COMPLETED":
        return {
            "application_id": application.id,
            "status": "SUCCESS",
            "message": "Scholarship funds successfully disbursed via simulated DBT payment gateway.",
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": f"DBT-MOCK-{application.id[:8].upper()}",
            "evaluation_mode": "MOCK",
        }
    elif app_status == "SANCTIONED":
        return {
            "application_id": application.id,
            "status": "PROCESSING",
            "message": "Scholarship sanctioned. DBT disbursement is currently processing via simulated payment gateway.",
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": f"DBT-MOCK-{application.id[:8].upper()}",
            "evaluation_mode": "MOCK",
        }
    elif app_status == "IN_VERIFICATION":
        return {
            "application_id": application.id,
            "status": "PENDING",
            "message": "Application is undergoing verification. Payment initiation is pending scheme approval.",
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": None,
            "evaluation_mode": "MOCK",
        }
    elif app_status in ["REJECTED", "WITHDRAWN"]:
        return {
            "application_id": application.id,
            "status": "FAILED",
            "message": f"Payment processing cannot proceed because application is {app_status}.",
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": None,
            "evaluation_mode": "MOCK",
        }
    else:  # DRAFT, SUBMITTED, DEFICIENCY, etc.
        return {
            "application_id": application.id,
            "status": "NOT_INITIATED",
            "message": "Payment has not been initiated. Application must be verified and sanctioned before disbursement.",
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": None,
            "evaluation_mode": "MOCK",
        }
