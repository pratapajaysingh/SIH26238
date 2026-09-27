from abc import ABC, abstractmethod


class UDISEAdapter(ABC):
    """Abstract interface for Unified District Information System for Education Plus (UDISE+).

    Live integration requires authorized government onboarding and API credentials.
    In prototype/evaluation mode, use MockUDISEAdapter.
    """

    @classmethod
    @abstractmethod
    def verify_school(cls, udise_code: str) -> dict:
        """Validate school accreditation and basic registry info."""
        pass
