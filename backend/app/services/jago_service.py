import re
from typing import Any
from sqlalchemy.orm import Session

from app.schemas.jago import JagoMessageRequest, JagoMessageResponse
from app.schemas.eligibility import EligibilityCheckRequest
from app.services.application_service import (
    get_application_status,
    get_application_deficiencies,
)
from app.services.payment_service import get_payment_status
from app.services.eligibility_service import check_eligibility
from app.models.user import User
from app.models.student import Student
from app.models.application import Application
from app.seed import DEMO_STUDENT_ID, DEMO_SCHOLARSHIPS

UUID_REGEX = re.compile(
    r"\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b"
)

DEFAULT_SUGGESTIONS = [
    "Check my application status",
    "What documents are missing?",
    "What is my payment status?",
    "Am I eligible?",
]


def detect_intent(message: str, explicit_intent: str | None = None) -> str:
    """Deterministic, rule-based intent detector for the JAGO assistant prototype.
    
    Can be seamlessly substituted with an LLM or ML classifier in future phases.
    """
    if explicit_intent:
        normalized = explicit_intent.strip().upper()
        if normalized in {
            "APPLICATION_STATUS",
            "APPLICATION_DEFICIENCIES",
            "PAYMENT_STATUS",
            "ELIGIBILITY",
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
    ]
    if any(kw in text for kw in payment_keywords):
        return "PAYMENT_STATUS"

    # 3. Application status & tracking
    status_keywords = [
        "status",
        "track",
        "progress",
        "where is my application",
        "check application",
        "application state",
        "stage",
    ]
    if any(kw in text for kw in status_keywords):
        return "APPLICATION_STATUS"

    # 4. Eligibility assessment
    eligibility_keywords = [
        "eligible",
        "eligibility",
        "qualify",
        "can i apply",
        "am i eligible",
        "scheme criteria",
    ]
    if any(kw in text for kw in eligibility_keywords):
        return "ELIGIBILITY"

    return "UNKNOWN"


def _extract_application_id(
    request: JagoMessageRequest,
    current_user: User | None = None,
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

    # Contextual user resolution: If authenticated, resolve student's application
    if current_user and db:
        student = db.query(Student).filter(Student.user_id == current_user.id).first()
        if student:
            user_apps = (
                db.query(Application)
                .filter(Application.student_id == student.id)
                .all()
            )
            if user_apps:
                return user_apps[-1].id

    return None


def _extract_student_id(
    request: JagoMessageRequest,
    current_user: User | None = None,
    db: Session | None = None,
) -> str:
    if request.student_id and request.student_id.strip():
        return request.student_id.strip()

    if request.context and isinstance(request.context, dict):
        ctx_sid = request.context.get("student_id")
        if ctx_sid and str(ctx_sid).strip():
            return str(ctx_sid).strip()

    # Contextual user resolution: If authenticated, resolve student record
    if current_user and db:
        student = db.query(Student).filter(Student.user_id == current_user.id).first()
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


def process_jago_message(
    db: Session,
    conversation_id: str,
    request: JagoMessageRequest,
    current_user: User | None = None,
) -> JagoMessageResponse:
    """Orchestrates JAGO interactions by invoking approved domain services.
    
    JAGO does NOT directly query or manipulate database models.
    """
    intent = detect_intent(request.message, request.intent)

    if intent == "APPLICATION_STATUS":
        app_id = _extract_application_id(request, current_user=current_user, db=db)
        if not app_id:
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message="Please provide your Application ID so I can look up its status (for example: 'Status of application 00000000-0000-0000-0000-000000000020').",
                data={"error": "APPLICATION_ID_REQUIRED"},
                source="jago_orchestration",
                suggestions=["Check status for 00000000-0000-0000-0000-000000000020"],
            )

        status_result = get_application_status(db, app_id)
        if status_result == "APPLICATION_NOT_FOUND":
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=f"No application found with ID '{app_id}'. Please check the ID and try again.",
                data={"application_id": app_id, "found": False},
                source="application_service.get_application_status",
                suggestions=["Check my application status", "Am I eligible?"],
            )

        current_status = status_result.get("status", "UNKNOWN")
        return JagoMessageResponse(
            conversation_id=conversation_id,
            intent=intent,
            message=f"Your scholarship application ({app_id}) is currently in '{current_status}' status.",
            data=status_result,
            source="application_service.get_application_status",
            suggestions=[
                "Check for deficiencies on this application",
                "Am I eligible for other schemes?",
            ],
        )

    elif intent == "APPLICATION_DEFICIENCIES":
        app_id = _extract_application_id(request, current_user=current_user, db=db)
        if not app_id:
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message="Please provide your Application ID to view any deficiencies or document issues (for example: 'What documents are missing for 00000000-0000-0000-0000-000000000020?').",
                data={"error": "APPLICATION_ID_REQUIRED"},
                source="jago_orchestration",
                suggestions=["Check deficiencies for 00000000-0000-0000-0000-000000000020"],
            )

        deficiencies_result = get_application_deficiencies(db, app_id)
        if deficiencies_result == "APPLICATION_NOT_FOUND":
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=f"No application found with ID '{app_id}'. Please check the ID and try again.",
                data={"application_id": app_id, "found": False},
                source="application_service.get_application_deficiencies",
                suggestions=["Check my application status", "Am I eligible?"],
            )

        count = len(deficiencies_result)
        if count == 0:
            msg = f"Good news! Application {app_id} has no outstanding deficiencies or missing documents."
        else:
            msg = f"Application {app_id} has {count} deficiency issue(s) that require your attention."

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
                f"Check status for {app_id}",
                "Am I eligible for other schemes?",
            ],
        )

    elif intent == "PAYMENT_STATUS":
        app_id = _extract_application_id(request, current_user=current_user, db=db)
        if not app_id:
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message="Please provide your Application ID to check your DBT disbursement and payment status (for example: 'What is the payment status for 00000000-0000-0000-0000-000000000020?').",
                data={"error": "APPLICATION_ID_REQUIRED"},
                source="jago_orchestration",
                suggestions=["Check payment for 00000000-0000-0000-0000-000000000020"],
            )


        payment_result = get_payment_status(db, app_id)
        if payment_result == "APPLICATION_NOT_FOUND":
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=f"No application found with ID '{app_id}'. Please check the ID and try again.",
                data={"application_id": app_id, "found": False},
                source="payment_service.get_payment_status",
                suggestions=["Check my application status", "Am I eligible?"],
            )

        pay_status = payment_result.get("status", "UNKNOWN")
        pay_msg = payment_result.get("message", "")
        return JagoMessageResponse(
            conversation_id=conversation_id,
            intent=intent,
            message=f"Your DBT payment status is '{pay_status}': {pay_msg} (Simulated prototype mode)",
            data=payment_result,
            source="payment_service.get_payment_status",
            suggestions=[
                f"Check status for {app_id}",
                f"Check deficiencies for {app_id}",
            ],
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
                message=f"Student record '{student_id}' was not found.",
                data={"error": "STUDENT_NOT_FOUND"},
                source="eligibility_service.check_eligibility",
                suggestions=["Am I eligible?", "Check my application status"],
            )

        if result == "SCHOLARSHIP_NOT_FOUND":
            return JagoMessageResponse(
                conversation_id=conversation_id,
                intent=intent,
                message=f"Scholarship scheme '{scholarship_id}' was not found.",
                data={"error": "SCHOLARSHIP_NOT_FOUND"},
                source="eligibility_service.check_eligibility",
                suggestions=["Am I eligible?", "Check my application status"],
            )

        is_eligible = getattr(result, "eligible", False)
        reasons = getattr(result, "reasons", [])
        reasons_text = "; ".join(reasons) if reasons else "Simulated criteria met."

        msg = (
            f"Mock Eligibility Result: You appear eligible for this scheme ({reasons_text}). Note: This is an isolated prototype evaluation."
            if is_eligible
            else f"Mock Eligibility Result: You do not currently meet the simulated criteria ({reasons_text})."
        )

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
            suggestions=["Check my application status", "What documents are missing?"],
        )

    # UNKNOWN intent fallback
    return JagoMessageResponse(
        conversation_id=conversation_id,
        intent="UNKNOWN",
        message="I'm sorry, I could not determine what action you'd like to take. JAGO can assist with checking your scholarship application status, identifying missing documents or deficiencies, checking DBT payment status, and assessing scheme eligibility.",
        data=None,
        source="jago_rule_engine",
        suggestions=DEFAULT_SUGGESTIONS,
    )

