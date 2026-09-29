class MockVerificationAdapter:
    """Mock verification adapter implementing conceptual verifyDocument() method for SIH demo.
    
    This is strictly a deterministic test/mock adapter.
    No live DigiLocker, APAAR, UDISE, or government APIs are called.
    
    Supports the following mock document types:
    - TEST_VERIFIED: Simulates successful verification
    - TEST_MISMATCH: Simulates attribute mismatch (routes to manual review)
    - TEST_FAILED: Simulates verification failure
    - TEST_UNAVAILABLE: Simulates external source unavailability (routes to manual review)
    - MOCK_ST_CERTIFICATE: Simulates pending/unverifiable document
    """

    # Adapter source mapping for transparency
    ADAPTER_SOURCES = {
        "MOCK_ST_CERTIFICATE": "DigiLocker / State e-District (MOCK)",
        "TEST_VERIFIED": "NSP / AISHE (MOCK)",
        "TEST_MISMATCH": "UIDAI / APAAR (MOCK)",
        "TEST_FAILED": "SFMP / PFMS (MOCK)",
        "TEST_UNAVAILABLE": "UDISE+ / UGC-NTA (MOCK)",
    }

    @classmethod
    def verify_document(cls, document) -> dict:
        doc_type = getattr(document, "document_type", None)

        if doc_type == "TEST_VERIFIED":
            return {
                "status": "VERIFIED",
                "message": "Mock document successfully verified against simulated issuer registry",
                "evaluation_mode": "MOCK",
                "adapter_source": cls.ADAPTER_SOURCES.get(doc_type, "MOCK"),
            }
        elif doc_type == "TEST_MISMATCH":
            return {
                "status": "MISMATCH",
                "message": "Mock document attributes do not match student records (mismatch simulated). Eligible for manual review.",
                "evaluation_mode": "MOCK",
                "adapter_source": cls.ADAPTER_SOURCES.get(doc_type, "MOCK"),
            }
        elif doc_type == "TEST_FAILED":
            return {
                "status": "FAILED",
                "message": "Mock document verification failed (simulated issuer failure)",
                "evaluation_mode": "MOCK",
                "adapter_source": cls.ADAPTER_SOURCES.get(doc_type, "MOCK"),
            }
        elif doc_type == "TEST_UNAVAILABLE":
            return {
                "status": "MISMATCH",
                "message": "External verification source is unavailable (simulated). Routed to manual review.",
                "evaluation_mode": "MOCK",
                "adapter_source": cls.ADAPTER_SOURCES.get(doc_type, "MOCK"),
                "source_unavailable": True,
            }
        else:
            return {
                "status": "FAILED",
                "message": "Mock adapter has no configured verification rule for this document type",
                "evaluation_mode": "MOCK",
                "adapter_source": "UNKNOWN (MOCK)",
            }
