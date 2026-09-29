"""Safe, authorized backend tools for JAGO Assistant.

SECURITY INVARIANTS:
1. LLM never accesses raw database models or writes arbitrary SQL.
2. Every student-specific tool executes exclusively in the context of the
   authenticated student (or designated demo student in unauthenticated/testing mode).
3. If an application ID is supplied, student ownership is strictly validated before querying.
4. All tool outputs are JSON-serializable dictionaries sanitized for LLM consumption.
"""

from typing import Any
from sqlalchemy.orm import Session

from app.models.student import Student
from app.models.user import User
from app.repositories.application_repository import (
    get_application_by_id,
    get_applications_by_student_id,
)
from app.repositories.scholarship_repository import get_scholarship_by_id, get_scholarships
from app.services.application_service import (
    get_application_status,
    get_application_deficiencies,
    get_application_timeline,
    list_student_applications,
)
from app.services.payment_service import get_payment_status
from app.services.eligibility_service import check_conflict
from app.services.notification_service import list_notifications
from app.core.scholarship_knowledge import (
    SCHOLARSHIP_SCHEMES_KNOWLEDGE,
    get_scheme_by_code,
    get_all_schemes_summary,
)
from app.seed import DEMO_STUDENT_ID, DEMO_SCHOLARSHIPS


class JagoToolSet:
    """Encapsulates authenticated tools that the JAGO LLM can invoke."""

    def __init__(
        self,
        db: Session,
        current_user: User | None = None,
        student: Student | None = None,
    ):
        self.db = db
        self.current_user = current_user
        self.student = student
        # Fallback to demo student ID if student object is absent
        self.student_id = student.id if student else DEMO_STUDENT_ID

    def _resolve_application_id(self, application_id: str | None = None) -> tuple[str | None, str | None]:
        """Resolves target application ID and enforces student ownership.
        
        Returns:
            (valid_app_id, error_message)
        """
        if application_id and application_id.strip():
            target_id = application_id.strip()
            # Verify ownership
            app = get_application_by_id(self.db, target_id)
            if not app:
                return None, f"No application was found with ID '{target_id}'."
            if app.student_id != self.student_id:
                return None, "UNAUTHORIZED: You are not authorized to view applications belonging to other students."
            return target_id, None

        user_apps = list_student_applications(self.db, self.student_id)
        if not user_apps:
            return None, "You do not have any registered scholarship applications."

        # Pick the most relevant or recent application
        return user_apps[0].id, None

    # ── TOOL 1: APPLICATION STATUS ───────────────────────────
    def get_my_application_status(self, application_id: str = "") -> dict[str, Any]:
        """Retrieves the current review and processing status of the authenticated student's scholarship application.
        
        Args:
            application_id: Optional specific application UUID. If omitted, uses student's active application.
        """
        app_id, err = self._resolve_application_id(application_id)
        if err:
            return {"status": "ERROR", "message": err}

        res = get_application_status(self.db, app_id)
        if res == "APPLICATION_NOT_FOUND":
            return {"status": "ERROR", "message": f"Application {app_id} not found."}

        app = get_application_by_id(self.db, app_id)
        scheme_name = "Unknown Scheme"
        if app and app.scholarship_id:
            sch = get_scholarship_by_id(self.db, app.scholarship_id)
            if sch:
                scheme_name = sch.name

        return {
            "status": "SUCCESS",
            "application_id": app_id,
            "scheme_name": scheme_name,
            "current_stage": res.get("status", "UNKNOWN"),
            "last_updated": res.get("last_updated"),
            "note": "Status retrieved via official TribalSetu verification workflow.",
        }

    # ── TOOL 2: APPLICATION TIMELINE ─────────────────────────
    def get_my_application_timeline(self, application_id: str = "") -> dict[str, Any]:
        """Retrieves the chronological audit timeline and verification milestone history of the student's application.
        
        Args:
            application_id: Optional specific application UUID. If omitted, uses student's active application.
        """
        app_id, err = self._resolve_application_id(application_id)
        if err:
            return {"status": "ERROR", "message": err}

        events = get_application_timeline(self.db, app_id)
        if events == "APPLICATION_NOT_FOUND":
            return {"status": "ERROR", "message": f"Application {app_id} not found."}

        formatted_events = []
        for ev in (events or []):
            formatted_events.append({
                "action": getattr(ev, "action", str(ev)),
                "status_after": getattr(ev, "status_after", ""),
                "remarks": getattr(ev, "remarks", "") or "",
                "created_at": getattr(ev, "created_at", "").isoformat() if hasattr(getattr(ev, "created_at", None), "isoformat") else str(getattr(ev, "created_at", "")),
            })

        return {
            "status": "SUCCESS",
            "application_id": app_id,
            "total_events": len(formatted_events),
            "timeline": formatted_events,
        }

    # ── TOOL 3: APPLICATION DEFICIENCIES ─────────────────────
    def get_my_application_deficiencies(self, application_id: str = "") -> dict[str, Any]:
        """Identifies missing documents, mismatches, or rejected items requiring student correction.
        
        Args:
            application_id: Optional specific application UUID. If omitted, uses student's active application.
        """
        app_id, err = self._resolve_application_id(application_id)
        if err:
            return {"status": "ERROR", "message": err}

        deficiencies = get_application_deficiencies(self.db, app_id)
        if deficiencies == "APPLICATION_NOT_FOUND":
            return {"status": "ERROR", "message": f"Application {app_id} not found."}

        has_issues = len(deficiencies) > 0

        # Detailed breakdown of attached documents for specific student inquiries
        from app.repositories.application_document_repository import get_documents_by_application_id
        from app.repositories.verification_repository import get_verifications_by_application_id
        attached = get_documents_by_application_id(self.db, app_id) or []
        verifs = {v.document_id: v for v in (get_verifications_by_application_id(self.db, app_id) or [])}

        verified_docs = []
        pending_docs = []
        mismatch_docs = []
        for d in attached:
            v = verifs.get(d.id)
            v_status = v.status if v else d.status
            if v_status == "VERIFIED":
                verified_docs.append(d.document_name)
            elif v_status in ["MISMATCH", "FAILED"]:
                mismatch_docs.append(d.document_name)
            else:
                pending_docs.append({
                    "document_name": d.document_name,
                    "status": "PENDING_VERIFICATION",
                    "reason": "Awaiting verification by Institute Nodal Officer / DigiLocker issuer sync",
                })

        return {
            "status": "SUCCESS",
            "application_id": app_id,
            "has_deficiencies": has_issues,
            "total_deficiencies": len(deficiencies),
            "deficiency_items": deficiencies,
            "verified_documents": verified_docs,
            "pending_documents": pending_docs,
            "mismatch_documents": mismatch_docs,
            "action_advice": (
                "Please upload the corrected document(s) via the TribalSetu Documents screen or re-sync with DigiLocker."
                if has_issues
                else "No outstanding deficiency actions are required for your application."
            ),
        }

    # ── TOOL 4: CHECK ELIGIBILITY ────────────────────────────
    def check_my_eligibility(self, scheme_name_or_code: str = "") -> dict[str, Any]:
        """Evaluates whether the student qualifies for a scheme and checks against multi-scholarship conflict rules.
        
        Args:
            scheme_name_or_code: Name or code of the scholarship (e.g. 'POST_MATRIC', 'NFST', 'Top Class', 'Pre-Matric', 'NOS').
        """
        # Resolve scholarship ID
        scholarship_id = None
        scheme_data = get_scheme_by_code(scheme_name_or_code)
        target_code = scheme_data["code"] if scheme_data else "POST_MATRIC"

        db_schemes = get_scholarships(self.db)
        for s in db_schemes:
            if s.code == target_code or target_code in s.name.upper():
                scholarship_id = s.id
                break

        if not scholarship_id:
            for s in DEMO_SCHOLARSHIPS:
                if s["code"] == target_code:
                    scholarship_id = s["id"]
                    break

        if not scholarship_id and db_schemes:
            scholarship_id = db_schemes[0].id

        conflict_res = check_conflict(self.db, self.student_id, scholarship_id)
        if isinstance(conflict_res, str):
            return {"status": "ERROR", "message": conflict_res}

        return {
            "status": "SUCCESS",
            "scheme_code": target_code,
            "scheme_name": scheme_data["scheme_name"] if scheme_data else target_code,
            "eligible": getattr(conflict_res, "eligible", True),
            "decision_status": getattr(conflict_res, "status", "ELIGIBLE"),
            "reasons": getattr(conflict_res, "reasons", []),
            "evaluation_mode": getattr(conflict_res, "evaluation_mode", "MOCK"),
            "policy_rule": "Under MoTA guidelines, a student can avail only one Central/State scholarship at a time.",
        }

    # ── TOOL 5: PAYMENT STATUS ───────────────────────────────
    def get_my_payment_status(self, application_id: str = "") -> dict[str, Any]:
        """Checks DBT disbursement, PFMS transfer status, and scholarship funds credit.
        
        Args:
            application_id: Optional specific application UUID. If omitted, checks student's sanctioned/active application.
        """
        app_id, err = self._resolve_application_id(application_id)
        if err:
            return {"status": "ERROR", "message": err}

        res = get_payment_status(self.db, app_id)
        if res == "APPLICATION_NOT_FOUND":
            return {"status": "ERROR", "message": f"Application {app_id} not found."}

        return {
            "status": "SUCCESS",
            "application_id": app_id,
            "payment_status": res.get("status", "UNKNOWN"),
            "dbt_status": res.get("dbt_status", "UNKNOWN"),
            "amount": res.get("amount", "Pending Calculation"),
            "transaction_id": res.get("transaction_id") or res.get("payment_reference"),
            "initiated_date": res.get("initiated_date"),
            "processed_date": res.get("processed_date"),
            "credited_date": res.get("credited_date"),
            "failure_reason": res.get("failure_reason"),
            "details": res.get("message", ""),
            "payment_mode": "Direct Benefit Transfer (DBT) / PFMS",
            "prototype_notice": "DBT disbursement is simulated in prototype environment.",
        }


    # ── TOOL 6: SCHOLARSHIP INFORMATION ──────────────────────
    def get_scholarship_information(self, scheme_name_or_code: str = "") -> dict[str, Any]:
        """Provides verified knowledge details regarding MoTA's 5 official ST scholarship schemes.
        
        Args:
            scheme_name_or_code: Target scheme (e.g. 'Pre-Matric', 'Post-Matric', 'Top Class', 'NFST', 'NOS'). If empty, returns summary of all 5.
        """
        if not scheme_name_or_code.strip():
            return {
                "status": "SUCCESS",
                "available_schemes": get_all_schemes_summary(),
                "guidance": "Ask for specific details on any scheme (e.g. 'Tell me about NFST' or 'Eligibility for Post Matric').",
            }

        scheme_data = get_scheme_by_code(scheme_name_or_code)
        if not scheme_data:
            return {
                "status": "NOT_FOUND",
                "message": f"Could not find verified MoTA guidelines for '{scheme_name_or_code}'.",
                "available_schemes": list(SCHOLARSHIP_SCHEMES_KNOWLEDGE.keys()),
            }

        return {
            "status": "SUCCESS",
            "scheme": scheme_data,
        }

    # ── TOOL 7: REQUIRED DOCUMENTS ───────────────────────────
    def get_required_documents(self, scheme_name_or_code: str = "") -> dict[str, Any]:
        """Lists mandatory and supporting documents required for applying to a specific ST scholarship scheme.
        
        Args:
            scheme_name_or_code: Target scheme code or name (e.g. 'POST_MATRIC', 'NFST', 'NOS').
        """
        scheme_data = get_scheme_by_code(scheme_name_or_code or "POST_MATRIC")
        if not scheme_data:
            scheme_data = SCHOLARSHIP_SCHEMES_KNOWLEDGE["POST_MATRIC"]

        return {
            "status": "SUCCESS",
            "scheme_name": scheme_data["scheme_name"],
            "scheme_code": scheme_data["code"],
            "required_documents": scheme_data["required_documents"],
            "digilocker_support": "ST Caste, Income, and Academic marksheets can be auto-fetched from DigiLocker.",
            "note": "Documents must be self-attested and legible if uploaded manually.",
        }

    # ── TOOL 8: PROFILE SUMMARY ──────────────────────────────
    def get_my_profile_summary(self) -> dict[str, Any]:
        """Retrieves non-sensitive summary of the currently authenticated student profile."""
        name = "Student"
        email = "Not Available"
        student_id = self.student_id

        if self.student:
            name = self.student.name
            email = self.student.email
        elif self.current_user:
            name = self.current_user.name
            email = self.current_user.email

        apps = list_student_applications(self.db, self.student_id)
        total_apps = len(apps)

        return {
            "status": "SUCCESS",
            "student_id": student_id,
            "name": name,
            "email": email,
            "total_registered_applications": total_apps,
            "verification_status": "DigiLocker Integrated / ST Verified (Prototype)",
        }

    # ── TOOL 9: NOTIFICATIONS ────────────────────────────────
    def get_my_notifications(self, unread_only: bool = False) -> dict[str, Any]:
        """Fetches the latest official notifications, alerts, and deficiency notices for the student.
        
        Args:
            unread_only: If True, only returns unread alerts.
        """
        notifs = list_notifications(self.db, student_id=self.student_id, unread_only=unread_only)
        if notifs == "STUDENT_NOT_FOUND":
            return {"status": "SUCCESS", "notifications": [], "total": 0}

        results = []
        for n in (notifs or []):
            results.append({
                "title": getattr(n, "title", ""),
                "message": getattr(n, "message", ""),
                "category": getattr(n, "category", ""),
                "is_read": getattr(n, "is_read", False),
                "created_at": getattr(n, "created_at", "").isoformat() if hasattr(getattr(n, "created_at", None), "isoformat") else str(getattr(n, "created_at", "")),
            })

        return {
            "status": "SUCCESS",
            "total": len(results),
            "notifications": results,
        }

    def get_tools_map(self) -> dict[str, Any]:
        """Returns mapping of tool name to bound callable function."""
        return {
            "get_my_application_status": self.get_my_application_status,
            "get_my_application_timeline": self.get_my_application_timeline,
            "get_my_application_deficiencies": self.get_my_application_deficiencies,
            "check_my_eligibility": self.check_my_eligibility,
            "get_my_payment_status": self.get_my_payment_status,
            "get_scholarship_information": self.get_scholarship_information,
            "get_required_documents": self.get_required_documents,
            "get_my_profile_summary": self.get_my_profile_summary,
            "get_my_notifications": self.get_my_notifications,
        }
