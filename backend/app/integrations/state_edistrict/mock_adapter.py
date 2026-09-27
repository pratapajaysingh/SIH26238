from app.integrations.state_edistrict.interface import StateEDistrictAdapter


class MockStateEDistrictAdapter(StateEDistrictAdapter):
    """Deterministic mock adapter providing simulated state certificate verification.

    This is strictly a deterministic test/mock adapter.
    No live State e-District or land/revenue portal APIs are called.
    Live integration requires authorized government onboarding/API credentials.
    """

    @classmethod
    def verify_certificate(cls, certificate_number: str, state: str, cert_type: str | None = None) -> dict:
        return {
            "system": "STATE_E_DISTRICT",
            "state": state,
            "certificate_number": certificate_number,
            "certificate_type": cert_type or "COMMUNITY_CERTIFICATE",
            "status": "VERIFIED",
            "issuing_authority": f"Tehsildar Office, District HQ ({state})",
            "message": "Simulated state e-District certificate record verified",
            "evaluation_mode": "MOCK",
        }
