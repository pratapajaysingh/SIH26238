from abc import ABC, abstractmethod


class UGCNTAAdapter(ABC):
    """Abstract interface for UGC / National Testing Agency (NTA) exam score validation.

    Live integration requires authorized government onboarding and API credentials.
    In prototype/evaluation mode, use MockUGCNTAAdapter.
    """

    @classmethod
    @abstractmethod
    def verify_exam_score(cls, application_number: str, exam_name: str) -> dict:
        """Validate entrance examination percentile or score."""
        pass
