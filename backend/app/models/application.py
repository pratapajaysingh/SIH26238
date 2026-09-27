from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base
import uuid


class Application(Base):
    __tablename__ = "applications"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    student_id = Column(String, ForeignKey("students.id"), nullable=False)
    scholarship_id = Column(String, ForeignKey("scholarships.id"), nullable=False)
    status = Column(String, nullable=False, default="DRAFT")

    timeline_events = relationship(
        "ApplicationTimeline",
        back_populates="application",
        cascade="all, delete-orphan",
        order_by="ApplicationTimeline.created_at",
    )

