"""Unreached ST Student Identification — Analytics Service (PROTOTYPE).

This module implements a mock matching/analytics workflow to identify enrolled ST students
who are not receiving scholarship benefits, as described in the SIH 2026 problem statement.

IMPORTANT: This is a PROTOTYPE. No real UDISE+, APAAR, or OTR APIs are called.
All data is deterministic mock data for demonstration purposes only.
"""

from typing import Any


# --- Mock enrolled ST student records (simulating UDISE+/APAAR/OTR data) ---
MOCK_ENROLLED_STUDENTS = [
    {
        "demo_id": "ENROL-ST-001",
        "name_hash": "a1b2c3",  # Anonymized
        "institution_code": "INST-GOV-101",
        "institution_name": "Government Higher Secondary School, Ranchi",
        "education_level": "Class 11",
        "enrollment_source": "UDISE+",
        "state": "Jharkhand",
    },
    {
        "demo_id": "ENROL-ST-002",
        "name_hash": "d4e5f6",
        "institution_code": "INST-GOV-202",
        "institution_name": "Tribal Welfare College, Bhubaneswar",
        "education_level": "B.A. First Year",
        "enrollment_source": "AISHE",
        "state": "Odisha",
    },
    {
        "demo_id": "ENROL-ST-003",
        "name_hash": "g7h8i9",
        "institution_code": "INST-GOV-303",
        "institution_name": "Central University of Gujarat",
        "education_level": "M.Phil",
        "enrollment_source": "OTR",
        "state": "Gujarat",
    },
    {
        "demo_id": "ENROL-ST-004",
        "name_hash": "j0k1l2",
        "institution_code": "INST-PVT-404",
        "institution_name": "IIT Kharagpur",
        "education_level": "B.Tech Third Year",
        "enrollment_source": "APAAR",
        "state": "West Bengal",
    },
    {
        "demo_id": "ENROL-ST-005",
        "name_hash": "m3n4o5",
        "institution_code": "INST-GOV-505",
        "institution_name": "Government School, Imphal",
        "education_level": "Class 10",
        "enrollment_source": "UDISE+",
        "state": "Manipur",
    },
]

# --- Mock scholarship beneficiary records ---
MOCK_BENEFICIARY_RECORDS = [
    {
        "demo_id": "ENROL-ST-001",
        "scholarship_code": "POST_MATRIC",
        "status": "SANCTIONED",
    },
    {
        "demo_id": "ENROL-ST-004",
        "scholarship_code": "TOP_CLASS_EDUCATION",
        "status": "SUBMITTED",
    },
]


def identify_unreached_beneficiaries(
    enrolled_students: list[dict] | None = None,
    beneficiary_records: list[dict] | None = None,
) -> list[dict[str, Any]]:
    """Match enrolled ST students against scholarship beneficiary records.
    
    Returns a list of students who appear enrolled/eligible but have no active
    scholarship benefit (i.e. unreached beneficiaries).
    
    This is a PROTOTYPE using mock/demo data. No real government APIs are called.
    """
    if enrolled_students is None:
        enrolled_students = MOCK_ENROLLED_STUDENTS
    if beneficiary_records is None:
        beneficiary_records = MOCK_BENEFICIARY_RECORDS

    # Build lookup of beneficiaries by demo_id
    beneficiary_lookup = {
        rec["demo_id"]: rec for rec in beneficiary_records
    }

    results = []
    for student in enrolled_students:
        demo_id = student["demo_id"]
        beneficiary = beneficiary_lookup.get(demo_id)

        if beneficiary:
            matched_status = "MATCHED"
            benefit_status = beneficiary.get("status", "UNKNOWN")
            reason = None
        else:
            matched_status = "UNREACHED"
            benefit_status = "NONE"
            reason = _suggest_reason(student)

        results.append({
            "demo_id": demo_id,
            "institution_code": student.get("institution_code"),
            "institution_name": student.get("institution_name"),
            "education_level": student.get("education_level"),
            "enrollment_source": student.get("enrollment_source"),
            "state": student.get("state"),
            "matched_status": matched_status,
            "scholarship_benefit_status": benefit_status,
            "scholarship_code": beneficiary.get("scholarship_code") if beneficiary else None,
            "possible_reason": reason,
            "next_action": _suggest_action(matched_status, reason),
            "data_source": "MOCK_PROTOTYPE",
        })

    return results


def get_unreached_only(
    enrolled_students: list[dict] | None = None,
    beneficiary_records: list[dict] | None = None,
) -> list[dict[str, Any]]:
    """Convenience wrapper returning only UNREACHED students."""
    all_results = identify_unreached_beneficiaries(enrolled_students, beneficiary_records)
    return [r for r in all_results if r["matched_status"] == "UNREACHED"]


def get_unreached_summary(
    enrolled_students: list[dict] | None = None,
    beneficiary_records: list[dict] | None = None,
) -> dict[str, Any]:
    """Summary statistics for unreached beneficiary analysis."""
    all_results = identify_unreached_beneficiaries(enrolled_students, beneficiary_records)
    total = len(all_results)
    unreached = sum(1 for r in all_results if r["matched_status"] == "UNREACHED")
    matched = total - unreached

    return {
        "total_enrolled": total,
        "total_matched": matched,
        "total_unreached": unreached,
        "unreached_percentage": round((unreached / total * 100), 1) if total > 0 else 0,
        "data_source": "MOCK_PROTOTYPE",
    }


def _suggest_reason(student: dict) -> str:
    """Generate a plausible reason why a student may be unreached."""
    level = student.get("education_level", "").lower()
    source = student.get("enrollment_source", "")

    if "class 9" in level or "class 10" in level:
        return "Student may be eligible for Pre-Matric Scholarship but not yet registered"
    elif "class 11" in level or "class 12" in level:
        return "Student may be eligible for Post-Matric Scholarship but not yet registered"
    elif "m.phil" in level or "ph.d" in level:
        return "Student may be eligible for NFST fellowship but not yet registered"
    elif source == "APAAR":
        return "Student enrolled via APAAR but no matching scholarship application found"
    else:
        return "No matching scholarship registration found; outreach recommended"


def _suggest_action(matched_status: str, reason: str | None) -> str:
    if matched_status == "MATCHED":
        return "No action needed — student is receiving benefits"
    return "Send awareness notification and assist with application via JAGO"
