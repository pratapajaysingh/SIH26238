"""Tests for TASK 6 — Multilingual JAGO Prototype."""
from app.seed import DEMO_STUDENT_ID, DEMO_SCHOLARSHIPS, DEMO_APPLICATION_ID


def test_jago_hindi_response(client, seeded_db):
    """JAGO responds in Hindi when language=hi is set in context."""
    response = client.post(
        "/api/v1/jago/conversations/conv-ml-1/messages",
        json={
            "message": "Check my application status",
            "application_id": DEMO_APPLICATION_ID,
            "context": {"language": "hi"},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "APPLICATION_STATUS"
    # Hindi response should contain Hindi text
    assert "छात्रवृत्ति" in data["message"] or "आवेदन" in data["message"]


def test_jago_english_default(client, seeded_db):
    """JAGO defaults to English when no language is specified."""
    response = client.post(
        "/api/v1/jago/conversations/conv-ml-2/messages",
        json={
            "message": "Check my application status",
            "application_id": DEMO_APPLICATION_ID,
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "scholarship application" in data["message"].lower()


def test_jago_hindi_eligibility(client, seeded_db):
    """JAGO eligibility response in Hindi."""
    response = client.post(
        "/api/v1/jago/conversations/conv-ml-3/messages",
        json={
            "message": "Am I eligible?",
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
            "context": {"language": "hi"},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "ELIGIBILITY"
    # Should contain Hindi text
    assert "मॉक" in data["message"] or "पात्रता" in data["message"]


def test_jago_documents_guidance_intent(client, seeded_db):
    """JAGO responds with required documents for a scheme."""
    response = client.post(
        "/api/v1/jago/conversations/conv-ml-4/messages",
        json={"message": "What documents do I need for Post Matric?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "DOCUMENTS_GUIDANCE"
    assert "required_documents" in data["data"]
    assert len(data["data"]["required_documents"]) > 0


def test_jago_hindi_keyword_detection(client, seeded_db):
    """JAGO detects Hindi keywords for intent classification."""
    response = client.post(
        "/api/v1/jago/conversations/conv-ml-5/messages",
        json={
            "message": "मेरी स्थिति बताओ",
            "application_id": DEMO_APPLICATION_ID,
            "context": {"language": "hi"},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "APPLICATION_STATUS"


def test_jago_nfst_documents_guidance(client, seeded_db):
    """JAGO returns NFST-specific documents."""
    response = client.post(
        "/api/v1/jago/conversations/conv-ml-6/messages",
        json={"message": "What documents do I need for NFST fellowship?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "DOCUMENTS_GUIDANCE"
    assert data["data"]["scheme_code"] == "NATIONAL_FELLOWSHIP_ST"
    assert "UGC NET/JRF Certificate" in data["data"]["required_documents"]
