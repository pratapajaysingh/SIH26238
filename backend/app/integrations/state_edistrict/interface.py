from abc import ABC, abstractmethod


class StateEDistrictAdapter(ABC):
    """Abstract interface for State e-District Certificate Verification Portals.

    Live integration requires authorized government onboarding and API credentials.
    In prototype/evaluation mode, use MockStateEDistrictAdapter.
    """

    @classmethod
    @abstractmethod
    def verify_certificate(cls, certificate_number: str, state: str, cert_type: str | None = None) -> dict:
        """Verify state-issued caste, income, or residential certificates."""
        pass
