from app.integrations.nos.interface import NOSAdapter


class MockNOSAdapter(NOSAdapter):
    """Deterministic mock adapter providing simulated NOS clearances.

    This is strictly a deterministic test/mock adapter.
    No live Ministry of Tribal Affairs NOS portal APIs are called.
    Live integration requires authorized government onboarding/API credentials.
    """

    @classmethod
    def verify_candidate_clearance(cls, student_id: str, passport_number: str | None = None) -> dict:
        return {
            "system": "NOS",
            "student_id": student_id,
            "passport_number": passport_number,
            "status": "VERIFIED",
            "message": "Simulated overseas university admission and visa clearance verified",
            "evaluation_mode": "MOCK",
        }
