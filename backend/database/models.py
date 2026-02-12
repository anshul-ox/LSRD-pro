from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Text, DateTime, Float
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, nullable=True)
    first_access = Column(DateTime, default=datetime.utcnow)
    last_access = Column(DateTime, default=datetime.utcnow)
    total_requests = Column(Integer, default=1)
    is_active = Column(Boolean, default=True)

    validations = relationship("Validation", back_populates="owner")


class Validation(Base):
    __tablename__ = "validations"

    id = Column(Integer, primary_key=True, index=True)
    validation_id = Column(String, unique=True, index=True, nullable=False)
    user_id = Column(String, ForeignKey("users.user_id"))
    status = Column(String, default="processing")
    file_count = Column(Integer)
    
    # Results
    is_completely_verified = Column(Boolean, nullable=True)
    overall_confidence = Column(Float, nullable=True)
    verification_status = Column(String, nullable=True)
    risk_level = Column(String, nullable=True)
    result_json = Column(Text, nullable=True)  # Store full JSON response
    
    created_at = Column(DateTime, default=datetime.utcnow)

    owner = relationship("User", back_populates="validations")


class APILog(Base):
    __tablename__ = "api_logs"

    id = Column(Integer, primary_key=True, index=True)
    endpoint = Column(String, nullable=False)
    method = Column(String, nullable=False)
    user_id = Column(String, nullable=True)
    response_status = Column(Integer, nullable=True)
    response_time = Column(Float, nullable=True)  # In seconds
    created_at = Column(DateTime, default=datetime.utcnow)
