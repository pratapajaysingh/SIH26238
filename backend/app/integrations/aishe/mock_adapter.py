from app.integrations.aishe.interface import AISHEAdapter


class MockAISHEAdapter(AISHEAdapter):
    """Deterministic mock adapter providing simulated AISHE institution verification.

    This is strictly a deterministic test/mock adapter.
    No live AISHE portal APIs are called.
    Live integration requires authorized government onboarding/API credentials.
    """

    @classmethod
    def verify_institution(cls, aishe_code: str) -> dict:
        return {
            "system": "AISHE",
            "aishe_code": aishe_code,
            "status": "VERIFIED",
            "institution_name": "Simulated National Institute of Technology",
            "institution_type": "CENTRAL_INSTITUTION",
            "evaluation_mode": "MOCK",
        }
