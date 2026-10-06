import argparse
from datetime import datetime
import logging
import os
import secrets
import sys
from sqlalchemy.orm import Session
from app.core.database import SessionLocal, engine, Base
from app.core.security import hash_password
from app.models.user import User
from app.models.student import Student
from app.models.scholarship import Scholarship
from app.models.application import Application
from app.models.document import Document
from app.models.application_document import ApplicationDocument
from app.models.verification_record import VerificationRecord
from app.models.manual_review import ManualReview
from app.models.notification import Notification
from app.models.application_timeline import ApplicationTimeline

logger = logging.getLogger("tribalsetu")

# Deterministic Demo IDs (UUID v4 format)
# Student A: Arjun Munda (eligible, active app, verification in progress, payment processing)
DEMO_USER_ID = "00000000-0000-0000-0000-000000000001"
DEMO_STUDENT_ID = "00000000-0000-0000-0000-000000000002"

# Student D: Rani Marandi (potential unreached beneficiary in UDISE+/APAAR, 0 active applications)
DEMO_USER_ID_2 = "00000000-0000-0000-0000-000000000003"
DEMO_STUDENT_ID_2 = "00000000-0000-0000-0000-000000000004"

# Student B: Sunita Soren (deficiency, missing document, manual review)
DEMO_USER_ID_3 = "00000000-0000-0000-0000-000000000005"
DEMO_STUDENT_ID_3 = "00000000-0000-0000-0000-000000000006"

# Student C: Birsa Kerketta (completed NFST fellowship, DBT payment credited)
DEMO_USER_ID_4 = "00000000-0000-0000-0000-000000000007"
DEMO_STUDENT_ID_4 = "00000000-0000-0000-0000-000000000008"

# Admin User: Ministry of Tribal Affairs Nodal Officer
DEMO_ADMIN_USER_ID = "00000000-0000-0000-0000-000000000009"

DEMO_SCHOLARSHIPS = [
    {
        "id": "00000000-0000-0000-0000-000000000010",
        "code": "POST_MATRIC",
        "name": "Post-Matric Scholarship",
        "description": "Financial support for post-matric ST students (Class XI to PhD).",
        "ministry": "Ministry of Tribal Affairs",
        "benefit_amount": "Upto ₹48,000/year",
        "education_level": "Post Matric",
    },
    {
        "id": "00000000-0000-0000-0000-000000000011",
        "code": "PRE_MATRIC",
        "name": "Pre-Matric Scholarship",
        "description": "Financial assistance for ST students in Class 9 and 10.",
        "ministry": "Ministry of Tribal Affairs",
        "benefit_amount": "Upto ₹6,000/year",
        "education_level": "Pre Matric",
    },
    {
        "id": "00000000-0000-0000-0000-000000000012",
        "code": "NATIONAL_OVERSEAS",
        "name": "National Overseas Scholarship",
        "description": "Financial assistance for ST students pursuing higher studies abroad.",
        "ministry": "Ministry of Tribal Affairs",
        "benefit_amount": "Full Tuition + Living Allowance",
        "education_level": "Post Graduate / Doctoral (Overseas)",
    },
    {
        "id": "00000000-0000-0000-0000-000000000013",
        "code": "TOP_CLASS_EDUCATION",
        "name": "National Fellowship and Scholarship for Higher Education of ST Students",
        "description": "Support for pursuing professional and technical courses at top institutions.",
        "ministry": "Ministry of Tribal Affairs",
        "benefit_amount": "Upto ₹2,00,000/year",
        "education_level": "Top Class Institutions",
    },
    {
        "id": "00000000-0000-0000-0000-000000000014",
        "code": "NATIONAL_FELLOWSHIP_ST",
        "name": "National Fellowship for ST Students (NFST)",
        "description": "Fellowship for ST students pursuing M.Phil and Ph.D. research programs under UGC.",
        "ministry": "Ministry of Tribal Affairs",
        "benefit_amount": "Upto ₹31,000/month (JRF) / ₹35,000/month (SRF)",
        "education_level": "M.Phil / Ph.D.",
    },
]

# Applications for Student A (Arjun Munda)
DEMO_APPLICATION_ID = "00000000-0000-0000-0000-000000000020"
DEMO_APPLICATION_ID_2 = "00000000-0000-0000-0000-000000000021"
DEMO_APPLICATION_ID_3 = "00000000-0000-0000-0000-000000000022"

# Application for Student B (Sunita Soren: manual-review / deficiency demo)
DEMO_APPLICATION_ID_4 = "00000000-0000-0000-0000-000000000023"

# Application for Student C (Birsa Kerketta: completed NFST fellowship / credited DBT demo)
DEMO_APPLICATION_ID_5 = "00000000-0000-0000-0000-000000000024"

DEMO_DOCUMENTS = [
    {
        "id": "00000000-0000-0000-0000-000000000030",
        "student_id": DEMO_STUDENT_ID,
        "document_type": "MOCK_ST_CERTIFICATE",
        "document_name": "ST Certificate",
        "status": "PENDING",
    },
    {
        "id": "00000000-0000-0000-0000-000000000031",
        "student_id": DEMO_STUDENT_ID,
        "document_type": "TEST_VERIFIED",
        "document_name": "Verified Marksheet",
        "status": "PENDING",
    },
    {
        "id": "00000000-0000-0000-0000-000000000032",
        "student_id": DEMO_STUDENT_ID,
        "document_type": "TEST_MISMATCH",
        "document_name": "Income Certificate Demo",
        "status": "PENDING",
    },
    {
        "id": "00000000-0000-0000-0000-000000000033",
        "student_id": DEMO_STUDENT_ID,
        "document_type": "TEST_UNAVAILABLE",
        "document_name": "Domicile Certificate Demo",
        "status": "PENDING",
    },
    {
        "id": "00000000-0000-0000-0000-000000000034",
        "student_id": DEMO_STUDENT_ID_3,
        "document_type": "STATE_EDISTRICT_INCOME",
        "document_name": "State e-District Income Record",
        "status": "MISMATCH",
    },
    {
        "id": "00000000-0000-0000-0000-000000000035",
        "student_id": DEMO_STUDENT_ID_4,
        "document_type": "UGC_NET_JRF_AWARD",
        "document_name": "UGC NET-JRF Award Letter",
        "status": "VERIFIED",
    },
]

DEMO_VERIFICATION_ID = "00000000-0000-0000-0000-000000000040"
DEMO_VERIFICATION_ID_2 = "00000000-0000-0000-0000-000000000042"
DEMO_MANUAL_REVIEW_ID = "00000000-0000-0000-0000-000000000045"

DEMO_NOTIFICATIONS = [
    {
        "id": "00000000-0000-0000-0000-000000000050",
        "student_id": DEMO_STUDENT_ID,
        "application_id": DEMO_APPLICATION_ID,
        "title": "Application Submitted",
        "message": "Your Post-Matric Scholarship application has been successfully submitted.",
        "category": "APPLICATION_SUBMITTED",
        "is_read": True,
    },
    {
        "id": "00000000-0000-0000-0000-000000000051",
        "student_id": DEMO_STUDENT_ID,
        "application_id": DEMO_APPLICATION_ID,
        "title": "Verification Completed",
        "message": "Aadhaar e-KYC and digital documents verified via DigiLocker adapter.",
        "category": "VERIFICATION_COMPLETED",
        "is_read": False,
    },
    {
        "id": "00000000-0000-0000-0000-000000000052",
        "student_id": DEMO_STUDENT_ID_3,
        "application_id": DEMO_APPLICATION_ID_4,
        "title": "Deficiency Raised",
        "message": "Income certificate mismatch detected against State e-District database.",
        "category": "DEFICIENCY_RAISED",
        "is_read": False,
    },
    {
        "id": "00000000-0000-0000-0000-000000000053",
        "student_id": DEMO_STUDENT_ID_3,
        "application_id": DEMO_APPLICATION_ID_4,
        "title": "Action Required: Re-upload Document",
        "message": "Please upload a valid Tehsildar income certificate or clarification affidavit.",
        "category": "ACTION_REQUIRED",
        "is_read": False,
    },
    {
        "id": "00000000-0000-0000-0000-000000000054",
        "student_id": DEMO_STUDENT_ID_3,
        "application_id": DEMO_APPLICATION_ID_4,
        "title": "Manual Review Pending",
        "message": "Application forwarded to District Welfare Officer for manual verification.",
        "category": "MANUAL_REVIEW",
        "is_read": False,
    },
    {
        "id": "00000000-0000-0000-0000-000000000055",
        "student_id": DEMO_STUDENT_ID,
        "application_id": DEMO_APPLICATION_ID_2,
        "title": "Scholarship Sanctioned",
        "message": "Your Pre-Matric Scholarship has been sanctioned by the MoTA committee.",
        "category": "SANCTIONED",
        "is_read": False,
    },
    {
        "id": "00000000-0000-0000-0000-000000000056",
        "student_id": DEMO_STUDENT_ID,
        "application_id": DEMO_APPLICATION_ID_2,
        "title": "Payment Initiated",
        "message": "Direct Benefit Transfer initiated via PFMS mock gateway (Ref: DBT-2026-PM-9481).",
        "category": "PAYMENT_INITIATED",
        "is_read": False,
    },
    {
        "id": "00000000-0000-0000-0000-000000000057",
        "student_id": DEMO_STUDENT_ID_4,
        "application_id": DEMO_APPLICATION_ID_5,
        "title": "Payment Credited via DBT",
        "message": "National Fellowship stipend of ₹31,000 credited to Aadhaar-linked account (Ref: DBT-2026-NFST-8821).",
        "category": "PAYMENT_CREDITED",
        "is_read": False,
    },
]

DEMO_TIMELINE_EVENTS = [
    # Student A: Application 1 (DRAFT)
    {
        "id": "00000000-0000-0000-0000-000000000060",
        "application_id": DEMO_APPLICATION_ID,
        "status": "DRAFT",
        "message": "Application drafted by student",
        "created_at": datetime(2026, 9, 20, 10, 0, 0),
    },
    # Student A: Application 2 (SANCTIONED / PAYMENT PROCESSING)
    {
        "id": "00000000-0000-0000-0000-000000000061",
        "application_id": DEMO_APPLICATION_ID_2,
        "status": "DRAFT",
        "message": "Application drafted by student",
        "created_at": datetime(2026, 8, 15, 10, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000062",
        "application_id": DEMO_APPLICATION_ID_2,
        "status": "SUBMITTED",
        "message": "Application submitted for institutional verification",
        "created_at": datetime(2026, 8, 18, 11, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000063",
        "application_id": DEMO_APPLICATION_ID_2,
        "status": "IN_VERIFICATION",
        "message": "Documents verified via DigiLocker mock adapter",
        "created_at": datetime(2026, 8, 20, 14, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000064",
        "application_id": DEMO_APPLICATION_ID_2,
        "status": "SANCTIONED",
        "message": "Application sanctioned after verification",
        "created_at": datetime(2026, 8, 25, 15, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000065",
        "application_id": DEMO_APPLICATION_ID_2,
        "status": "PAYMENT_INITIATED",
        "message": "Direct Benefit Transfer initiated via PFMS mock gateway (Ref: DBT-2026-PM-9481)",
        "created_at": datetime(2026, 9, 1, 9, 30, 0),
    },
    # Student A: Application 3 (DEFICIENCY)
    {
        "id": "00000000-0000-0000-0000-000000000066",
        "application_id": DEMO_APPLICATION_ID_3,
        "status": "DRAFT",
        "message": "Application drafted by student",
        "created_at": datetime(2026, 9, 18, 10, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000067",
        "application_id": DEMO_APPLICATION_ID_3,
        "status": "DEFICIENCY",
        "message": "Application flagged for document deficiency",
        "created_at": datetime(2026, 9, 21, 11, 0, 0),
    },
    # Student B: Application 4 (DEFICIENCY / RESUBMITTED / MANUAL_REVIEW)
    {
        "id": "00000000-0000-0000-0000-000000000068",
        "application_id": DEMO_APPLICATION_ID_4,
        "status": "DRAFT",
        "message": "Application drafted by student",
        "created_at": datetime(2026, 9, 1, 10, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000069",
        "application_id": DEMO_APPLICATION_ID_4,
        "status": "SUBMITTED",
        "message": "Application submitted by student",
        "created_at": datetime(2026, 9, 3, 11, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000070",
        "application_id": DEMO_APPLICATION_ID_4,
        "status": "IN_VERIFICATION",
        "message": "Automated verification initiated via State e-District adapter",
        "created_at": datetime(2026, 9, 5, 14, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000071",
        "application_id": DEMO_APPLICATION_ID_4,
        "status": "DEFICIENCY",
        "message": "Application flagged for income certificate deficiency",
        "created_at": datetime(2026, 9, 8, 10, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000072",
        "application_id": DEMO_APPLICATION_ID_4,
        "status": "RESUBMITTED",
        "message": "Student uploaded clarification affidavit and updated certificate",
        "created_at": datetime(2026, 9, 12, 16, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000073",
        "application_id": DEMO_APPLICATION_ID_4,
        "status": "MANUAL_REVIEW",
        "message": "Forwarded to District Welfare Officer for manual verification",
        "created_at": datetime(2026, 9, 15, 11, 0, 0),
    },
    # Student C: Application 5 (COMPLETED / NFST)
    {
        "id": "00000000-0000-0000-0000-000000000074",
        "application_id": DEMO_APPLICATION_ID_5,
        "status": "DRAFT",
        "message": "Research fellowship application drafted",
        "created_at": datetime(2026, 5, 10, 10, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000075",
        "application_id": DEMO_APPLICATION_ID_5,
        "status": "SUBMITTED",
        "message": "Application submitted with UGC NET-JRF certificate",
        "created_at": datetime(2026, 5, 15, 11, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000076",
        "application_id": DEMO_APPLICATION_ID_5,
        "status": "IN_VERIFICATION",
        "message": "UGC/NTA & University admission credentials verified",
        "created_at": datetime(2026, 5, 20, 14, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000077",
        "application_id": DEMO_APPLICATION_ID_5,
        "status": "SANCTIONED",
        "message": "MoTA National Fellowship award sanctioned (JRF ₹31,000/month)",
        "created_at": datetime(2026, 6, 1, 10, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000078",
        "application_id": DEMO_APPLICATION_ID_5,
        "status": "PAYMENT_INITIATED",
        "message": "Quarterly research stipend payment initiated (Ref: PFMS-NFST-2026-771)",
        "created_at": datetime(2026, 6, 5, 9, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000079",
        "application_id": DEMO_APPLICATION_ID_5,
        "status": "DBT_SENT",
        "message": "Direct Benefit Transfer sent to NPCI clearinghouse",
        "created_at": datetime(2026, 6, 7, 12, 0, 0),
    },
    {
        "id": "00000000-0000-0000-0000-000000000080",
        "application_id": DEMO_APPLICATION_ID_5,
        "status": "COMPLETED",
        "message": "Direct Benefit Transfer credited successfully. Fellowship tenure ongoing.",
        "created_at": datetime(2026, 6, 8, 15, 30, 0),
    },
]


def seed_database(db: Session, reset: bool = False) -> dict:
    """Idempotently seed deterministic demo/synthetic data for frontend and local integration.
    
    If reset=True, previously seeded demo records will be deleted first.
    """
    admin_email = os.getenv("ADMIN_EMAIL", "").strip()

    if reset:
        # Delete child records first in dependency order
        db.query(Notification).filter(Notification.id.like("00000000-0000-0000-0000-%")).delete(synchronize_session=False)
        db.query(ApplicationTimeline).filter(ApplicationTimeline.id.like("00000000-0000-0000-0000-%")).delete(synchronize_session=False)
        db.query(ManualReview).filter(ManualReview.id.like("00000000-0000-0000-0000-%")).delete(synchronize_session=False)
        db.query(VerificationRecord).filter(VerificationRecord.id.like("00000000-0000-0000-0000-%")).delete(synchronize_session=False)
        db.query(ApplicationDocument).filter(ApplicationDocument.application_id.like("00000000-0000-0000-0000-%")).delete(synchronize_session=False)
        db.query(Application).filter(Application.id.like("00000000-0000-0000-0000-%")).delete(synchronize_session=False)
        db.query(Document).filter(Document.id.like("00000000-0000-0000-0000-%")).delete(synchronize_session=False)
        for s in DEMO_SCHOLARSHIPS:
            db.query(Scholarship).filter(Scholarship.code == s["code"]).delete(synchronize_session=False)
        db.query(Student).filter(Student.id.in_([DEMO_STUDENT_ID, DEMO_STUDENT_ID_2, DEMO_STUDENT_ID_3, DEMO_STUDENT_ID_4])).delete(synchronize_session=False)
        db.query(User).filter(User.id.in_([DEMO_USER_ID, DEMO_USER_ID_2, DEMO_USER_ID_3, DEMO_USER_ID_4, DEMO_ADMIN_USER_ID])).delete(synchronize_session=False)
        if admin_email:
            db.query(User).filter(User.email == admin_email).delete(synchronize_session=False)
        legacy_u = db.query(User).filter(User.email == "admin.mota@tribalsetu.gov.in").first()
        if legacy_u and (not admin_email or admin_email != "admin.mota@tribalsetu.gov.in"):
            legacy_u.role = "STUDENT"
            legacy_u.password = hash_password(secrets.token_urlsafe(32))
        db.commit()

    created_counts = {
        "users": 0,
        "students": 0,
        "scholarships": 0,
        "applications": 0,
        "documents": 0,
        "application_documents": 0,
        "verification_records": 0,
        "manual_reviews": 0,
        "notifications": 0,
        "application_timeline": 0,
    }

    # 1. Users
    user_definitions = [
        (DEMO_USER_ID, "Demo Student User", "demo.student@example.com", "STUDENT"),
        (DEMO_USER_ID_2, "Demo Student Two", "demo.student2@example.com", "STUDENT"),
        (DEMO_USER_ID_3, "Sunita Soren", "demo.student3@example.com", "STUDENT"),
        (DEMO_USER_ID_4, "Birsa Kerketta", "demo.student4@example.com", "STUDENT"),
    ]
    if admin_email:
        user_definitions.append(
            (DEMO_ADMIN_USER_ID, "MoTA Admin Officer", admin_email, "ADMIN")
        )
    else:
        logger.info("ADMIN_EMAIL environment variable is not set; skipping admin user creation.")

    users = {}
    for uid, name, email, role in user_definitions:
        unusable_password = hash_password(secrets.token_urlsafe(32))
        u = db.query(User).filter(User.id == uid).first()
        if not u:
            u_by_email = db.query(User).filter(User.email == email).first()
            if not u_by_email:
                u = User(id=uid, name=name, email=email, password=unusable_password, role=role)
                db.add(u)
                db.flush()
                created_counts["users"] += 1
            else:
                u = u_by_email
                u.name = name
                u.role = role
                u.password = unusable_password
        else:
            u.email = email
            u.name = name
            u.role = role
            u.password = unusable_password
        users[uid] = u

    # Always demote legacy admin.mota@tribalsetu.gov.in to STUDENT with a random password; never delete it
    legacy_admin = db.query(User).filter(User.email == "admin.mota@tribalsetu.gov.in").first()
    if legacy_admin and (not admin_email or admin_email != "admin.mota@tribalsetu.gov.in"):
        legacy_admin.role = "STUDENT"
        legacy_admin.password = hash_password(secrets.token_urlsafe(32))

    # 2. Students
    student_definitions = [
        (DEMO_STUDENT_ID, DEMO_USER_ID, "Demo Student User", "demo.student@example.com"),
        (DEMO_STUDENT_ID_2, DEMO_USER_ID_2, "Demo Student Two", "demo.student2@example.com"),
        (DEMO_STUDENT_ID_3, DEMO_USER_ID_3, "Sunita Soren", "demo.student3@example.com"),
        (DEMO_STUDENT_ID_4, DEMO_USER_ID_4, "Birsa Kerketta", "demo.student4@example.com"),
    ]

    students = {}
    for sid, uid, name, email in student_definitions:
        st = db.query(Student).filter(Student.id == sid).first()
        if not st:
            st_by_email = db.query(Student).filter(Student.email == email).first()
            if not st_by_email:
                st = Student(id=sid, user_id=users[uid].id, name=name, email=email)
                db.add(st)
                db.flush()
                created_counts["students"] += 1
            else:
                st = st_by_email
        students[sid] = st

    # 3. Scholarships (all 5 schemes)
    for s_data in DEMO_SCHOLARSHIPS:
        existing = db.query(Scholarship).filter(Scholarship.code == s_data["code"]).first()
        if not existing:
            scholarship = Scholarship(
                id=s_data["id"],
                code=s_data["code"],
                name=s_data["name"],
                description=s_data.get("description"),
                ministry=s_data.get("ministry"),
                benefit_amount=s_data.get("benefit_amount"),
                education_level=s_data.get("education_level"),
            )
            db.add(scholarship)
            db.flush()
            created_counts["scholarships"] += 1

    # 4. Applications
    # 4a. Student A: Primary application (DRAFT) - Post-Matric
    app = db.query(Application).filter(Application.id == DEMO_APPLICATION_ID).first()
    if not app:
        app = Application(
            id=DEMO_APPLICATION_ID,
            student_id=students[DEMO_STUDENT_ID].id,
            scholarship_id=DEMO_SCHOLARSHIPS[0]["id"],
            status="DRAFT",
        )
        db.add(app)
        db.flush()
        created_counts["applications"] += 1

    # 4b. Student A: Sanctioned application - Pre-Matric (payment/DBT demo)
    app2 = db.query(Application).filter(Application.id == DEMO_APPLICATION_ID_2).first()
    if not app2:
        app2 = Application(
            id=DEMO_APPLICATION_ID_2,
            student_id=students[DEMO_STUDENT_ID].id,
            scholarship_id=DEMO_SCHOLARSHIPS[1]["id"],
            status="SANCTIONED",
        )
        db.add(app2)
        db.flush()
        created_counts["applications"] += 1

    # 4c. Student A: Deficiency application - Top Class Education
    app3 = db.query(Application).filter(Application.id == DEMO_APPLICATION_ID_3).first()
    if not app3:
        app3 = Application(
            id=DEMO_APPLICATION_ID_3,
            student_id=students[DEMO_STUDENT_ID].id,
            scholarship_id=DEMO_SCHOLARSHIPS[3]["id"],
            status="DEFICIENCY",
        )
        db.add(app3)
        db.flush()
        created_counts["applications"] += 1

    # 4d. Student B: Manual review application - Top Class Education
    app4 = db.query(Application).filter(Application.id == DEMO_APPLICATION_ID_4).first()
    if not app4:
        app4 = Application(
            id=DEMO_APPLICATION_ID_4,
            student_id=students[DEMO_STUDENT_ID_3].id,
            scholarship_id=DEMO_SCHOLARSHIPS[3]["id"],
            status="MANUAL_REVIEW",
        )
        db.add(app4)
        db.flush()
        created_counts["applications"] += 1

    # 4e. Student C: Completed fellowship application - NFST (credited DBT demo)
    app5 = db.query(Application).filter(Application.id == DEMO_APPLICATION_ID_5).first()
    if not app5:
        app5 = Application(
            id=DEMO_APPLICATION_ID_5,
            student_id=students[DEMO_STUDENT_ID_4].id,
            scholarship_id=DEMO_SCHOLARSHIPS[4]["id"],
            status="COMPLETED",
        )
        db.add(app5)
        db.flush()
        created_counts["applications"] += 1

    # 5. Documents
    for d_data in DEMO_DOCUMENTS:
        doc = db.query(Document).filter(Document.id == d_data["id"]).first()
        if not doc:
            doc = Document(
                id=d_data["id"],
                student_id=d_data["student_id"],
                document_type=d_data["document_type"],
                document_name=d_data["document_name"],
                status=d_data["status"],
            )
            db.add(doc)
            db.flush()
            created_counts["documents"] += 1

    # 6. Application Documents Link
    # 6a. App 1 links docs 0, 1 (Student A)
    for d_data in DEMO_DOCUMENTS[:2]:
        link = (
            db.query(ApplicationDocument)
            .filter(
                ApplicationDocument.application_id == DEMO_APPLICATION_ID,
                ApplicationDocument.document_id == d_data["id"],
            )
            .first()
        )
        if not link:
            link = ApplicationDocument(
                application_id=DEMO_APPLICATION_ID,
                document_id=d_data["id"],
            )
            db.add(link)
            db.flush()
            created_counts["application_documents"] += 1

    # 6b. App 3 links mismatch doc (demo 2) for Student A
    link_mismatch = (
        db.query(ApplicationDocument)
        .filter(
            ApplicationDocument.application_id == DEMO_APPLICATION_ID_3,
            ApplicationDocument.document_id == DEMO_DOCUMENTS[2]["id"],
        )
        .first()
    )
    if not link_mismatch:
        link_mismatch = ApplicationDocument(
            application_id=DEMO_APPLICATION_ID_3,
            document_id=DEMO_DOCUMENTS[2]["id"],
        )
        db.add(link_mismatch)
        db.flush()
        created_counts["application_documents"] += 1

    # 6c. App 4 links state edistrict income doc (demo 4) for Student B
    link_income = (
        db.query(ApplicationDocument)
        .filter(
            ApplicationDocument.application_id == DEMO_APPLICATION_ID_4,
            ApplicationDocument.document_id == DEMO_DOCUMENTS[4]["id"],
        )
        .first()
    )
    if not link_income:
        link_income = ApplicationDocument(
            application_id=DEMO_APPLICATION_ID_4,
            document_id=DEMO_DOCUMENTS[4]["id"],
        )
        db.add(link_income)
        db.flush()
        created_counts["application_documents"] += 1

    # 6d. App 5 links UGC NET award letter (demo 5) for Student C
    link_award = (
        db.query(ApplicationDocument)
        .filter(
            ApplicationDocument.application_id == DEMO_APPLICATION_ID_5,
            ApplicationDocument.document_id == DEMO_DOCUMENTS[5]["id"],
        )
        .first()
    )
    if not link_award:
        link_award = ApplicationDocument(
            application_id=DEMO_APPLICATION_ID_5,
            document_id=DEMO_DOCUMENTS[5]["id"],
        )
        db.add(link_award)
        db.flush()
        created_counts["application_documents"] += 1

    # 7. Verification Records
    verif = (
        db.query(VerificationRecord)
        .filter(VerificationRecord.id == DEMO_VERIFICATION_ID)
        .first()
    )
    if not verif:
        verif = VerificationRecord(
            id=DEMO_VERIFICATION_ID,
            application_id=DEMO_APPLICATION_ID,
            document_id=DEMO_DOCUMENTS[0]["id"],
            status="PENDING",
        )
        db.add(verif)
        db.flush()
        created_counts["verification_records"] += 1

    verif2 = (
        db.query(VerificationRecord)
        .filter(VerificationRecord.id == DEMO_VERIFICATION_ID_2)
        .first()
    )
    if not verif2:
        verif2 = VerificationRecord(
            id=DEMO_VERIFICATION_ID_2,
            application_id=DEMO_APPLICATION_ID_4,
            document_id=DEMO_DOCUMENTS[4]["id"],
            status="MISMATCH",
        )
        db.add(verif2)
        db.flush()
        created_counts["verification_records"] += 1

    # 8. Manual Review Record
    review = (
        db.query(ManualReview)
        .filter(ManualReview.id == DEMO_MANUAL_REVIEW_ID)
        .first()
    )
    if not review:
        review = ManualReview(
            id=DEMO_MANUAL_REVIEW_ID,
            application_id=DEMO_APPLICATION_ID_4,
            verification_id=DEMO_VERIFICATION_ID_2,
            status="OPEN",
        )
        db.add(review)
        db.flush()
        created_counts["manual_reviews"] += 1


    # 9. Notifications
    for n_data in DEMO_NOTIFICATIONS:
        notif = (
            db.query(Notification)
            .filter(Notification.id == n_data["id"])
            .first()
        )
        if not notif:
            notif = Notification(
                id=n_data["id"],
                student_id=n_data["student_id"],
                application_id=n_data["application_id"],
                title=n_data["title"],
                message=n_data["message"],
                category=n_data["category"],
                is_read=n_data["is_read"],
            )
            db.add(notif)
            db.flush()
            created_counts["notifications"] += 1

    # 10. Application Timeline
    for t_data in DEMO_TIMELINE_EVENTS:
        timeline_entry = (
            db.query(ApplicationTimeline)
            .filter(ApplicationTimeline.id == t_data["id"])
            .first()
        )
        if not timeline_entry:
            timeline_entry = ApplicationTimeline(
                id=t_data["id"],
                application_id=t_data["application_id"],
                status=t_data["status"],
                message=t_data["message"],
                created_at=t_data["created_at"],
            )
            db.add(timeline_entry)
            db.flush()
            created_counts["application_timeline"] += 1

    db.commit()
    return created_counts



def main():
    parser = argparse.ArgumentParser(description="Seed database with synthetic demo data")
    parser.add_argument("--reset", action="store_true", help="Reset existing seeded demo records")
    args = parser.parse_args()

    db = SessionLocal()
    try:
        results = seed_database(db, reset=args.reset)
        print("Database seeded successfully:")
        for model_name, count in results.items():
            print(f"  - {model_name}: {count} new record(s)")
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        db.close()


if __name__ == "__main__":
    main()
