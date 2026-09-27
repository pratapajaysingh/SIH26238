from datetime import datetime
import uuid
from sqlalchemy import Column, DateTime, ForeignKey, String
from sqlalchemy.orm import relationship

from app.core.database import Base


class ApplicationTimeline(Base):
    __tablename__ = "application_timeline"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    application_id = Column(String, ForeignKey("applications.id"), nullable=False)
    status = Column(String, nullable=False)
    message = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    application = relationship("Application", back_populates="timeline_events")
