from app.integrations.uidai.interface import UIDAIAdapter


class MockUIDAIAdapter(UIDAIAdapter):
    """Deterministic mock adapter providing simulated UIDAI demographic verification.

    This is strictly a deterministic test/mock adapter.
    No live UIDAI or Aadhaar biometric/OTP APIs are called.
    Live integration requires authorized government onboarding/API credentials.
    """

    @classmethod
    def verify_demographics(cls, aadhaar_ref: str, name: str, dob: str | None = None) -> dict:
        return {
            "system": "UIDAI",
            "aadhaar_ref": aadhaar_ref,
            "status": "VERIFIED",
            "name_match": True,
            "match_score": 100,
            "message": "Simulated Aadhaar demographic validation successful",
            "evaluation_mode": "MOCK",
        }
