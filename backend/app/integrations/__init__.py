"""TribalSetu External Integrations & Adapters Package.

This package defines architectural adapter interfaces and deterministic mock adapters
for government, academic, and financial registries.

NOTE: All adapters operate in prototype/evaluation mode returning deterministic simulated data.
No live government APIs are called, and no external credentials are used.
Live integration requires authorized government onboarding and production credentials.
"""

from app.integrations.digilocker import DigiLockerAdapter, MockDigiLockerAdapter
from app.integrations.verification.mock_adapter import MockVerificationAdapter
from app.integrations.nsp import NSPAdapter, MockNSPAdapter
from app.integrations.sfmp import SFMPAdapter, MockSFMPAdapter
from app.integrations.nos import NOSAdapter, MockNOSAdapter
from app.integrations.apaar import APAARAdapter, MockAPAARAdapter
from app.integrations.udise import UDISEAdapter, MockUDISEAdapter
from app.integrations.aishe import AISHEAdapter, MockAISHEAdapter
from app.integrations.uidai import UIDAIAdapter, MockUIDAIAdapter
from app.integrations.state_edistrict import StateEDistrictAdapter, MockStateEDistrictAdapter
from app.integrations.ugc_nta import UGCNTAAdapter, MockUGCNTAAdapter

__all__ = [
    "DigiLockerAdapter",
    "MockDigiLockerAdapter",
    "MockVerificationAdapter",
    "NSPAdapter",
    "MockNSPAdapter",
    "SFMPAdapter",
    "MockSFMPAdapter",
    "NOSAdapter",
    "MockNOSAdapter",
    "APAARAdapter",
    "MockAPAARAdapter",
    "UDISEAdapter",
    "MockUDISEAdapter",
    "AISHEAdapter",
    "MockAISHEAdapter",
    "UIDAIAdapter",
    "MockUIDAIAdapter",
    "StateEDistrictAdapter",
    "MockStateEDistrictAdapter",
    "UGCNTAAdapter",
    "MockUGCNTAAdapter",
]
