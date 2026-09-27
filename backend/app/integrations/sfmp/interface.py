from abc import ABC, abstractmethod


class SFMPAdapter(ABC):
    """Abstract interface for Scholarship Fund Management Platform (SFMP / PFMS).

    Live integration requires authorized government onboarding and API credentials.
    In prototype/evaluation mode, use MockSFMPAdapter.
    """

    @classmethod
    @abstractmethod
    def get_disbursement_status(cls, application_id: str) -> dict:
        """Fetch DBT disbursement and fund transfer status."""
        pass
