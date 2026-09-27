from app.integrations.ugc_nta.interface import UGCNTAAdapter


class MockUGCNTAAdapter(UGCNTAAdapter):
    """Deterministic mock adapter providing simulated UGC/NTA exam score verification.

    This is strictly a deterministic test/mock adapter.
    No live UGC/NTA examination server APIs are called.
    Live integration requires authorized government onboarding/API credentials.
    """

    @classmethod
    def verify_exam_score(cls, application_number: str, exam_name: str) -> dict:
        return {
            "system": "UGC_NTA",
            "application_number": application_number,
            "exam_name": exam_name,
            "status": "VERIFIED",
            "percentile": 96.5,
            "qualified": True,
            "message": "Simulated UGC/NTA entrance score verified",
            "evaluation_mode": "MOCK",
        }
