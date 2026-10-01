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
from app.models.otp_token import OtpToken

__all__ = [
    "User",
    "Student",
    "Scholarship",
    "Application",
    "ApplicationTimeline",
    "Document",
    "ApplicationDocument",
    "VerificationRecord",
    "ManualReview",
    "Notification",
    "OtpToken",
]



