from database.database import SessionLocal
from database import models
import os

# Ensure we use the same path logic
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(os.path.dirname(BASE_DIR), "data")
DB_PATH = os.path.join(DATA_DIR, "validations.db")

print(f"Checking database at: {DB_PATH}")
print(f"File exists: {os.path.exists(DB_PATH)}")

db = SessionLocal()

print("\n--- USERS ---")
users = db.query(models.User).all()
for u in users:
    print(f"ID: {u.id}, UserID: {u.user_id}, Total Requests: {u.total_requests}")

print("\n--- VALIDATIONS ---")
validations = db.query(models.Validation).all()
for v in validations:
    print(f"ID: {v.id}, ValID: {v.validation_id}, UserID: {v.user_id}, Status: {v.status}")

db.close()
