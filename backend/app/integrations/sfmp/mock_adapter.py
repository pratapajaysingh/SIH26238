from app.integrations.sfmp.interface import SFMPAdapter


class MockSFMPAdapter(SFMPAdapter):
    """Deterministic mock adapter providing simulated SFMP/PFMS DBT status.

    This is strictly a deterministic test/mock adapter.
    No live banking or government payment gateways are called.
    Live integration requires authorized government onboarding/API credentials.
    """

    @classmethod
    def get_disbursement_status(cls, application_id: str) -> dict:
        return {
            "system": "SFMP/PFMS",
            "application_id": application_id,
            "status": "PENDING_BENEFICIARY_VALIDATION",
            "disbursement_mode": "DIRECT_BENEFIT_TRANSFER",
            "payment_reference": None,
            "message": "Simulated PFMS beneficiary pre-validation check",
            "evaluation_mode": "MOCK",
        }
