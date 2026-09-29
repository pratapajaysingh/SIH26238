import logging
import re
from typing import Any
from sqlalchemy.orm import Session

from app.schemas.jago import JagoMessageRequest, JagoMessageResponse
from app.schemas.eligibility import EligibilityCheckRequest
from app.services.application_service import (
    get_application_status,
    get_application_deficiencies,
    list_student_applications,
)
from app.services.payment_service import get_payment_status
from app.services.eligibility_service import check_eligibility
from app.services.student_service import get_student_by_user
from app.services.jago_llm_service import JagoLLMService
from app.core.scholarship_knowledge import (
    SCHOLARSHIP_SCHEMES_KNOWLEDGE,
    get_scheme_by_code,
    get_all_schemes_summary,
)
from app.seed import DEMO_STUDENT_ID, DEMO_SCHOLARSHIPS

logger = logging.getLogger(__name__)

UUID_REGEX = re.compile(
    r"\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b"
)

DEFAULT_SUGGESTIONS = {
    "en": [
        "Check my application status",
        "Why is my application pending?",
        "What documents are missing?",
        "What is my payment status?",
        "Am I eligible for NFST?",
        "What scholarship schemes are available?",
    ],
    "hi": [
        "मेरे आवेदन की स्थिति जांचें",
        "मेरा आवेदन लंबित क्यों है?",
        "कौन से दस्तावेज़ गायब हैं?",
        "मेरी भुगतान स्थिति क्या है?",
        "क्या मैं पात्र हूँ?",
        "कौन सी छात्रवृत्ति योजनाएं उपलब्ध हैं?",
    ],
}

# Multilingual response templates (Deterministic fallback)
MULTILINGUAL_TEMPLATES = {
    "en": {
        "app_id_required": "Please provide your Application ID so I can look up its status (for example: 'Status of application 00000000-0000-0000-0000-000000000020').",
        "app_not_found": "No application found with ID '{app_id}'. Please check the ID and try again.",
        "app_status": "Your scholarship application ({app_id}) is currently in '{status}' status.",
        "deficiency_none": "Good news! Application {app_id} has no outstanding deficiencies or missing documents.",
        "deficiency_found": "Application {app_id} has {count} deficiency issue(s) that require your attention.",
        "payment_status": "Your DBT payment status is '{status}': {message} (Simulated prototype mode)",
        "payment_id_required": "Please provide your Application ID to check your DBT disbursement and payment status.",
        "student_not_found": "Student record '{student_id}' was not found.",
        "scholarship_not_found": "Scholarship scheme '{scholarship_id}' was not found.",
        "eligible": "Mock Eligibility Result: You appear eligible for this scheme ({reasons}). Note: This is an isolated prototype evaluation.",
        "not_eligible": "Mock Eligibility Result: You do not currently meet the simulated criteria ({reasons}).",
        "unknown": "I'm sorry, I could not determine what action you'd like to take. JAGO can assist with checking your scholarship application status, identifying missing documents or deficiencies, checking DBT payment status, assessing scheme eligibility, and listing required documents.",
        "documents_guidance": "For scheme '{scheme}', you typically need: {doc_list}. Note: Exact requirements depend on official scheme guidelines.",
        "schemes_summary": "TribalSetu supports 5 core Ministry of Tribal Affairs (MoTA) scholarship schemes: {schemes}. Ask about any scheme for detailed eligibility and document requirements.",
        "greeting": "Namaste! I am JAGO, your AI Scholarship Assistant for the Ministry of Tribal Affairs (MoTA). How can I assist with your scholarship journey today?",
    },
    "hi": {
        "app_id_required": "कृपया अपना आवेदन ID प्रदान करें ताकि मैं इसकी स्थिति देख सकूँ।",
        "app_not_found": "ID '{app_id}' वाला कोई आवेदन नहीं मिला। कृपया ID जांचें और पुनः प्रयास करें।",
        "app_status": "आपका छात्रवृत्ति आवेदन ({app_id}) वर्तमान में '{status}' स्थिति में है।",
        "deficiency_none": "शुभ समाचार! आवेदन {app_id} में कोई बकाया कमी या लापता दस्तावेज़ नहीं है।",
        "deficiency_found": "आवेदन {app_id} में {count} कमी मुद्दे हैं जिन पर ध्यान देना आवश्यक है।",
        "payment_status": "आपकी DBT भुगतान स्थिति '{status}' है: {message} (सिमुलेटेड प्रोटोटाइप मोड)",
        "payment_id_required": "अपनी DBT संवितरण और भुगतान स्थिति जांचने के लिए कृपया अपना आवेदन ID प्रदान करें।",
        "student_not_found": "छात्र रिकॉर्ड '{student_id}' नहीं मिला।",
        "scholarship_not_found": "छात्रवृत्ति योजना '{scholarship_id}' नहीं मिली।",
        "eligible": "मॉक पात्रता परिणाम: आप इस योजना के लिए पात्र प्रतीत होते हैं ({reasons})। नोट: यह एक पृथक प्रोटोटाइप मूल्यांकन है।",
        "not_eligible": "मॉक पात्रता परिणाम: आप वर्तमान में सिमुलेटेड मानदंडों को पूरा नहीं करते ({reasons})।",
        "unknown": "मुझे खेद है, मैं यह निर्धारित नहीं कर सका कि आप क्या कार्रवाई करना चाहते हैं। JAGO आपकी छात्रवृत्ति आवेदन स्थिति, लापता दस्तावेज़, DBT भुगतान स्थिति, और पात्रता मूल्यांकन में सहायता कर सकता है।",
        "documents_guidance": "योजना '{scheme}' के लिए, आपको आमतौर पर चाहिए: {doc_list}। नोट: सटीक आवश्यकताएं आधिकारिक योजना दिशानिर्देशों पर निर्भर करती हैं।",
        "schemes_summary": "जनजातीय कार्य मंत्रालय (MoTA) की 5 प्रमुख योजनाएं उपलब्ध हैं: {schemes}। विस्तृत जानकारी के लिए किसी भी योजना के बारे में पूछें।",
        "greeting": "नमस्ते! मैं JAGO हूँ, जनजातीय कार्य मंत्रालय (MoTA) के लिए आपका AI छात्रवृत्ति सहायक। आज मैं आपकी छात्रवृत्ति यात्रा में क्या सहायता कर सकता हूँ?",
    },
}

# Document requirements by scheme (for DOCUMENTS_GUIDANCE intent)
SCHEME_DOCUMENTS = {
    "POST_MATRIC": ["ST Certificate", "Income Certificate", "Marksheet (Previous Year)", "Aadhaar Card", "Bank Passbook", "Bonafide/Enrollment Certificate"],
    "PRE_MATRIC": ["ST Certificate", "Income Certificate", "School Enrollment Certificate", "Aadhaar Card", "Bank Passbook"],
    "NATIONAL_OVERSEAS": ["ST Certificate", "Income Certificate", "Valid Passport", "Unconditional Offer Letter", "Aadhaar Card", "Bank Passbook", "Academic Transcripts"],
    "TOP_CLASS_EDUCATION": ["ST Certificate", "Income Certificate", "Admission Letter (Top Institution)", "Aadhaar Card", "Bank Passbook", "Marksheet"],
    "NATIONAL_FELLOWSHIP_ST": ["ST Certificate", "UGC NET/JRF Certificate", "Research Proposal", "Aadhaar Card", "Bank Passbook", "University Registration Proof"],
}


def _get_lang(request: JagoMessageRequest) -> str:
    """Extract language preference from request context or message script."""
    if request.context and isinstance(request.context, dict):
        lang = request.context.get("language", "en")
        if lang in MULTILINGUAL_TEMPLATES:
            return lang
    if request.message and re.search(r"[\u0900-\u097F]", request.message):
        return "hi"
    return "en"


def _t(lang: str, key: str, **kwargs) -> str:
    """Get translated template string with format arguments."""
    template = MULTILINGUAL_TEMPLATES.get(lang, MULTILINGUAL_TEMPLATES["en"]).get(
        key, MULTILINGUAL_TEMPLATES["en"].get(key, "")
    )
    try:
        return template.format(**kwargs)
    except (KeyError, IndexError):
        return template


def detect_intent(message: str, explicit_intent: str | None = None) -> str:
    """Deterministic, rule-based intent detector for fallback routing.
    
    Can be seamlessly substituted with an LLM or ML classifier in future phases.
    """
    if explicit_intent:
        normalized = explicit_intent.strip().upper()
        if normalized in {
            "APPLICATION_STATUS",
            "APPLICATION_DEFICIENCIES",
            "PAYMENT_STATUS",
            "ELIGIBILITY",
            "DOCUMENTS_GUIDANCE",
            "SCHOLARSHIP_INFO",
            "UNKNOWN",
        }:
            return normalized

    text = message.lower().strip()

    # 1. Deficiencies & document problems check
    deficiency_keywords = [
        "deficienc",
        "missing",
        "missing document",
        "missing doc",
        "issues",
        "issue",
        "problem",
        "what is wrong",
        "mismatch",
        "rejected",
        "defect",
        "fix application",
    ]
    if any(kw in text for kw in deficiency_keywords):
        return "APPLICATION_DEFICIENCIES"

    # 2. Payment & DBT status check (checked before general status)
    payment_keywords = [
        "payment",
        "disburs",
        "dbt",
        "scholarship amount",
        "money",
        "funds",
        "pfms",
        "bank transfer",
        "stipend",
        "paisa",
        "paise",
        "rupaye",
    ]
    if any(kw in text for kw in payment_keywords):
        return "PAYMENT_STATUS"

    # 3. Documents guidance (checked before general status)
    docs_keywords = [
        "document",
        "documents needed",
        "what documents",
        "required documents",
        "documents required",
        "which documents",
        "dastavez",
        "दस्तावेज़",
    ]
    if any(kw in text for kw in docs_keywords):
        return "DOCUMENTS_GUIDANCE"

    # 4. Scholarship Schemes General Knowledge
    scholarship_keywords = [
        "available scholarship",
        "scholarships available",
        "which scholarship",
        "what scholarship",
        "schemes",
        "scholarship schemes",
        "types of scholarship",
        "all scholarships",
        "योजनाएं",
        "छात्रवृत्ति",
    ]
    if any(kw in text for kw in scholarship_keywords):
        return "SCHOLARSHIP_INFO"

    # 5. Application status & tracking
    status_keywords = [
        "status",
        "track",
        "progress",
        "where is my application",
        "check application",
        "application state",
        "stage",
        "स्थिति",
        "स्टेटस",
    ]
    if any(kw in text for kw in status_keywords):
        return "APPLICATION_STATUS"

    # 6. Eligibility assessment
    eligibility_keywords = [
        "eligible",
        "eligibility",
        "qualify",
        "can i apply",
        "am i eligible",
        "scheme criteria",
        "पात्र",
        "पात्रता",
    ]
    if any(kw in text for kw in eligibility_keywords):
        return "ELIGIBILITY"

    # 7. Greeting check
    greeting_keywords = ["hi", "hello", "namaste", "hey", "jago", "namaskar", "kya haal hai", "kaise ho"]
    if text in greeting_keywords or any(text.startswith(g + " ") for g in greeting_keywords) or any(text.endswith(" " + g) for g in greeting_keywords):
        return "GREETING"

    return "UNKNOWN"


def _extract_application_id(
    request: JagoMessageRequest,
    current_user: Any = None,
    db: Session | None = None,
) -> str | None:
    if request.application_id and request.application_id.strip():
        return request.application_id.strip()

    if request.context and isinstance(request.context, dict):
        ctx_app_id = request.context.get("application_id")
        if ctx_app_id and str(ctx_app_id).strip():
            return str(ctx_app_id).strip()

    matches = UUID_REGEX.findall(request.message)
    if matches:
        return matches[0]

    # Contextual user resolution: If authenticated, resolve student's application via approved services
    if current_user and db and hasattr(current_user, "id"):
        student = get_student_by_user(db, current_user.id)
        if student:
            user_apps = list_student_applications(db, student.id)
            if user_apps:
                return user_apps[0].id

    return None


def _extract_student_id(
    request: JagoMessageRequest,
    current_user: Any = None,
    db: Session | None = None,
) -> str:
    if request.student_id and request.student_id.strip():
        return request.student_id.strip()

    if request.context and isinstance(request.context, dict):
        ctx_sid = request.context.get("student_id")
        if ctx_sid and str(ctx_sid).strip():
            return str(ctx_sid).strip()

    # Contextual user resolution: If authenticated, resolve student record via approved service
    if current_user and db and hasattr(current_user, "id"):
        student = get_student_by_user(db, current_user.id)
        if student:
            return student.id

    matches = UUID_REGEX.findall(request.message)
    if len(matches) >= 2:
        return matches[0]

    return DEMO_STUDENT_ID


def _extract_scholarship_id(request: JagoMessageRequest) -> str:
    if request.scholarship_id and request.scholarship_id.strip():
        return request.scholarship_id.strip()

    if request.context and isinstance(request.context, dict):
        ctx_sch = request.context.get("scholarship_id")
        if ctx_sch and str(ctx_sch).strip():
            return str(ctx_sch).strip()

    matches = UUID_REGEX.findall(request.message)
    if len(matches) >= 2:
        return matches[1]

    return DEMO_SCHOLARSHIPS[0]["id"]


def _extract_scheme_code(request: JagoMessageRequest) -> str:
    """Extract scheme code from message for document guidance."""
    text = request.message.lower()
    for scheme_code in SCHEME_DOCUMENTS:
        if scheme_code.lower().replace("_", " ") in text:
            return scheme_code
    # Check common names
    if "nfst" in text or "fellowship" in text:
        return "NATIONAL_FELLOWSHIP_ST"
    if "overseas" in text or "nos" in text:
        return "NATIONAL_OVERSEAS"
    if "top class" in text:
        return "TOP_CLASS_EDUCATION"
    if "pre matric" in text or "pre-matric" in text:
        return "PRE_MATRIC"
    return "POST_MATRIC"


def process_jago_message(
    db: Session,
    conversation_id: str,
    request: JagoMessageRequest,
    current_user: Any = None,
) -> JagoMessageResponse:
    """Orchestrates JAGO interactions with real LLM tool calling and safe fallback.
    
    Architecture:
    1. If GEMINI_API_KEY is configured and no explicit intent override is present,
       invokes JagoLLMService to interpret query, call approved tools, and generate response.
    2. If Gemini is unavailable, unconfigured, or encounters any error,
       gracefully falls back to the deterministic intent engine.
    """
    lang = _get_lang(request)
    student = None
    if current_user and hasattr(current_user, "id"):
        student = get_student_by_user(db, current_user.id)

    # ── 1. REAL LLM ORCHESTRATION LAYER ───────────────────────
    if not request.intent:
        llm_service = JagoLLMService()
        if llm_service.is_configured():
            try:
                llm_result = llm_service.process_message(
                    db=db,
                    conversation_id=conversation_id,
                    user_message=request.message,
                    current_user=current_user,
                    student=student,
                )
                if llm_result and llm_result.get("message"):
                    return JagoMessageResponse(
                        conversation_id=conversation_id,
                        intent=llm_result.get("intent", "GENERAL_INQUIRY"),
                        message=llm_result["message"],
                        data=llm_result.get("data"),
                        source=llm_result.get("source", "gemini_llm_orchestration"),
                        suggestions=DEFAULT_SUGGESTIONS.get(lang, DEFAULT_SUGGESTIONS["en"]),
                        language=lang,
                    )
            except Exception as e:
                logger.warning("LLM orchestration failed, transitioning to deterministic fallback: %s", e)

    # ── 2. DETERMINISTIC FALLBACK PIPELINE ────────────────────
    return _process_jago_message_deterministic(
        db=db,
        conversation_id=conversation_id,
        request=request,
        current_user=current_user,
        lang=lang,
    )


def _process_jago_message_deterministic(
    db: Session,
    conversation_id: str,
    request: JagoMessageRequest,
    current_user: Any = None,
    lang: str = "en",
) -> JagoMessageResponse:
    """Deterministic fallback pipeline using rule-based keyword matching."""
    intent = detect_intent(request.message, request.intent)

    if intent == "APPLICATION_STATUS":
        app_id = _extract_application_id(request, current_user=current_user, db=db)
        if not app_id:
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=_t(lang, "app_id_required"),
                data={"error": "APPLICATION_ID_REQUIRED"},
                source="jago_orchestration",
                suggestions=[DEFAULT_SUGGESTIONS[lang][0]],
                language=lang,
            )

        status_result = get_application_status(db, app_id)
        if status_result == "APPLICATION_NOT_FOUND":
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=_t(lang, "app_not_found", app_id=app_id),
                data={"application_id": app_id, "found": False},
                source="application_service.get_application_status",
                suggestions=DEFAULT_SUGGESTIONS[lang][:2],
                language=lang,
            )

        current_status = status_result.get("status", "UNKNOWN")
        return JagoMessageResponse(
            conversation_id=conversation_id,
            intent=intent,
            message=_t(lang, "app_status", app_id=app_id, status=current_status),
            data=status_result,
            source="application_service.get_application_status",
            suggestions=[
                DEFAULT_SUGGESTIONS[lang][1],
                DEFAULT_SUGGESTIONS[lang][3],
            ],
            language=lang,
        )

    elif intent == "APPLICATION_DEFICIENCIES":
        app_id = _extract_application_id(request, current_user=current_user, db=db)
        if not app_id:
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=_t(lang, "app_id_required"),
                data={"error": "APPLICATION_ID_REQUIRED"},
                source="jago_orchestration",
                suggestions=[DEFAULT_SUGGESTIONS[lang][1]],
                language=lang,
            )

        deficiencies_result = get_application_deficiencies(db, app_id)
        if deficiencies_result == "APPLICATION_NOT_FOUND":
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=_t(lang, "app_not_found", app_id=app_id),
                data={"application_id": app_id, "found": False},
                source="application_service.get_application_deficiencies",
                suggestions=DEFAULT_SUGGESTIONS[lang][:2],
                language=lang,
            )

        count = len(deficiencies_result)
        if count == 0:
            msg = _t(lang, "deficiency_none", app_id=app_id)
        else:
            msg = _t(lang, "deficiency_found", app_id=app_id, count=count)

        return JagoMessageResponse(
            conversation_id=conversation_id,
            intent=intent,
            message=msg,
            data={
                "application_id": app_id,
                "total_deficiencies": count,
                "deficiencies": deficiencies_result,
            },
            source="application_service.get_application_deficiencies",
            suggestions=[
                DEFAULT_SUGGESTIONS[lang][0],
                DEFAULT_SUGGESTIONS[lang][3],
            ],
            language=lang,
        )

    elif intent == "PAYMENT_STATUS":
        app_id = _extract_application_id(request, current_user=current_user, db=db)
        if not app_id:
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=_t(lang, "payment_id_required"),
                data={"error": "APPLICATION_ID_REQUIRED"},
                source="jago_orchestration",
                suggestions=[DEFAULT_SUGGESTIONS[lang][2]],
                language=lang,
            )

        payment_result = get_payment_status(db, app_id)
        if payment_result == "APPLICATION_NOT_FOUND":
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=_t(lang, "app_not_found", app_id=app_id),
                data={"application_id": app_id, "found": False},
                source="payment_service.get_payment_status",
                suggestions=DEFAULT_SUGGESTIONS[lang][:2],
                language=lang,
            )

        pay_status = payment_result.get("status", "UNKNOWN")
        pay_msg = payment_result.get("message", "")
        return JagoMessageResponse(
            conversation_id=conversation_id,
            intent=intent,
            message=_t(lang, "payment_status", status=pay_status, message=pay_msg),
            data=payment_result,
            source="payment_service.get_payment_status",
            suggestions=[
                DEFAULT_SUGGESTIONS[lang][0],
                DEFAULT_SUGGESTIONS[lang][1],
            ],
            language=lang,
        )

    elif intent == "ELIGIBILITY":
        student_id = _extract_student_id(request, current_user=current_user, db=db)
        scholarship_id = _extract_scholarship_id(request)

        eligibility_req = EligibilityCheckRequest(
            student_id=student_id,
            scholarship_id=scholarship_id,
        )
        result = check_eligibility(db, eligibility_req)

        if result == "STUDENT_NOT_FOUND":
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=_t(lang, "student_not_found", student_id=student_id),
                data={"error": "STUDENT_NOT_FOUND"},
                source="eligibility_service.check_eligibility",
                suggestions=DEFAULT_SUGGESTIONS[lang][:2],
                language=lang,
            )

        if result == "SCHOLARSHIP_NOT_FOUND":
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=_t(lang, "scholarship_not_found", scholarship_id=scholarship_id),
                data={"error": "SCHOLARSHIP_NOT_FOUND"},
                source="eligibility_service.check_eligibility",
                suggestions=DEFAULT_SUGGESTIONS[lang][:2],
                language=lang,
            )

        is_eligible = getattr(result, "eligible", False)
        reasons = getattr(result, "reasons", [])
        reasons_text = "; ".join(reasons) if reasons else "Simulated criteria met."

        if is_eligible:
            msg = _t(lang, "eligible", reasons=reasons_text)
        else:
            msg = _t(lang, "not_eligible", reasons=reasons_text)

        return JagoMessageResponse(
            conversation_id=conversation_id,
            intent=intent,
            message=msg,
            data={
                "student_id": student_id,
                "scholarship_id": scholarship_id,
                "eligible": is_eligible,
                "reasons": reasons,
                "evaluation_mode": getattr(result, "evaluation_mode", "MOCK"),
            },
            source="eligibility_service.check_eligibility",
            suggestions=[DEFAULT_SUGGESTIONS[lang][0], DEFAULT_SUGGESTIONS[lang][1]],
            language=lang,
        )

    elif intent == "DOCUMENTS_GUIDANCE":
        scheme_code = _extract_scheme_code(request)
        docs = SCHEME_DOCUMENTS.get(scheme_code, SCHEME_DOCUMENTS["POST_MATRIC"])
        doc_list = ", ".join(docs)

        return JagoMessageResponse(
            conversation_id=conversation_id,
            intent=intent,
            message=_t(lang, "documents_guidance", scheme=scheme_code, doc_list=doc_list),
            data={
                "scheme_code": scheme_code,
                "required_documents": docs,
                "evaluation_mode": "MOCK",
            },
            source="jago_orchestration.documents_guidance",
            suggestions=[DEFAULT_SUGGESTIONS[lang][0], DEFAULT_SUGGESTIONS[lang][3]],
            language=lang,
        )

    elif intent == "SCHOLARSHIP_INFO":
        scheme_code = _extract_scheme_code(request)
        scheme_data = get_scheme_by_code(scheme_code)
        if scheme_data:
            msg = f"{scheme_data['scheme_name']}: {scheme_data['broad_purpose']} Benefit: {scheme_data['benefit_amount']}."
        else:
            all_schemes = ", ".join([s["name"] for s in get_all_schemes_summary()])
            msg = _t(lang, "schemes_summary", schemes=all_schemes)

        return JagoMessageResponse(
            conversation_id=conversation_id,
            intent=intent,
            message=msg,
            data={"scheme_info": scheme_data or get_all_schemes_summary()},
            source="jago_orchestration.scholarship_knowledge",
            suggestions=DEFAULT_SUGGESTIONS[lang][:3],
            language=lang,
        )

    elif intent == "GREETING":
        return JagoMessageResponse(
            conversation_id=conversation_id,
            intent=intent,
            message=_t(lang, "greeting"),
            data={"greeting": True},
            source="jago_rule_engine",
            suggestions=DEFAULT_SUGGESTIONS[lang],
            language=lang,
        )

    # UNKNOWN intent fallback
    return JagoMessageResponse(
        conversation_id=conversation_id,
        intent="UNKNOWN",
        message=_t(lang, "unknown"),
        data=None,
        source="jago_rule_engine",
        suggestions=DEFAULT_SUGGESTIONS[lang],
        language=lang,
    )
