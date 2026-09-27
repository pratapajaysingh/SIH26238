import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey
from app.core.database import Base


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    student_id = Column(String, ForeignKey("students.id"), nullable=False)
    application_id = Column(String, ForeignKey("applications.id"), nullable=True)
    title = Column(String, nullable=False)
    message = Column(String, nullable=False)
    category = Column(String, nullable=False, default="APPLICATION_UPDATE")
    is_read = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
