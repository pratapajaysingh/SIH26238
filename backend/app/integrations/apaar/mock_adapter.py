from app.integrations.apaar.interface import APAARAdapter


class MockAPAARAdapter(APAARAdapter):
    """Deterministic mock adapter providing simulated APAAR academic records.

    This is strictly a deterministic test/mock adapter.
    No live APAAR or Ministry of Education APIs are called.
    Live integration requires authorized government onboarding/API credentials.
    """

    @classmethod
    def fetch_academic_record(cls, apaar_id: str) -> dict:
        return {
            "system": "APAAR",
            "apaar_id": apaar_id,
            "status": "VERIFIED",
            "academic_level": "HIGHER_SECONDARY",
            "credits_earned": 64,
            "institution": "Simulated Eklavya Model Residential School",
            "evaluation_mode": "MOCK",
        }
