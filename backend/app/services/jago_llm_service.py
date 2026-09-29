"""LLM Orchestration Service for JAGO Assistant using Google GenAI SDK (google-genai).

Architecture:
Router -> JAGO Service -> JagoLLMService -> JagoToolSet (Domain Services) -> DB / Knowledge

SECURITY & INTEGRITY:
1. LLM has NO direct access to PostgreSQL or raw SQL execution.
2. LLM can only invoke safe, strongly-typed tools in JagoToolSet.
3. Every student-specific tool operates in the authenticated student context.
4. Hallucinations are strictly forbidden: JAGO never fabricates dates, approval
   guarantees, or payment amounts.
5. If GEMINI_API_KEY is not configured or fails, callers fall back to deterministic JAGO.
"""

import logging
from typing import Any
from collections import OrderedDict
from sqlalchemy.orm import Session

try:
    from google import genai
    from google.genai import types
    GENAI_AVAILABLE = True
except ImportError:
    genai = None  # type: ignore
    types = None  # type: ignore
    GENAI_AVAILABLE = False

from app.core import config
from app.models.user import User
from app.models.student import Student
from app.services.jago_tools import JagoToolSet

logger = logging.getLogger(__name__)

# Bounded conversation memory cache (LRU-style, max 100 conversations, max 20 messages each)
_MAX_CONVERSATIONS = 100
_MAX_HISTORY_PER_CONV = 20
_CONVERSATION_MEMORY: OrderedDict[str, list[Any]] = OrderedDict()

JAGO_SYSTEM_INSTRUCTION = """You are JAGO, the dedicated, friendly, and factual AI Scholarship Assistant for the Ministry of Tribal Affairs (MoTA), Government of India, operating within the TribalSetu platform.

MISSION & ROLE:
- Your mission is to empower Scheduled Tribe (ST) students across India by providing clear, reliable guidance on scholarships, eligibility, document requirements, application status, deficiencies, and DBT payment disbursements.
- You are student-focused, respectful, reassuring, and concise yet comprehensive.

STRICT FACTUALITY & ANTI-HALLUCINATION RULES:
1. NEVER invent or fabricate application statuses, verification outcomes, payment dates, sanction letters, or government decisions.
2. If application or payment information is not returned by the approved tools, clearly inform the student that the information is currently unavailable or requires manual verification, rather than guessing.
3. Official external government workflows (PFMS, DigiLocker, District Verification) in this prototype operate via simulated backend adapters.
4. Distinguish clearly between a student's personal application status and general scheme information.

LANGUAGE CAPABILITY:
- You naturally understand and communicate in English, Hindi (हिंदी), and Hinglish (Hindi written in Latin script, e.g., 'mera status kya hai?').
- Match the user's language and tone:
  * English input -> Natural English response.
  * Hindi input (Devanagari) -> Fluent, polite Hindi response.
  * Hinglish input -> Natural, helpful Hinglish response (e.g., 'Aapka application abhi verification stage me hai...').

AVAILABLE TOOLS:
You have access to safe backend tools:
1. get_my_application_status: Check status of current student's application.
2. get_my_application_timeline: Audit history and verification stages.
3. get_my_application_deficiencies: Missing documents, mismatch remarks, or corrections needed.
4. check_my_eligibility: Evaluate criteria and check multi-scholarship conflict rules (students can avail only one scheme at a time).
5. get_my_payment_status: DBT disbursement and PFMS bank credit status.
6. get_scholarship_information: Official facts on the 5 MoTA schemes (Pre-Matric, Post-Matric, Top Class, NFST, NOS).
7. get_required_documents: Checklists and DigiLocker support for any scheme.
8. get_my_profile_summary: Non-sensitive student profile and registration details.
9. get_my_notifications: Official student notices and alerts.

MULTIPLE TOOLS USAGE:
When a query requires combined information (e.g. 'my application is verified but payment has not arrived', or 'tell me about Top Class and required documents'), call all relevant tools before formulating your complete answer.

TONE:
Supportive, professional, transparent, and encouraging to tribal scholars.
"""


def _get_history(conversation_id: str) -> list[types.Content]:
    """Retrieve bounded message history for a conversation."""
    if conversation_id in _CONVERSATION_MEMORY:
        _CONVERSATION_MEMORY.move_to_end(conversation_id)
        return list(_CONVERSATION_MEMORY[conversation_id])
    return []


def _append_to_history(conversation_id: str, content: types.Content) -> None:
    """Store conversation turn with bounding."""
    if conversation_id not in _CONVERSATION_MEMORY:
        if len(_CONVERSATION_MEMORY) >= _MAX_CONVERSATIONS:
            _CONVERSATION_MEMORY.popitem(last=False)
        _CONVERSATION_MEMORY[conversation_id] = []

    history = _CONVERSATION_MEMORY[conversation_id]
    history.append(content)
    # Trim to max window
    if len(history) > _MAX_HISTORY_PER_CONV:
        _CONVERSATION_MEMORY[conversation_id] = history[-_MAX_HISTORY_PER_CONV:]


def clear_conversation_memory(conversation_id: str | None = None) -> None:
    """Clear memory for testing or reset."""
    if conversation_id:
        _CONVERSATION_MEMORY.pop(conversation_id, None)
    else:
        _CONVERSATION_MEMORY.clear()


class JagoLLMService:
    """Orchestrates conversations with Gemini via the official google-genai SDK."""

    def __init__(self, api_key: str | None = None, model: str | None = None):
        self.api_key = (api_key or config.GEMINI_API_KEY or "").strip()
        self.model_name = (model or config.GEMINI_MODEL or "gemini-2.5-flash").strip()
        self._client: genai.Client | None = None

        if GENAI_AVAILABLE and self.api_key:
            try:
                self._client = genai.Client(api_key=self.api_key)
            except Exception as e:
                logger.warning("Failed to initialize Gemini Client: %s", e)
                self._client = None

    def is_configured(self) -> bool:
        """Checks if a valid Gemini API key is configured."""
        return bool(GENAI_AVAILABLE and self.api_key and self._client is not None)

    def process_message(
        self,
        db: Session,
        conversation_id: str,
        user_message: str,
        current_user: User | None = None,
        student: Student | None = None,
    ) -> dict[str, Any] | None:
        """Processes user message with tools via Gemini and returns response payload.
        
        Returns:
            dict containing answer, tools_called, data, etc., or None if LLM is unavailable/failed.
        """
        if not self.is_configured():
            logger.info("Gemini LLM is not configured (missing GEMINI_API_KEY).")
            return None

        # Instantiate authenticated toolset
        toolset = JagoToolSet(db=db, current_user=current_user, student=student)
        called_tools: list[str] = []

        # Create tool wrappers that record calls for observability
        def wrap_tool(name: str, fn: Any):
            def wrapper(*args: Any, **kwargs: Any) -> Any:
                called_tools.append(name)
                try:
                    return fn(*args, **kwargs)
                except Exception as err:
                    logger.error("Error executing tool %s: %s", name, err)
                    return {"status": "ERROR", "message": f"Error running tool {name}: {str(err)}"}
            wrapper.__name__ = name
            wrapper.__doc__ = fn.__doc__
            return wrapper

        wrapped_tools = [
            wrap_tool(name, fn)
            for name, fn in toolset.get_tools_map().items()
        ]

        # Retrieve prior history
        history = _get_history(conversation_id)

        # Prepare user content
        current_user_content = types.Content(
            role="user",
            parts=[types.Part.from_text(text=user_message)],
        )

        generate_config = types.GenerateContentConfig(
            system_instruction=JAGO_SYSTEM_INSTRUCTION,
            temperature=0.2,
            tools=wrapped_tools,
        )

        try:
            # Build full message payload including prior memory
            contents_payload = list(history) + [current_user_content]

            response = self._client.models.generate_content(
                model=self.model_name,
                contents=contents_payload,
                config=generate_config,
            )

            response_text = response.text or ""

            # Check if tools were executed through automatic function calling
            if hasattr(response, "automatic_function_calling_history") and response.automatic_function_calling_history:
                for hist_turn in response.automatic_function_calling_history:
                    if hasattr(hist_turn, "parts") and hist_turn.parts:
                        for part in hist_turn.parts:
                            if hasattr(part, "function_call") and part.function_call:
                                fn_name = getattr(part.function_call, "name", "")
                                if fn_name and fn_name not in called_tools:
                                    called_tools.append(fn_name)

            # Persist turns into lightweight conversation memory
            _append_to_history(conversation_id, current_user_content)
            model_turn = types.Content(
                role="model",
                parts=[types.Part.from_text(text=response_text)],
            )
            _append_to_history(conversation_id, model_turn)

            # Determine dominant intent for backward compatibility
            dominant_intent = self._derive_intent_from_tools(called_tools, user_message)

            return {
                "message": response_text,
                "tools_called": list(set(called_tools)),
                "intent": dominant_intent,
                "source": "gemini_llm_orchestration" + (f"[{','.join(called_tools)}]" if called_tools else ""),
                "data": {
                    "tools_used": called_tools,
                    "model": self.model_name,
                    "evaluation_mode": "LLM_FUNCTION_CALLING",
                },
            }

        except Exception as e:
            logger.error("Gemini API call failed: %s", e)
            return None

    def _derive_intent_from_tools(self, tools: list[str], message: str) -> str:
        """Maps executed tools back to canonical TribalSetu intents for API compatibility."""
        if "get_my_application_deficiencies" in tools:
            return "APPLICATION_DEFICIENCIES"
        if "get_my_payment_status" in tools:
            return "PAYMENT_STATUS"
        if "check_my_eligibility" in tools:
            return "ELIGIBILITY"
        if "get_required_documents" in tools:
            return "DOCUMENTS_GUIDANCE"
        if "get_my_application_status" in tools or "get_my_application_timeline" in tools:
            return "APPLICATION_STATUS"
        if "get_scholarship_information" in tools:
            return "SCHOLARSHIP_INFO"
        if "get_my_profile_summary" in tools:
            return "PROFILE_SUMMARY"
        if "get_my_notifications" in tools:
            return "NOTIFICATIONS"
        return "GENERAL_INQUIRY"
