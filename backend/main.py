from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
import base64
import os
from dotenv import load_dotenv
import json
import shutil
from pathlib import Path

# Load environment variables
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# Configure Gemini
genai.configure(api_key=GEMINI_API_KEY)

# Create FastAPI app
app = FastAPI(
    title="PDF Gemini Analyzer",
    description="Upload 2 PDFs, get Gemini analysis",
    version="1.0.0"
)

# CORS (allow Flutter to call)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create temp directory
TEMP_DIR = Path("temp")
TEMP_DIR.mkdir(exist_ok=True)

# Gemini Analysis Prompt
ANALYSIS_PROMPT = """
You are an expert document analyst specializing in Indian land records and property documents.

I am providing TWO PDF documents:
1. JAMABANDI (Land Record)
2. SALE DEED (Property Sale Agreement)

Your task: Extract data from both documents and validate if they match.

---

STEP 1: EXTRACT DATA

From JAMABANDI extract:
- Owner name (exact text)
- Father's name
- Plot number / Khasra number
- Khata number
- Area with unit (bigha/acre/sq ft/sq m)
- Village name
- Tehsil (if present)
- District (if present)
- All dates found

From SALE DEED extract:
- Buyer name
- Seller name
- Father's names
- Plot number / Khasra number
- Area with unit
- Sale amount
- Registration date
- Registration number
- Witness names

---

STEP 2: VALIDATE

1. OWNER MATCH:
Does Jamabandi owner = Deed seller?
Consider these as SAME:
- "Ram Kumar" = "राम कुमार" = "R. Kumar" = "Shri Ram Kumar"
Handle Hindi/English variations smartly.

2. PLOT NUMBER MATCH:
Do plot numbers match?
Consider these as SAME:
- "123/456" = "123-456" = "khata 123/456"

3. AREA MATCH:
Convert both to square feet, then calculate difference.
If difference ≤ 2% → MATCH (acceptable tolerance)
If difference > 2% → FLAG IT

Unit conversions:
- 1 Bigha = 27,225 sq ft
- 1 Acre = 43,560 sq ft
- 1 Hectare = 107,639 sq ft
- 1 sq meter = 10.764 sq ft

4. DATE CHECK:
Is deed date AFTER jamabandi date?

5. AUTHENTICITY:
Are stamps/signatures visible?

---

STEP 3: MAKE DECISION

"approved" if:
- Owner matches (confidence > 85%)
- Plot number matches
- Area difference ≤ 2%
- Dates valid
- Stamps present

"needs_review" if:
- Minor mismatches
- Area difference 2-5%
- Low confidence (65-85%)

"rejected" if:
- Owner completely different
- Plot mismatch
- Area difference > 5%
- Missing signatures

---

OUTPUT FORMAT:

Return ONLY valid JSON (no markdown, no code blocks, no extra text):

{
  "extraction": {
    "jamabandi": {
      "owner_name": "string or null",
      "father_name": "string or null",
      "plot_number": "string or null",
      "area": "string or null",
      "area_sqft": number or null,
      "village": "string or null",
      "dates": ["array or empty"]
    },
    "deed": {
      "buyer_name": "string or null",
      "seller_name": "string or null",
      "seller_father_name": "string or null",
      "plot_number": "string or null",
      "area": "string or null",
      "area_sqft": number or null,
      "sale_amount": "string or null",
      "registration_date": "string or null"
    }
  },
  "validation": {
    "owner_match": boolean,
    "owner_confidence": float (0-1),
    "owner_explanation": "why they match or don't match",
    "plot_match": boolean,
    "plot_explanation": "string",
    "area_match": boolean,
    "area_difference_sqft": number,
    "area_difference_percent": float,
    "area_explanation": "string",
    "dates_valid": boolean,
    "stamps_present": boolean,
    "signatures_present": boolean
  },
  "decision": {
    "recommendation": "approved" | "needs_review" | "rejected",
    "confidence": float (0-1),
    "reason": "brief explanation",
    "issues": ["list of problems or empty array"]
  }
}

IMPORTANT RULES:
1. Extract REAL data - don't make up information
2. If you can't read something, use null
3. Be smart about name matching (Hindi/English are same person)
4. Return ONLY JSON, no markdown
5. Be honest about confidence scores
6. Explain your decisions clearly

Now analyze the documents and return your response.
"""

def pdf_to_base64(file_path: str) -> str:
    """Convert PDF file to base64 string"""
    with open(file_path, "rb") as pdf_file:
        return base64.b64encode(pdf_file.read()).decode("utf-8")

def analyze_with_gemini(jamabandi_path: str, deed_path: str) -> dict:
    """Send PDFs to Gemini and get analysis"""
    try:
        # Initialize Gemini model
        # Using gemini-1.5-pro as fallback for flash
        model = genai.GenerativeModel("gemini-1.5-pro")
        
        # Convert PDFs to base64
        jamabandi_data = pdf_to_base64(jamabandi_path)
        deed_data = pdf_to_base64(deed_path)
        
        # Prepare content for Gemini
        contents = [
            {
                "mime_type": "application/pdf",
                "data": jamabandi_data
            },
            {
                "mime_type": "application/pdf",
                "data": deed_data
            },
            ANALYSIS_PROMPT
        ]
        
        # Call Gemini API
        response = model.generate_content(
            contents,
            generation_config={
                "temperature": 0.1,
                "top_p": 0.95,
                "max_output_tokens": 8192,
            }
        )
        
        # Extract text response
        response_text = response.text.strip()
        
        # Remove markdown code blocks if present
        if response_text.startswith("```json"):
            response_text = response_text[7:]
        if response_text.startswith("```"):
            response_text = response_text[3:]
        if response_text.endswith("```"):
            response_text = response_text[:-3]
        response_text = response_text.strip()
        
        # Parse JSON
        result = json.loads(response_text)
        
        # LOGGING RAW RESPONSE FOR DEBUGGING
        print("======== GEMINI RAW RESPONSE ========")
        print(json.dumps(result, indent=2))
        print("=====================================")
        
        return {
            "success": True,
            "data": result,
            "raw_response": response.text
        }
        
    except json.JSONDecodeError as e:
        return {
            "success": False,
            "error": "Failed to parse Gemini response as JSON",
            "raw_response": response.text if 'response' in locals() else None,
            "details": str(e)
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "details": "Gemini API call failed"
        }

@app.post("/analyze")
async def analyze_documents(
    jamabandi: UploadFile = File(..., description="Jamabandi PDF file"),
    deed: UploadFile = File(..., description="Deed PDF file")
):
    """
    Upload Jamabandi and Deed PDFs for Gemini analysis
    
    Returns:
    - Extracted data from both documents
    - Validation results
    - Decision (approved/needs_review/rejected)
    """
    
    # Validate file types
    if not jamabandi.filename.endswith('.pdf'):
        raise HTTPException(400, "Jamabandi must be a PDF file")
    if not deed.filename.endswith('.pdf'):
        raise HTTPException(400, "Deed must be a PDF file")
    
    # Save uploaded files temporarily
    jamabandi_path = TEMP_DIR / f"jamabandi_{os.urandom(8).hex()}.pdf"
    deed_path = TEMP_DIR / f"deed_{os.urandom(8).hex()}.pdf"
    
    try:
        # Save files
        with open(jamabandi_path, "wb") as buffer:
            shutil.copyfileobj(jamabandi.file, buffer)
        
        with open(deed_path, "wb") as buffer:
            shutil.copyfileobj(deed.file, buffer)
        
        # Analyze with Gemini
        result = analyze_with_gemini(str(jamabandi_path), str(deed_path))
        
        return result
        
    except Exception as e:
        raise HTTPException(500, f"Analysis failed: {str(e)}")
    
    finally:
        # Clean up temporary files
        if jamabandi_path.exists():
            jamabandi_path.unlink()
        if deed_path.exists():
            deed_path.unlink()

@app.get("/")
def root():
    """API Info"""
    return {
        "name": "PDF Gemini Analyzer",
        "version": "1.0.0",
        "endpoints": {
            "POST /analyze": "Upload jamabandi and deed PDFs for analysis"
        }
    }

@app.get("/health")
def health():
    """Health check"""
    gemini_status = "configured" if GEMINI_API_KEY else "not_configured"
    return {
        "status": "running",
        "gemini_api": gemini_status
    }

# Run with: uvicorn main:app --reload --port 8000
