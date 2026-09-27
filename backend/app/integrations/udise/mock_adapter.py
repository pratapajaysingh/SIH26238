from app.integrations.udise.interface import UDISEAdapter


class MockUDISEAdapter(UDISEAdapter):
    """Deterministic mock adapter providing simulated UDISE+ school verification.

    This is strictly a deterministic test/mock adapter.
    No live UDISE+ government portal APIs are called.
    Live integration requires authorized government onboarding/API credentials.
    """

    @classmethod
    def verify_school(cls, udise_code: str) -> dict:
        return {
            "system": "UDISE+",
            "udise_code": udise_code,
            "status": "VERIFIED",
            "school_name": "Simulated Eklavya Model Residential School",
            "category": "TRIBAL_WELFARE_RESIDENTIAL",
            "state": "Simulated State",
            "evaluation_mode": "MOCK",
        }
