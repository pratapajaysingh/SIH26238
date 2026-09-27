from abc import ABC, abstractmethod


class APAARAdapter(ABC):
    """Abstract interface for Automated Permanent Academic Account Registry (APAAR / ABC ID).

    Live integration requires authorized government onboarding and API credentials.
    In prototype/evaluation mode, use MockAPAARAdapter.
    """

    @classmethod
    @abstractmethod
    def fetch_academic_record(cls, apaar_id: str) -> dict:
        """Fetch verified student enrollment and academic credits."""
        pass
