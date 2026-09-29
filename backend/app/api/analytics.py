"""Analytics API Router — Ministry-side visibility and unreached beneficiary identification.

PROTOTYPE: Uses mock/demo data. No real UDISE+, APAAR, or OTR APIs are called.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.services.unreached_service import (
    identify_unreached_beneficiaries,
    get_unreached_only,
    get_unreached_summary,
)
from app.services.analytics_service import get_dashboard_analytics

router = APIRouter(prefix="/analytics", tags=["Analytics (Prototype)"])


@router.get("/unreached-beneficiaries")
@router.get("/unreached-beneficiaries/", include_in_schema=False)
def get_unreached_beneficiaries_api():
    """Identify ST students who are enrolled but not receiving scholarship benefits.
    
    PROTOTYPE: Uses mock UDISE+/APAAR/OTR data. No real government APIs are called.
    """
    return {
        "results": get_unreached_only(),
        "summary": get_unreached_summary(),
        "data_source": "MOCK_PROTOTYPE",
    }


@router.get("/unreached-beneficiaries/all")
@router.get("/unreached-beneficiaries/all/", include_in_schema=False)
def get_all_beneficiary_matching_api():
    """Full matching results for all enrolled students (matched + unreached).
    
    PROTOTYPE: Uses mock UDISE+/APAAR/OTR data. No real government APIs are called.
    """
    return {
        "results": identify_unreached_beneficiaries(),
        "summary": get_unreached_summary(),
        "data_source": "MOCK_PROTOTYPE",
    }


@router.get("/dashboard")
@router.get("/dashboard/", include_in_schema=False)
def get_dashboard_analytics_api(db: Session = Depends(get_db)):
    """Ministry-side dashboard analytics.
    
    Provides scheme-wise application counts, sanctions, payments, deficiency,
    verification/manual-review counts, and unreached beneficiary summary.
    
    PROTOTYPE: Uses mock/demo data.
    """
    return get_dashboard_analytics(db)
