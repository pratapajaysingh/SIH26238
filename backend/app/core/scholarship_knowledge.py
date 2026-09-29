"""Centralized, verified scholarship knowledge base for JAGO Assistant.

Covers the 5 core Ministry of Tribal Affairs (MoTA) schemes for Scheduled Tribe (ST) students:
1. Pre-Matric Scholarship for ST Students
2. Post-Matric Scholarship for ST Students
3. Top Class Education Scheme for ST Students
4. National Fellowship for ST Students (NFST)
5. National Overseas Scholarship for ST Students (NOS)

NOTE: Exact official guidelines, sanction dates, and income thresholds adhere to
official MoTA scheme notifications. Where exact official details are prototype-configured,
they are explicitly annotated as configurable/demo prototype parameters.
"""

from typing import Any

SCHOLARSHIP_SCHEMES_KNOWLEDGE: dict[str, dict[str, Any]] = {
    "PRE_MATRIC": {
        "scheme_name": "Pre-Matric Scholarship for ST Students",
        "code": "PRE_MATRIC",
        "ministry": "Ministry of Tribal Affairs (MoTA)",
        "source": "Ministry of Tribal Affairs",
        "last_updated": "2026-04-01",
        "broad_purpose": (
            "To support ST parents for education of their children studying in Classes IX and X, "
            "so that the incidence of drop-out, especially in the transition from elementary to secondary stage, is minimized."
        ),
        "target_category": "Scheduled Tribe (ST) students in Classes IX and X",
        "duration": "2 Academic Years (Class 9 and 10)",
        "application_channel": "National Scholarship Portal (NSP) / State Portals / TribalSetu",
        "broad_eligibility": {
            "caste": "Must belong to Scheduled Tribe (ST) recognized under the Constitution.",
            "education": "Regular full-time student in Class IX or X in a Government or recognized school.",
            "income_ceiling": "Family annual income ceiling: ₹2,50,000 (Configurable prototype threshold).",
            "other_conditions": "Must not be holding any other Central/State scholarship simultaneously.",
        },
        "benefit_amount": "Up to ₹6,000/year (Maintenance allowance + Day Scholar/Hosteller grant per guidelines)",
        "structured_benefits": {
            "tuition_support": "Covered under compulsory free school education norms",
            "maintenance_allowance": "Day Scholar: ₹3,500/year; Hosteller: ₹7,000/year",
            "academic_allowance": "Included in annual maintenance grant",
            "book_allowance": "Free textbooks provided under Samagra Shiksha / State schemes",
            "other_benefits": "Additional disability allowance of 10% for students with benchmark disabilities",
            "total_or_max_benefit": "Up to ₹7,000/year",
            "frequency": "Annual direct transfer to parent/student Aadhaar-seeded bank account",
        },
        "required_documents": [
            "ST Caste Certificate (DigiLocker verified or Competent Authority)",
            "Income Certificate issued by designated State Authority",
            "School Enrollment / Bonafide Certificate",
            "Aadhaar Card (linked to student or parent)",
            "Aadhaar-seeded Bank Account Passbook",
        ],
        "application_info": {
            "portal": "National Scholarship Portal (NSP) / TribalSetu unified portal",
            "mode": "Online submission via portal with document verification",
            "verification_stages": ["School / Institute Level", "District Welfare Office", "State Welfare Department"],
        },
        "important_notes": (
            "Disbursement is made directly into the student/parent Aadhaar-seeded bank account via DBT. "
            "Under MoTA guidelines, students cannot avail any other government scholarship simultaneously."
        ),
    },
    "POST_MATRIC": {
        "scheme_name": "Post-Matric Scholarship for ST Students",
        "code": "POST_MATRIC",
        "ministry": "Ministry of Tribal Affairs (MoTA)",
        "source": "Ministry of Tribal Affairs",
        "last_updated": "2026-04-01",
        "broad_purpose": (
            "To provide financial assistance to Scheduled Tribe students studying at post-matriculation "
            "or post-secondary stages (Class XI to Post-Doctoral studies) to enable them to complete their education."
        ),
        "target_category": "Scheduled Tribe (ST) students pursuing Post-Matriculation / Higher Education",
        "duration": "Tenure of recognized post-secondary diploma, degree, or postgraduate course",
        "application_channel": "National Scholarship Portal (NSP) / State Portals / TribalSetu",
        "broad_eligibility": {
            "caste": "Must belong to Scheduled Tribe (ST) recognized by the Government of India.",
            "education": "Enrolled in recognized post-secondary course (Class 11, 12, ITI, Diploma, Undergraduate, Postgraduate, M.Phil/Ph.D.).",
            "income_ceiling": "Total family annual income must not exceed ₹2,50,000 per annum (Configurable prototype parameter).",
            "other_conditions": "Applicable for study in India only. Student can avail only one Central/State scholarship at a time.",
        },
        "benefit_amount": "Full compulsory non-refundable fees + Annual maintenance allowance up to ₹48,000/year depending on course group and hosteller/day scholar status.",
        "structured_benefits": {
            "tuition_support": "100% compulsory non-refundable fees approved by State Fee Regulatory Authority",
            "maintenance_allowance": "₹4,000 - ₹13,500/year (Day Scholar) / ₹7,000 - ₹20,000/year (Hosteller) based on course Group (Group 1 to 4)",
            "academic_allowance": "Study tour charges up to ₹1,600/year; thesis typing ₹1,600",
            "book_allowance": "Book bank facility / grants for medical, engineering, and professional streams",
            "other_benefits": "Special reader allowance of ₹2,000 - ₹4,000/year for visually impaired scholars",
            "total_or_max_benefit": "Full tuition fees + up to ₹48,000/year",
            "frequency": "Annual Direct Benefit Transfer (DBT) to student's Aadhaar-seeded bank account",
        },
        "required_documents": [
            "ST Caste Certificate (DigiLocker or verified State authority certificate)",
            "Annual Family Income Certificate",
            "Previous Year Academic Marksheet / Passing Certificate",
            "Institution Admission / Fee Receipt / Bonafide Certificate",
            "Aadhaar Card (Aadhaar number)",
            "Active Aadhaar-seeded Bank Account Passbook / Bank verification details",
        ],
        "application_info": {
            "portal": "TribalSetu / State Scholarship Portal / NSP",
            "mode": "Online application with automated DigiLocker document ingestion",
            "verification_stages": ["Institute Verification", "District Nodal Officer (DNO)", "State Nodal Officer (SNO)", "PFMS / DBT Disbursement"],
        },
        "important_notes": (
            "100% Direct Benefit Transfer (DBT). DBT requires an active bank account with NPCI Aadhaar seeding. "
            "Students availing this scheme cannot simultaneously draw benefits from any other Central or State scholarship."
        ),
    },
    "TOP_CLASS_EDUCATION": {
        "scheme_name": "National Fellowship and Scholarship for Higher Education of ST Students (Top Class Education)",
        "code": "TOP_CLASS_EDUCATION",
        "ministry": "Ministry of Tribal Affairs (MoTA)",
        "source": "Ministry of Tribal Affairs",
        "last_updated": "2026-04-01",
        "broad_purpose": (
            "To encourage meritorious ST students to pursue professional and technical courses "
            "in premier notified institutions such as IITs, IIMs, NITs, AIIMS, NLUs, and other notified top-tier institutes."
        ),
        "target_category": "ST students admitted to notified Top Class Institutions across India",
        "duration": "Full tenure of the professional or postgraduate degree program",
        "application_channel": "National Scholarship Portal (NSP) / MoTA Top Class Portal / TribalSetu",
        "broad_eligibility": {
            "caste": "Must belong to Scheduled Tribe (ST).",
            "education": "Secured admission into an institute included in the MoTA notified list of Top Class Institutions.",
            "income_ceiling": "Total family income from all sources must not exceed ₹6,00,000 per annum (Configurable prototype threshold).",
            "slots": "Limited slots allocated per institute / year as notified by the Ministry.",
        },
        "benefit_amount": "Full tuition fee and non-refundable fees + Living expenses allowance of ₹3,000/month + Books & stationery ₹5,000/year + Computer assistance ₹45,000 (one-time).",
        "structured_benefits": {
            "tuition_support": "Full tuition fee and non-refundable charges (up to ₹2.00 lakh/year for private institutes; actuals for government institutes)",
            "maintenance_allowance": "Living expenses allowance: ₹3,000/month (₹36,000/year)",
            "academic_allowance": "Computer and accessories grant: ₹45,000 (one-time during entire tenure)",
            "book_allowance": "Books and stationery grant: ₹5,000/year",
            "other_benefits": "Coverage includes top IITs, IIMs, NITs, AIIMS, NLUs, and central premier institutions",
            "total_or_max_benefit": "Full tuition + ₹86,000 in Year 1 (₹41,000/year thereafter)",
            "frequency": "Living/book allowance to student via DBT; tuition fee paid directly to the institute",
        },
        "required_documents": [
            "ST Caste Certificate",
            "Income Certificate from Competent Authority",
            "Admission Offer Letter & Fee Structure from Notified Premier Institution",
            "Class XII / Qualifying Exam Marksheet",
            "Aadhaar Card",
            "Aadhaar-seeded Bank Passbook / Mandate",
        ],
        "application_info": {
            "portal": "NSP / MoTA Scholarship Portal / TribalSetu",
            "mode": "Online application, verified by Head of Institution and MoTA",
            "verification_stages": ["Institute Verification", "Ministry Level Merit Allocation", "Sanction & Payment"],
        },
        "important_notes": (
            "Scholarship continues till completion of the course subject to satisfactory academic performance. "
            "Students can avail only one scholarship scheme at a time."
        ),
    },
    "NATIONAL_FELLOWSHIP_ST": {
        "scheme_name": "National Fellowship for ST Students (NFST)",
        "code": "NATIONAL_FELLOWSHIP_ST",
        "ministry": "Ministry of Tribal Affairs (MoTA)",
        "source": "Ministry of Tribal Affairs",
        "last_updated": "2026-04-01",
        "broad_purpose": (
            "To support Scheduled Tribe students to pursue regular and full-time M.Phil and Ph.D. research degrees "
            "in Sciences, Humanities, Social Sciences, and Engineering/Technology in Indian universities/institutions."
        ),
        "target_category": "ST research scholars pursuing full-time M.Phil / Ph.D.",
        "duration": "Up to 5 years (2 years JRF + 3 years SRF)",
        "application_channel": "MoTA Fellowship Portal / TribalSetu / UGC Portal",
        "broad_eligibility": {
            "caste": "Must belong to Scheduled Tribe (ST).",
            "education": "Post-Graduate degree with at least 55% marks (or equivalent) and registered in regular full-time M.Phil / Ph.D.",
            "qualifying_exams": "UGC NET / CSIR NET-JRF / ICMR / GATE qualification is prioritized / mandatory per scheme guidelines.",
            "income_ceiling": "No family income ceiling applies for Fellowship, merit and research admission based.",
            "slots": "750 fresh fellowships awarded annually across India.",
        },
        "benefit_amount": "JRF: ₹31,000/month (initially 2 years); SRF: ₹35,000/month (remaining tenure) + HRA + Contingency grants (₹10,000-₹20,500/year).",
        "structured_benefits": {
            "tuition_support": "Not applicable / Institutional waiver for full-time JRF/SRF fellows",
            "maintenance_allowance": "Junior Research Fellow (JRF): ₹31,000/month for initial 2 years; Senior Research Fellow (SRF): ₹35,000/month for remaining 3 years",
            "academic_allowance": "House Rent Allowance (HRA) as per Central Government rates (8%, 16%, or 24% based on city tier X, Y, Z)",
            "book_allowance": "Contingency grant: ₹10,000/year (Humanities and Social Sciences) or ₹20,500/year (Sciences, Engineering & Technology)",
            "other_benefits": "Escorts/Reader assistance of ₹2,000/month for physically challenged and blind candidates",
            "total_or_max_benefit": "₹31,000 - ₹35,000/month + HRA + up to ₹20,500/year contingency",
            "frequency": "Monthly Direct Benefit Transfer (DBT) via PFMS to Aadhaar-seeded bank account",
        },
        "required_documents": [
            "ST Caste Certificate",
            "Post-Graduate Degree Marksheet and Certificate",
            "UGC-NET / CSIR-NET / GATE Scorecard / Result",
            "University / Institute Ph.D. / M.Phil Registration / Admission Certificate",
            "Synopsis / Research Proposal approved by Departmental Research Committee",
            "Aadhaar Card and Aadhaar-seeded Bank Passbook",
        ],
        "application_info": {
            "portal": "MoTA Fellowship Portal / TribalSetu",
            "mode": "Direct online application with University verification",
            "verification_stages": ["University Nodal Officer Verification", "MoTA Steering Committee Merit Selection", "PFMS Direct Credit"],
        },
        "important_notes": (
            "Fellows cannot hold any full-time employment or receive any other fellowship/scholarship during the tenure. "
            "750 slots are awarded annually across India on merit."
        ),
    },
    "NATIONAL_OVERSEAS": {
        "scheme_name": "National Overseas Scholarship for ST Students (NOS)",
        "code": "NATIONAL_OVERSEAS",
        "ministry": "Ministry of Tribal Affairs (MoTA)",
        "source": "Ministry of Tribal Affairs",
        "last_updated": "2026-04-01",
        "broad_purpose": (
            "To facilitate ST candidates to pursue Post Graduate and Doctoral (Ph.D.) studies abroad "
            "in accredited international universities, with special priority for Top 500 QS World Ranking institutions."
        ),
        "target_category": "ST students pursuing Masters / Ph.D. in foreign universities",
        "duration": "Masters: Up to 3 years; Ph.D.: Up to 4 years",
        "application_channel": "MoTA Overseas Scholarship Portal / TribalSetu",
        "broad_eligibility": {
            "caste": "Must belong to Scheduled Tribe (ST).",
            "education": "At least 55% marks or equivalent grade in relevant Master's (for Ph.D.) or Bachelor's (for Master's).",
            "admission": "Must hold an unconditional offer letter of admission from a top foreign university (QS Rank <= 500).",
            "age_limit": "Below 35 years as on 1st July of the application year.",
            "income_ceiling": "Total family annual income must not exceed ₹6,00,000 per annum (Configurable prototype parameter).",
            "slots": "20 fresh awards per year.",
        },
        "benefit_amount": "Full tuition fees + Annual maintenance allowance (USD 15,400 for USA / GBP 9,900 for UK) + Contingency allowance + Airfare (economy class) + Medical insurance.",
        "structured_benefits": {
            "tuition_support": "100% actual tuition fees charged by accredited foreign institution",
            "maintenance_allowance": "USD 15,400/year for USA and other countries; GBP 9,900/year for United Kingdom",
            "academic_allowance": "Annual contingency grant: USD 1,500/year or GBP 1,100/year for books, equipment, and conference travel",
            "book_allowance": "Covered under the annual contingency grant",
            "other_benefits": "Economy class return international airfare; Visa fees; Medical health insurance premium actuals",
            "total_or_max_benefit": "Full tuition + USD 15,400/year (or GBP 9,900/year) + Airfare + Insurance",
            "frequency": "Disbursed biannually via Indian Missions abroad",
        },
        "required_documents": [
            "ST Caste Certificate",
            "Income Certificate (competent revenue authority)",
            "Valid Indian Passport (Bio-data pages)",
            "Unconditional Offer Letter from Top 500 QS ranked university",
            "Academic Transcripts (10th, 12th, Bachelor's, Master's)",
            "Proof of GRE / GMAT / IELTS / TOEFL scores (if required by university)",
            "Aadhaar Card and Indian Bank Account details",
        ],
        "application_info": {
            "portal": "Ministry of Tribal Affairs Overseas Portal / TribalSetu",
            "mode": "Online submission during annual application window",
            "verification_stages": ["Document Scrutiny", "Interview / Screening Committee", "Sanction Letter Issued by MoTA"],
        },
        "important_notes": (
            "Awardees must execute a bond to return to India and serve for at least 2 years post completion of studies. "
            "External visa, embassy, and foreign university verifications are simulated in prototype mode."
        ),
    },
}


def get_scheme_by_code(query: str) -> dict[str, Any] | None:
    """Resolve a scheme dict using fuzzy code/keyword matching."""
    text = query.lower().replace("-", " ").replace("_", " ").strip()
    if not text:
        return None

    # Exact code match
    for code, data in SCHOLARSHIP_SCHEMES_KNOWLEDGE.items():
        if code.lower() == text:
            return data

    # Keyword mappings
    if "pre" in text and "matric" in text:
        return SCHOLARSHIP_SCHEMES_KNOWLEDGE["PRE_MATRIC"]
    if "school" in text or "class 9" in text or "class 10" in text or "secondary school" in text:
        return SCHOLARSHIP_SCHEMES_KNOWLEDGE["PRE_MATRIC"]
    if "post" in text and "matric" in text:
        return SCHOLARSHIP_SCHEMES_KNOWLEDGE["POST_MATRIC"]
    if "top" in text or "premier" in text or "iit" in text or "iim" in text or "nit" in text:
        return SCHOLARSHIP_SCHEMES_KNOWLEDGE["TOP_CLASS_EDUCATION"]
    if "fellowship" in text or "nfst" in text or "phd" in text or "m.phil" in text or "jrf" in text or "srf" in text:
        return SCHOLARSHIP_SCHEMES_KNOWLEDGE["NATIONAL_FELLOWSHIP_ST"]
    if "overseas" in text or "nos" in text or "abroad" in text or "foreign" in text:
        return SCHOLARSHIP_SCHEMES_KNOWLEDGE["NATIONAL_OVERSEAS"]
    if "higher education" in text or "college" in text or "university" in text:
        return SCHOLARSHIP_SCHEMES_KNOWLEDGE["POST_MATRIC"]

    # Partial name match
    for code, data in SCHOLARSHIP_SCHEMES_KNOWLEDGE.items():
        if text in data["scheme_name"].lower():
            return data

    return None


def get_all_schemes_summary() -> list[dict[str, Any]]:
    """Return concise overview of the 5 official schemes."""
    return [
        {
            "code": code,
            "name": data["scheme_name"],
            "purpose": data["broad_purpose"][:120] + "...",
            "target": data["target_category"],
            "benefit": data["benefit_amount"],
            "tuition_support": data["structured_benefits"]["tuition_support"],
            "maintenance_allowance": data["structured_benefits"]["maintenance_allowance"],
            "frequency": data["structured_benefits"]["frequency"],
            "source": data["source"],
            "last_updated": data["last_updated"],
        }
        for code, data in SCHOLARSHIP_SCHEMES_KNOWLEDGE.items()
    ]

