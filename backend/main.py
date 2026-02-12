from fastapi import FastAPI, File, UploadFile, HTTPException, Form, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
import google.generativeai as genai
import json
import os
import tempfile
import logging
from datetime import datetime
import magic
import hashlib
import time
import uuid

# Database Imports
from database.database import engine, Base, get_db
from database import crud, models

# Setup logging
logging.basicConfig(level=logging.INFO, filename='server.log', filemode='a', format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Ensure data directory exists
DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
if not os.path.exists(DATA_DIR):
    os.makedirs(DATA_DIR)

# Create tables on startup
try:
    Base.metadata.create_all(bind=engine)
    logger.info("Database tables created successfully.")
except Exception as e:
    logger.error(f"Error creating database tables: {e}")

app = FastAPI(
    title="LSR Document Intelligence API",
    description="AI-Powered Document Cross-Validation & Verification System",
    version="2.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Gemini Configuration
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyAFAFdGR842HI_p0O4NjoKTEr_BE1btwcI")
if not GEMINI_API_KEY:
    logger.warning("GEMINI_API_KEY environment variable not set. Please set it to use Gemini features.")

# Configure Gemini
genai.configure(api_key=GEMINI_API_KEY)

# Use Gemini Flash Latest for better availability/quota
model = genai.GenerativeModel(
    model_name='gemini-flash-latest',
    generation_config={
        "temperature": 0.1,  # Low for consistent results
        "top_p": 0.95,
        "top_k": 40,
        "max_output_tokens": 8192,
        "response_mime_type": "application/json",
    }
)

# ============== DATA MODELS ==============

class DocumentAnalysis(BaseModel):
    document_type: str = "Unknown"
    extracted_entities: Dict[str, Any] = {}
    confidence: float = 0.0
    tampering_indicators: List[str] = []
    authenticity_score: float = 0.0

class CrossValidationResult(BaseModel):
    field_name: str
    document_1_value: str
    document_2_value: str
    document_3_value: Optional[str] = None
    match_status: str  # EXACT_MATCH, PARTIAL_MATCH, MISMATCH, MISSING
    confidence: float
    notes: str

class VerificationReport(BaseModel):
    validation_id: Optional[str] = None # Added field
    is_completely_verified: bool = Field(..., description="All checks passed")
    overall_confidence: float = Field(..., ge=0, le=100)
    verification_status: str  # VERIFIED, SUSPECTED, REJECTED
    risk_level: str  # LOW, MEDIUM, HIGH, CRITICAL
    
    # Individual document analysis
    document_1_analysis: DocumentAnalysis
    document_2_analysis: Optional[DocumentAnalysis] = None
    document_3_analysis: Optional[DocumentAnalysis] = None
    
    # Cross-validation results
    cross_validations: List[CrossValidationResult]
    
    # Summary
    total_checks: int
    passed_checks: int
    failed_checks: int
    warning_checks: int
    
    # Detailed findings
    exact_matches: List[str]
    partial_matches: List[str]
    discrepancies: List[str]
    missing_information: List[str]
    red_flags: List[str]
    
    # Recommendations
    verification_summary: str
    recommendations: str
    next_steps: List[str]
    
    # Metadata
    processing_timestamp: str
    gemini_model_used: str

# ============== PROMPT ENGINE ==============

def build_master_prompt(file_names: List[str]) -> str:
    """
    MASTER PROMPT - Complete instruction set for Gemini
    """
    
    prompt = f"""You are an expert **Forensic Document Examiner** and **Legal Compliance Officer** with 20+ years of experience. Your task is to perform **DEEP MULTI-LAYER VALIDATION** on {len(file_names)} uploaded documents.

## 🎯 PRIMARY OBJECTIVE
Perform cross-document verification to detect:
- Identity fraud
- Document forgery
- Data inconsistencies
- Missing critical information
- Logical impossibilities

## 📋 DOCUMENTS RECEIVED
{chr(10).join([f"{i+1}. {name}" for i, name in enumerate(file_names)])}

---

## 🔍 LAYER 1: INDIVIDUAL DOCUMENT ANALYSIS (Each Document)

For EACH document, extract and analyze:

### 1. Document Classification
- Exact document type (Invoice, Contract, ID Proof, Bank Statement, etc.)
- Issuing authority
- Document date & validity period
- Document number/ID

### 2. Entity Extraction (Structured Data)
Extract ALL entities in structured format:
- Person names (full name as written)
- Date of birth (YYYY-MM-DD)
- Document/Registration numbers
- Issue and Expiry dates
- Addresses (complete)
- Contact info (phone/email)
- Monetary values (amounts with currency)
- Signatories and Witnesses
- Organization names
- Jurisdiction

### 3. Forensic Checks
- Check for font inconsistencies
- Detect digital tampering traces
- Verify checksums of ID numbers (if applicable logic is known)
- Validate logical consistency of dates (e.g., Issue Date < Expiry Date)

## 🔄 LAYER 2: CROSS-VALIDATION (Between Documents)

Compare specific fields across ALL documents (e.g. Document 1 vs Document 2).
For each common field (Name, DOB, Address, etc.):
- Determine `match_status`: EXACT_MATCH, PARTIAL_MATCH, MISMATCH, MISSING
- Calculate `confidence` score for the match
- Add `notes` explaining any discrepancy

## 📊 LAYER 3: RISK ASSESSMENT

- Determine `verification_status`: VERIFIED, SUSPECTED, REJECTED
- Assign `risk_level`: LOW, MEDIUM, HIGH, CRITICAL
- Summarize red flags, discrepancies, and missing info

---

## 📤 OUTPUT FORMAT
You must return a single JSON object that strictly adheres to the schema of the `VerificationReport` model provided below.
Ensure all boolean values are true/false (lowercase in JSON), and floats are numbers.

SCHEMA STRUCTURE:
{{
  "is_completely_verified": bool,
  "overall_confidence": float (0-100),
  "verification_status": "VERIFIED" | "SUSPECTED" | "REJECTED",
  "risk_level": "LOW" | "MEDIUM" | "HIGH" | "CRITICAL",
  "document_1_analysis": {{ ... }},
  "document_2_analysis": {{ ... }} (if applicable),
  "document_3_analysis": {{ ... }} (if applicable),
  "cross_validations": [
    {{
      "field_name": "Name",
      "document_1_value": "John Doe",
      "document_2_value": "Jon Doe",
      "match_status": "PARTIAL_MATCH",
      "confidence": 85.0,
      "notes": "Minor spelling difference"
    }}
  ],
  "total_checks": int,
  "passed_checks": int,
  "failed_checks": int,
  "warning_checks": int,
  "exact_matches": ["List of field names"],
  "partial_matches": ["List of field names"],
  "discrepancies": ["Description of discrepancies"],
  "missing_information": ["List of missing fields"],
  "red_flags": ["List of major issues"],
  "verification_summary": "Executive summary of findings",
  "recommendations": "Actionable advice",
  "next_steps": ["Step 1", "Step 2"],
  "processing_timestamp": "ISO 8601 string",
  "gemini_model_used": "gemini-flash-latest"
}}
"""
    return prompt

# ============== ENDPOINTS ==============

@app.post("/analyze-documents", response_model=VerificationReport)
async def analyze_documents(
    files: List[UploadFile] = File(...),
    user_id: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    """
    Uploads multiple documents (PDFs/Images) and performs AI-powered cross-validation.
    Tracks user activity and stores validation results in database.
    """
    start_time = time.time()
    
    # Generate Validation ID
    validation_id = f"VAL_{datetime.now().strftime('%Y%m%d')}_{uuid.uuid4().hex[:8]}"
    
    # Handle user tracking
    if not user_id:
        user_id = "guest_user"
    
    try:
        # Create/Update user
        crud.get_or_create_user(db, user_id)
        
        # Create initial validation record
        crud.create_validation(db, validation_id, user_id, len(files))
        
    except Exception as e:
        logger.error(f"Database error during user/validation creation: {e}")
        # Continue execution even if DB logging fails, but log it
    
    if not GEMINI_API_KEY:
        error_msg = "Gemini API Key is not configured on the server."
        crud.log_api_request(db, "/analyze-documents", "POST", user_id, 500, time.time() - start_time)
        raise HTTPException(status_code=500, detail=error_msg)

    if len(files) < 1:
        crud.log_api_request(db, "/analyze-documents", "POST", user_id, 400, time.time() - start_time)
        raise HTTPException(status_code=400, detail="At least one document is required for analysis.")

    temp_files = []
    gemini_files = []
    
    try:
        # 1. Save uploaded files to temp and upload to Gemini
        for file in files:
            # Create a temp file
            suffix = os.path.splitext(file.filename)[1]
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
                content = await file.read()
                tmp.write(content)
                tmp_path = tmp.name
                temp_files.append(tmp_path)
            
            # Determine MIME type (optional, but good for Gemini)
            mime_type = magic.from_file(tmp_path, mime=True)
            
            # Upload to Gemini
            logger.info(f"Uploading {file.filename} to Gemini...")
            myfile = genai.upload_file(tmp_path, mime_type=mime_type, display_name=file.filename)
            gemini_files.append(myfile)

        # 2. Wait for files to be processed (Active)
        logger.info("Waiting for file processing...")
        for myfile in gemini_files:
            while myfile.state.name == "PROCESSING":
                time.sleep(2)
                myfile = genai.get_file(myfile.name)
            
            if myfile.state.name == "FAILED":
                raise HTTPException(status_code=500, detail=f"Gemini failed to process file: {myfile.display_name}")

        # 3. Generate Content
        file_names = [f.display_name for f in gemini_files]
        prompt = build_master_prompt(file_names)
        
        logger.info("Generating analysis...")
        response = model.generate_content(
            contents=[prompt] + gemini_files
        )
        
        # 4. Parse Response
        try:
            # Clean up response text if it contains markdown code blocks
            text = response.text
            if text.startswith("```json"):
                text = text.replace("```json", "").replace("```", "")
            elif text.startswith("```"):
                text = text.replace("```", "")
                
            report_data = json.loads(text)
            
            # Add validation_id to report
            report_data["validation_id"] = validation_id
            
            # Validate with Pydantic
            report = VerificationReport(**report_data)
            
            # Update database with results
            try:
                crud.update_validation(db, validation_id, report_data)
                crud.log_api_request(db, "/analyze-documents", "POST", user_id, 200, time.time() - start_time)
            except Exception as e:
                logger.error(f"Database update error: {e}")

            return report
            
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON: {e}")
            logger.error(f"Raw response: {response.text}")
            crud.log_api_request(db, "/analyze-documents", "POST", user_id, 500, time.time() - start_time)
            raise HTTPException(status_code=500, detail="AI returned invalid JSON format")
        except Exception as e:
            logger.error(f"Validation error: {e}")
            crud.log_api_request(db, "/analyze-documents", "POST", user_id, 500, time.time() - start_time)
            raise HTTPException(status_code=500, detail=f"Data validation error: {str(e)}")

    except Exception as e:
        logger.error(f"Error processing documents: {e}")
        crud.log_api_request(db, "/analyze-documents", "POST", user_id, 500, time.time() - start_time)
        raise HTTPException(status_code=500, detail=str(e))
        
    finally:
        # Cleanup: Delete temp files
        for path in temp_files:
            try:
                os.unlink(path)
            except Exception:
                pass
        
        # Cleanup: Delete Gemini files (optional, but good practice to manage storage)
        # Note: In a real app, you might want to keep them or manage lifecycle differently
        for myfile in gemini_files:
            try:
                genai.delete_file(myfile.name)
            except Exception:
                pass

@app.get("/api/history/{user_id}")
async def get_user_history(user_id: str, db: Session = Depends(get_db)):
    """Get validation history for a user"""
    validations = crud.get_user_validations(db, user_id)
    return {"user_id": user_id, "validations": validations}

@app.get("/health")
async def health_check(db: Session = Depends(get_db)):
    try:
        db.execute("SELECT 1")
        db_status = "connected"
    except Exception as e:
        logger.error(f"Health check DB error: {e}")
        db_status = "disconnected"
    return {"status": "healthy", "database": db_status}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
