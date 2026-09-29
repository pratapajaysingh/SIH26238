"""Ministry Analytics Service (PROTOTYPE).

Provides lightweight analytics for Ministry-side visibility on scheme-wise
applications, sanctions, payments, deficiencies, verifications, and unreached
beneficiaries.

Uses existing repository/service architecture. Mock/demo data where required.
"""

from sqlalchemy.orm import Session
from app.models.application import Application
from app.models.verification_record import VerificationRecord
from app.models.manual_review import ManualReview
from app.models.notification import Notification
from app.services.unreached_service import get_unreached_summary


def get_dashboard_analytics(db: Session) -> dict:
    """Aggregate analytics across all scholarship schemes for Ministry dashboard."""

    # Scheme-wise application counts
    all_apps = db.query(Application).all()
    scheme_counts: dict[str, dict] = {}
    total_apps = 0
    total_sanctioned = 0
    total_completed = 0
    total_rejected = 0
    total_deficiency = 0

    for app in all_apps:
        total_apps += 1
        sid = app.scholarship_id
        if sid not in scheme_counts:
            scheme_counts[sid] = {
                "scholarship_id": sid,
                "total": 0,
                "draft": 0,
                "submitted": 0,
                "in_verification": 0,
                "deficiency": 0,
                "sanctioned": 0,
                "rejected": 0,
                "withdrawn": 0,
                "completed": 0,
            }
        scheme_counts[sid]["total"] += 1
        status_key = app.status.lower().replace(" ", "_") if app.status else "draft"
        if status_key in scheme_counts[sid]:
            scheme_counts[sid][status_key] += 1

        if app.status == "SANCTIONED":
            total_sanctioned += 1
        elif app.status == "COMPLETED":
            total_completed += 1
        elif app.status == "REJECTED":
            total_rejected += 1
        elif app.status == "DEFICIENCY":
            total_deficiency += 1

    # Verification and manual review counts
    total_verifications = db.query(VerificationRecord).count()
    pending_verifications = db.query(VerificationRecord).filter(
        VerificationRecord.status == "PENDING"
    ).count()
    manual_reviews = db.query(ManualReview).count()
    open_reviews = db.query(ManualReview).filter(ManualReview.status == "OPEN").count()

    # Payment/disbursement: sanctioned + completed = processed
    payment_summary = {
        "total_sanctioned": total_sanctioned,
        "total_completed": total_completed,
        "total_disbursement_eligible": total_sanctioned + total_completed,
        "evaluation_mode": "MOCK",
    }

    # Unreached beneficiary prototype summary
    unreached_summary = get_unreached_summary()

    return {
        "total_applications": total_apps,
        "total_sanctioned": total_sanctioned,
        "total_completed": total_completed,
        "total_rejected": total_rejected,
        "total_deficiency": total_deficiency,
        "scheme_wise_applications": list(scheme_counts.values()),
        "verification_summary": {
            "total": total_verifications,
            "pending": pending_verifications,
        },
        "manual_review_summary": {
            "total": manual_reviews,
            "open": open_reviews,
        },
        "payment_summary": payment_summary,
        "unreached_beneficiary_summary": unreached_summary,
        "data_source": "MOCK_PROTOTYPE",
    }
