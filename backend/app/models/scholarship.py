from sqlalchemy import Column, String
from app.core.database import Base
import uuid


class Scholarship(Base):
    __tablename__ = "scholarships"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    code = Column(String, unique=True, nullable=False)
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)
    ministry = Column(String, nullable=True)
    benefit_amount = Column(String, nullable=True)
    education_level = Column(String, nullable=True)
