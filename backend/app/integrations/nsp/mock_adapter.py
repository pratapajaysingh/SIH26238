from app.integrations.nsp.interface import NSPAdapter


class MockNSPAdapter(NSPAdapter):
    """Deterministic mock adapter providing simulated NSP portal responses.

    This is strictly a deterministic test/mock adapter.
    No live government APIs are called.
    Live integration requires authorized government onboarding/API credentials.
    """

    @classmethod
    def check_scheme_status(cls, application_id: str) -> dict:
        return {
            "portal": "NSP",
            "application_id": application_id,
            "status": "REGISTERED",
            "message": "Simulated NSP portal scheme application record found",
            "evaluation_mode": "MOCK",
        }
