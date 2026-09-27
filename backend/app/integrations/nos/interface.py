from abc import ABC, abstractmethod


class NOSAdapter(ABC):
    """Abstract interface for National Overseas Scholarship (NOS) integration.

    Live integration requires authorized government onboarding and API credentials.
    In prototype/evaluation mode, use MockNOSAdapter.
    """

    @classmethod
    @abstractmethod
    def verify_candidate_clearance(cls, student_id: str, passport_number: str | None = None) -> dict:
        """Verify overseas study eligibility, visa, or acceptance documentation."""
        pass
