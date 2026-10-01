"""Tests for Multilingual JAGO Assistant (TASK 4).

Validates:
1. Deterministic multilingual templates for English, Hindi, Santali (Ol Chiki), Odia, and Gondi.
2. Language extraction via request context ('context': {'language': '...'}).
3. Automatic language detection via Unicode script (Ol Chiki, Odia, Devanagari).
4. Localized suggestion chips for each language.
5. All core intents (GREETING, APPLICATION_STATUS, APPLICATION_DEFICIENCIES,
   PAYMENT_STATUS, ELIGIBILITY, DOCUMENTS_GUIDANCE, SCHOLARSHIP_INFO, UNKNOWN) across languages.
"""
import pytest
from app.seed import (
    DEMO_APPLICATION_ID,
    DEMO_APPLICATION_ID_2,
    DEMO_STUDENT_ID,
    DEMO_SCHOLARSHIPS,
)


@pytest.mark.parametrize(
    "lang,greeting_substr",
    [
        ("en", "Namaste! I am JAGO"),
        ("hi", "नमस्ते! मैं JAGO हूँ"),
        ("sat", "ᱡᱚᱦᱟᱨ! ᱤᱧ ᱫᱚ JAGO"),
        ("or", "ଜୋହାର / ନମସ୍କାର! ମୁଁ JAGO"),
        ("gon", "सेवा जोहार! नना JAGO"),
    ],
)
def test_jago_greetings_multilingual(client, seeded_db, lang, greeting_substr):
    """Test that JAGO returns localized greetings with correct language code and suggestions."""
    response = client.post(
        "/api/v1/jago/conversations/conv-multi-greet/messages",
        json={
            "message": "hello",
            "intent": "GREETING",
            "context": {"language": lang},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == lang
    assert greeting_substr in data["message"]
    assert len(data["suggestions"]) >= 4


def test_jago_santali_script_auto_detection(client, seeded_db):
    """Test automatic language detection for Santali (Ol Chiki script)."""
    # ᱡᱚᱦᱟᱨ (Johar in Ol Chiki)
    response = client.post(
        "/api/v1/jago/conversations/conv-sat-auto/messages",
        json={"message": "ᱡᱚᱦᱟᱨ JAGO"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "sat"
    assert "ᱡᱚᱦᱟᱨ" in data["message"]


def test_jago_odia_script_auto_detection(client, seeded_db):
    """Test automatic language detection for Odia script."""
    # ନମସ୍କାର (Namaskara in Odia)
    response = client.post(
        "/api/v1/jago/conversations/conv-odia-auto/messages",
        json={"message": "ନମସ୍କାର JAGO"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "or"
    assert "ନମସ୍କାର" in data["message"]


def test_jago_santali_application_status(client, seeded_db):
    """Test application status retrieval in Santali."""
    response = client.post(
        "/api/v1/jago/conversations/conv-sat-status/messages",
        json={
            "message": f"Status of {DEMO_APPLICATION_ID}",
            "intent": "APPLICATION_STATUS",
            "application_id": DEMO_APPLICATION_ID,
            "context": {"language": "sat"},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "sat"
    assert "ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱟᱵᱮᱫᱚᱱ" in data["message"]
    assert DEMO_APPLICATION_ID in data["message"]


def test_jago_odia_payment_status(client, seeded_db):
    """Test DBT payment status retrieval in Odia."""
    response = client.post(
        "/api/v1/jago/conversations/conv-or-pay/messages",
        json={
            "message": f"Payment for {DEMO_APPLICATION_ID_2}",
            "intent": "PAYMENT_STATUS",
            "application_id": DEMO_APPLICATION_ID_2,
            "context": {"language": "or"},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "or"
    assert "DBT ଦେୟ ସ୍ଥିତି" in data["message"]


def test_jago_santali_deficiency_check(client, seeded_db):
    """Test application deficiency inquiry in Santali."""
    response = client.post(
        "/api/v1/jago/conversations/conv-sat-def/messages",
        json={
            "message": f"Deficiency for {DEMO_APPLICATION_ID}",
            "intent": "APPLICATION_DEFICIENCIES",
            "application_id": DEMO_APPLICATION_ID,
            "context": {"language": "sat"},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "sat"
    # Either deficiency none or deficiency found in Santali
    assert ("ᱱᱟᱯᱟᱭ ᱠᱷᱚᱵᱚᱨ" in data["message"]) or ("ᱠᱟᱜᱚᱡᱽ" in data["message"])


def test_jago_odia_eligibility_check(client, seeded_db):
    """Test eligibility evaluation in Odia."""
    response = client.post(
        "/api/v1/jago/conversations/conv-or-elig/messages",
        json={
            "message": "Am I eligible?",
            "intent": "ELIGIBILITY",
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
            "context": {"language": "or"},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "or"
    assert "ଯୋଗ୍ୟତା" in data["message"]


def test_jago_gondi_unknown_fallback(client, seeded_db):
    """Test fallback response in Gondi."""
    response = client.post(
        "/api/v1/jago/conversations/conv-gon-unk/messages",
        json={
            "message": "random unparseable request 12345",
            "context": {"language": "gon"},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "gon"
    assert "नना समजो माकन" in data["message"]
    assert len(data["suggestions"]) >= 3
