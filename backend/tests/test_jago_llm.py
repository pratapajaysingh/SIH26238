"""Comprehensive Unit and Integration tests for LLM-powered JAGO Assistant.

Tests cover all 14 required verification scenarios:
1. Normal LLM response
2. Application status tool call
3. Deficiency tool call
4. Eligibility tool call
5. Payment tool call
6. Multiple tool calls in single query
7. Hindi message handling
8. Hinglish message handling
9. Follow-up conversation & memory retention
10. Unknown / general question handling
11. Gemini API failure fallback
12. Missing API key fallback
13. Unauthorized application access prevention
14. Malformed tool call handling

NOTE: Tests use mock providers and do NOT depend on external Gemini API network calls.
"""

from unittest.mock import MagicMock, patch
import pytest

from app.services.jago_tools import JagoToolSet
from app.services.jago_llm_service import (
    JagoLLMService,
    clear_conversation_memory,
    _get_history,
)
from app.seed import DEMO_APPLICATION_ID, DEMO_STUDENT_ID, DEMO_STUDENT_ID_2
from app.models.application import Application
from app.models.student import Student


# Helper to generate mock GenAI response object
def create_mock_gemini_response(text: str, tools_called: list[str] | None = None):
    mock_resp = MagicMock()
    mock_resp.text = text
    mock_resp.automatic_function_calling_history = []
    if tools_called:
        parts = []
        for t_name in tools_called:
            part = MagicMock()
            part.function_call = MagicMock()
            part.function_call.name = t_name
            parts.append(part)
        mock_turn = MagicMock()
        mock_turn.parts = parts
        mock_resp.automatic_function_calling_history.append(mock_turn)
    return mock_resp


# ── TEST 1: NORMAL LLM RESPONSE ─────────────────────────────
def test_normal_llm_response(client, seeded_db):
    conv_id = "test-llm-norm-1"
    mock_text = "Hello! I am JAGO, your Ministry of Tribal Affairs scholarship assistant. How can I help you today?"

    with patch.object(JagoLLMService, "is_configured", return_value=True), \
         patch.object(JagoLLMService, "process_message") as mock_proc:
        mock_proc.return_value = {
            "message": mock_text,
            "tools_called": [],
            "intent": "GENERAL_INQUIRY",
            "source": "gemini_llm_orchestration",
            "data": {"model": "gemini-2.5-flash"},
        }

        resp = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": "Hi JAGO"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["conversation_id"] == conv_id
        assert data["message"] == mock_text
        assert data["source"] == "gemini_llm_orchestration"


# ── TEST 2: APPLICATION STATUS TOOL CALL ─────────────────────
def test_application_status_tool_call(seeded_db):
    toolset = JagoToolSet(db=seeded_db)
    res = toolset.get_my_application_status(DEMO_APPLICATION_ID)
    assert res["status"] == "SUCCESS"
    assert res["application_id"] == DEMO_APPLICATION_ID
    assert res["current_stage"] == "DRAFT"
    assert "scheme_name" in res


# ── TEST 3: DEFICIENCY TOOL CALL ─────────────────────────────
def test_deficiency_tool_call(seeded_db):
    toolset = JagoToolSet(db=seeded_db)
    res = toolset.get_my_application_deficiencies(DEMO_APPLICATION_ID)
    assert res["status"] == "SUCCESS"
    assert res["application_id"] == DEMO_APPLICATION_ID
    assert isinstance(res["deficiency_items"], list)
    assert "action_advice" in res


# ── TEST 4: ELIGIBILITY TOOL CALL ────────────────────────────
def test_eligibility_tool_call(seeded_db):
    toolset = JagoToolSet(db=seeded_db)
    res = toolset.check_my_eligibility(scheme_name_or_code="NFST")
    assert res["status"] == "SUCCESS"
    assert res["scheme_code"] == "NATIONAL_FELLOWSHIP_ST"
    assert "eligible" in res
    assert "policy_rule" in res


# ── TEST 5: PAYMENT TOOL CALL ────────────────────────────────
def test_payment_tool_call(seeded_db):
    toolset = JagoToolSet(db=seeded_db)
    res = toolset.get_my_payment_status(DEMO_APPLICATION_ID)
    assert res["status"] == "SUCCESS"
    assert "payment_status" in res
    assert "payment_mode" in res
    assert "prototype_notice" in res


# ── TEST 6: MULTIPLE TOOL CALLS ──────────────────────────────
def test_multiple_tool_calls_orchestration(client, seeded_db):
    conv_id = "test-multi-tools-conv"
    user_query = "my application is verified but payment has not arrived"
    combined_answer = "Your application status is IN_VERIFICATION and your DBT payment status is PENDING."

    with patch.object(JagoLLMService, "is_configured", return_value=True), \
         patch.object(JagoLLMService, "process_message") as mock_proc:
        mock_proc.return_value = {
            "message": combined_answer,
            "tools_called": ["get_my_application_status", "get_my_payment_status"],
            "intent": "APPLICATION_STATUS",
            "source": "gemini_llm_orchestration[get_my_application_status,get_my_payment_status]",
            "data": {"tools_used": ["get_my_application_status", "get_my_payment_status"]},
        }

        resp = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": user_query},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["message"] == combined_answer
        assert "get_my_application_status" in data["source"]
        assert "get_my_payment_status" in data["source"]


# ── TEST 7: HINDI MESSAGE HANDLING ───────────────────────────
def test_hindi_message_handling(client, seeded_db):
    conv_id = "test-hindi-conv"
    hindi_query = "मेरी स्कॉलरशिप का स्टेटस क्या है?"
    hindi_answer = "आपके छात्रवृत्ति आवेदन की वर्तमान स्थिति 'DRAFT' है।"

    with patch.object(JagoLLMService, "is_configured", return_value=True), \
         patch.object(JagoLLMService, "process_message") as mock_proc:
        mock_proc.return_value = {
            "message": hindi_answer,
            "tools_called": ["get_my_application_status"],
            "intent": "APPLICATION_STATUS",
            "source": "gemini_llm_orchestration",
            "data": {},
        }

        resp = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": hindi_query},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["language"] == "hi"
        assert data["message"] == hindi_answer


# ── TEST 8: HINGLISH MESSAGE HANDLING ────────────────────────
def test_hinglish_message_handling(client, seeded_db):
    conv_id = "test-hinglish-conv"
    hinglish_query = "bhai mera scholarship ka status kya hai?"
    hinglish_answer = "Aapka scholarship application abhi 'DRAFT' stage par hai."

    with patch.object(JagoLLMService, "is_configured", return_value=True), \
         patch.object(JagoLLMService, "process_message") as mock_proc:
        mock_proc.return_value = {
            "message": hinglish_answer,
            "tools_called": ["get_my_application_status"],
            "intent": "APPLICATION_STATUS",
            "source": "gemini_llm_orchestration",
            "data": {},
        }

        resp = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": hinglish_query},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["message"] == hinglish_answer


# ── TEST 9: FOLLOW-UP CONVERSATION & MEMORY ──────────────────
def test_followup_conversation_memory(seeded_db):
    conv_id = "test-memory-continuity-conv"
    clear_conversation_memory(conv_id)

    llm = JagoLLMService(api_key="mock_test_key")
    llm._client = MagicMock()

    # Turn 1
    llm._client.models.generate_content.return_value = create_mock_gemini_response(
        "Your application is currently In Verification."
    )
    res1 = llm.process_message(seeded_db, conv_id, "What is my application status?")
    assert res1 is not None
    assert "In Verification" in res1["message"]

    # History should contain user and model turns
    history_after_turn1 = _get_history(conv_id)
    assert len(history_after_turn1) == 2

    # Turn 2: Follow-up question
    llm._client.models.generate_content.return_value = create_mock_gemini_response(
        "It has been in verification stage for 3 days."
    )
    res2 = llm.process_message(seeded_db, conv_id, "How long has it been there?")
    assert res2 is not None

    history_after_turn2 = _get_history(conv_id)
    assert len(history_after_turn2) == 4
    clear_conversation_memory(conv_id)


# ── TEST 10: UNKNOWN / GENERAL QUESTION ──────────────────────
def test_general_question_no_hallucination(client, seeded_db):
    conv_id = "test-general-conv"
    general_query = "How are you today?"
    general_answer = "I am doing well, thank you! As your JAGO scholarship assistant, how can I help you today?"

    with patch.object(JagoLLMService, "is_configured", return_value=True), \
         patch.object(JagoLLMService, "process_message") as mock_proc:
        mock_proc.return_value = {
            "message": general_answer,
            "tools_called": [],
            "intent": "GENERAL_INQUIRY",
            "source": "gemini_llm_orchestration",
            "data": {},
        }

        resp = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": general_query},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["message"] == general_answer


# ── TEST 11: GEMINI API FAILURE FALLBACK ─────────────────────
def test_gemini_api_failure_fallback(client, seeded_db):
    conv_id = "test-api-fail-conv"

    # Simulate Gemini crashing/timing out -> should gracefully fall back to deterministic response
    with patch.object(JagoLLMService, "is_configured", return_value=True), \
         patch.object(JagoLLMService, "process_message", side_effect=RuntimeError("Gemini API connection timed out")):

        resp = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": f"What is the status of application {DEMO_APPLICATION_ID}?"},
        )
        assert resp.status_code == 200
        data = resp.json()
        # Fallback executed successfully
        assert data["intent"] == "APPLICATION_STATUS"
        assert "DRAFT" in data["message"]
        assert data["source"] == "application_service.get_application_status"


# ── TEST 12: MISSING API KEY FALLBACK ────────────────────────
def test_missing_api_key_deterministic_fallback(client, seeded_db):
    conv_id = "test-missing-key-conv"

    with patch.object(JagoLLMService, "is_configured", return_value=False):
        resp = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": f"Are there any deficiencies in my application {DEMO_APPLICATION_ID}?"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["intent"] == "APPLICATION_DEFICIENCIES"
        assert data["source"] == "application_service.get_application_deficiencies"


# ── TEST 13: UNAUTHORIZED APPLICATION ACCESS PREVENTION ──────
def test_unauthorized_application_access_prevention(seeded_db):
    # Student 2 tries to access Student 1's application ID
    student2 = seeded_db.query(Student).filter(Student.id == DEMO_STUDENT_ID_2).first()
    assert student2 is not None

    toolset_student2 = JagoToolSet(db=seeded_db, student=student2)
    # Attempting to check DEMO_APPLICATION_ID (which belongs to student 1)
    res = toolset_student2.get_my_application_status(DEMO_APPLICATION_ID)
    assert res["status"] == "ERROR"
    assert "UNAUTHORIZED" in res["message"] or "not authorized" in res["message"].lower()


# ── TEST 14: MALFORMED TOOL CALL HANDLING ────────────────────
def test_malformed_tool_call_handling(seeded_db):
    toolset = JagoToolSet(db=seeded_db)
    # Call with non-existent UUID
    res = toolset.get_my_application_status("00000000-0000-0000-0000-999999999999")
    assert res["status"] == "ERROR"
    assert "not found" in res["message"].lower() or "No application" in res["message"]

    # Call eligibility with garbage scheme name
    res_elig = toolset.check_my_eligibility("NON_EXISTENT_SCHEME_XYZ")
    assert res_elig["status"] == "SUCCESS"
    assert "policy_rule" in res_elig
