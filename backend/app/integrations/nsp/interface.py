from abc import ABC, abstractmethod


class NSPAdapter(ABC):
    """Abstract interface for National Scholarship Portal (NSP) integration.

    Live integration requires authorized government onboarding and API credentials.
    In prototype/evaluation mode, use MockNSPAdapter.
    """

    @classmethod
    @abstractmethod
    def check_scheme_status(cls, application_id: str) -> dict:
        """Query scholarship status on NSP portal."""
        pass
