from sqlalchemy.orm import Session
from . import models
from datetime import datetime
import json

def get_user(db: Session, user_id: str):
    return db.query(models.User).filter(models.User.user_id == user_id).first()

def get_or_create_user(db: Session, user_id: str, email: str = None):
    db_user = get_user(db, user_id)
    if db_user:
        db_user.last_access = datetime.utcnow()
        db_user.total_requests += 1
        db.commit()
        db.refresh(db_user)
        return db_user
    
    new_user = models.User(user_id=user_id, email=email)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

def create_validation(db: Session, validation_id: str, user_id: str, file_count: int):
    db_validation = models.Validation(
        validation_id=validation_id,
        user_id=user_id,
        file_count=file_count,
        status="processing"
    )
    db.add(db_validation)
    db.commit()
    db.refresh(db_validation)
    return db_validation

def update_validation(db: Session, validation_id: str, report_data: dict):
    db_validation = db.query(models.Validation).filter(models.Validation.validation_id == validation_id).first()
    if db_validation:
        db_validation.status = "completed"
        db_validation.is_completely_verified = report_data.get("is_completely_verified")
        db_validation.overall_confidence = report_data.get("overall_confidence")
        db_validation.verification_status = report_data.get("verification_status")
        db_validation.risk_level = report_data.get("risk_level")
        db_validation.result_json = json.dumps(report_data)
        db.commit()
        db.refresh(db_validation)
    return db_validation

def get_user_validations(db: Session, user_id: str, limit: int = 50):
    return db.query(models.Validation).filter(models.Validation.user_id == user_id).order_by(models.Validation.created_at.desc()).limit(limit).all()

def log_api_request(db: Session, endpoint: str, method: str, user_id: str, status: int, time_taken: float):
    db_log = models.APILog(
        endpoint=endpoint,
        method=method,
        user_id=user_id,
        response_status=status,
        response_time=time_taken
    )
    db.add(db_log)
    db.commit()
