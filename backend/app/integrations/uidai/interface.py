from abc import ABC, abstractmethod


class UIDAIAdapter(ABC):
    """Abstract interface for Unique Identification Authority of India (UIDAI) verification.

    Live integration requires authorized government onboarding and API credentials.
    In prototype/evaluation mode, use MockUIDAIAdapter.
    """

    @classmethod
    @abstractmethod
    def verify_demographics(cls, aadhaar_ref: str, name: str, dob: str | None = None) -> dict:
        """Verify student identity demographics against simulated Aadhaar vault."""
        pass
