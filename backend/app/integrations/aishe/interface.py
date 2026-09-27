from abc import ABC, abstractmethod


class AISHEAdapter(ABC):
    """Abstract interface for All India Survey on Higher Education (AISHE).

    Live integration requires authorized government onboarding and API credentials.
    In prototype/evaluation mode, use MockAISHEAdapter.
    """

    @classmethod
    @abstractmethod
    def verify_institution(cls, aishe_code: str) -> dict:
        """Validate higher education institution recognition."""
        pass
