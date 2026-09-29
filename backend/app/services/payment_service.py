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
    ref_id = f"DBT-MOCK-{application.id[:8].upper()}"

    if app_status == "COMPLETED":
        return {
            "application_id": application.id,
            "status": "SUCCESS",
            "dbt_status": "CREDITED",
            "message": "Scholarship funds of ₹31,000 successfully disbursed and credited to Aadhaar-seeded bank account via PFMS DBT.",
            "amount": "₹31,000",
            "transaction_id": f"PFMS-{application.id[:8].upper()}-CREDITED",
            "initiated_date": "2026-09-22",
            "processed_date": "2026-09-24",
            "credited_date": "2026-09-25",
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": ref_id,
            "evaluation_mode": "MOCK",
        }
    elif app_status in ["SANCTIONED", "PAYMENT_INITIATED", "DBT_SENT"]:
        return {
            "application_id": application.id,
            "status": "PROCESSING",
            "dbt_status": "PAYMENT_INITIATED" if app_status == "SANCTIONED" else app_status,
            "message": "Scholarship sanctioned. Direct Benefit Transfer (DBT) payment order generated via PFMS gateway.",
            "amount": "₹6,000",
            "transaction_id": f"PFMS-{application.id[:8].upper()}-IN-TRANSIT",
            "initiated_date": "2026-09-23",
            "processed_date": "2026-09-24",
            "credited_date": None,
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": ref_id,
            "evaluation_mode": "MOCK",
        }
    elif app_status in ["IN_VERIFICATION", "MANUAL_REVIEW"]:
        return {
            "application_id": application.id,
            "status": "PENDING",
            "dbt_status": "AWAITING_SANCTION",
            "message": "Application is undergoing nodal verification. Payment initiation is pending scheme approval.",
            "amount": "Pending Calculation",
            "transaction_id": None,
            "initiated_date": None,
            "processed_date": None,
            "credited_date": None,
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": None,
            "evaluation_mode": "MOCK",
        }
    elif app_status in ["REJECTED", "WITHDRAWN"]:
        return {
            "application_id": application.id,
            "status": "FAILED",
            "dbt_status": "CANCELLED",
            "message": f"Payment processing cannot proceed because application is {app_status}.",
            "amount": "₹0",
            "transaction_id": None,
            "initiated_date": None,
            "processed_date": None,
            "credited_date": None,
            "failure_reason": f"Application terminated in {app_status} state",
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": None,
            "evaluation_mode": "MOCK",
        }
    elif app_status == "DEFICIENCY":
        return {
            "application_id": application.id,
            "status": "NOT_INITIATED",
            "dbt_status": "ON_HOLD",
            "message": "Payment paused: Application flagged for document deficiency. Please upload required corrections.",
            "amount": "Pending Resolution",
            "transaction_id": None,
            "initiated_date": None,
            "processed_date": None,
            "credited_date": None,
            "failure_reason": "Outstanding document deficiency requires student correction",
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": None,
            "evaluation_mode": "MOCK",
        }
    else:  # DRAFT, SUBMITTED, etc.
        return {
            "application_id": application.id,
            "status": "NOT_INITIATED",
            "dbt_status": "NOT_INITIATED",
            "message": "Payment has not been initiated. Application must be verified and sanctioned before disbursement.",
            "amount": "Pending Verification",
            "transaction_id": None,
            "initiated_date": None,
            "processed_date": None,
            "credited_date": None,
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": None,
            "evaluation_mode": "MOCK",
        }

