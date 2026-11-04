import os
import json
import io
import re
from typing import Optional, List, Dict, Any
from pathlib import Path
from dotenv import load_dotenv

from fastapi import FastAPI, File, UploadFile, HTTPException, Header, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from PIL import Image

# Load environment variables from .env
env_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=env_path)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()

app = FastAPI(
    title="FloraScan & PLOW AI Backend",
    description="Real plant identification, phytosanitary disease detection, and agronomist chat proxy.",
    version="2.0.0",
)

# Enable CORS for local Flutter Web development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

ANALYSIS_SYSTEM_PROMPT = """You are a world-class phytopathologist, botanist, and agronomist AI engine.
Your task is to analyze the provided image of a plant with scientific accuracy.

Carefully determine:
1. Is this actually a plant, leaf, flower, fruit, or tree?
2. If NOT a plant (e.g. human, object, animal, indoor scene):
   Return "is_plant": false, and indicate in "common_name" what it appears to be.
3. If it IS a plant:
   - Identify its exact common name (e.g. "Monstera Deliciosa", "Holy Basil / Tulsi", "Tomato", "Mango Tree").
   - Identify its binomial scientific name (e.g. "Ocimum tenuiflorum", "Solanum lycopersicum").
   - Botanical family (e.g. "Lamiaceae", "Solanaceae", "Araceae").
   - Plant type: choose exactly one of ["houseplant", "tree", "crop", "flower", "herb", "other"].
   - Identification confidence score between 0 and 100.
   - If confidence is below 60, provide 2 to 3 closest possible alternative species in "alternatives".
4. Determine the health status:
   - Must be one of ["healthy", "diseased", "stressed", "unknown"].
   - CRITICAL RULE: If the plant looks healthy, green, and vibrant, set "health_status": "healthy", "disease_name": null, "severity": 0, "disease_confidence": 0, and DO NOT fabricate or invent a disease!
   - If diseased or stressed: identify the exact disease or disorder (e.g. "Early Blight", "Powdery Mildew", "Iron Chlorosis", "Spider Mite Infestation", "Bacterial Leaf Spot", "Leaf Curl").
   - Severity: an integer from 0 to 100 representing percentage of leaf/tissue damage.
   - List the visible symptoms (e.g. "concentric bullseye lesions", "yellowing chlorotic halos", "powdery white talc mycelium", "marginal necrosis").
   - Identify 2-4 likely causes (environmental, fungal vector, irrigation error, thermal optimum).
   - Provide 3-5 concrete, actionable step-by-step treatment recommendations (both cultural/organic and curative).
   - Provide 3-5 prevention guidelines to prevent recurrence.

CRITICAL: Return ONLY raw, valid JSON. Do NOT wrap in markdown fences (no ```json or ```).

Strict JSON Schema:
{
  "is_plant": true,
  "common_name": "Tomato",
  "scientific_name": "Solanum lycopersicum",
  "family": "Solanaceae",
  "plant_type": "crop",
  "confidence": 94,
  "health_status": "diseased",
  "disease_name": "Early Blight",
  "disease_confidence": 92,
  "symptoms_seen": [
    "Dark concentric bullseye lesions on lower foliage",
    "Surrounding yellow chlorotic halos"
  ],
  "severity": 62,
  "likely_causes": [
    "Persistent leaf wetness exceeding 4 hours from overhead watering",
    "Fungal vector Alternaria solani surviving in soil debris",
    "Warm humid microclimate (24-29°C)"
  ],
  "treatment_steps": [
    "Prune and discard infected lower leaflets using sanitized shears",
    "Apply OMRI-listed organic copper octanoate or Bacillus subtilis spray",
    "Transition from overhead watering to basal soil drip irrigation",
    "Apply 2 inches of organic mulch around the stem base"
  ],
  "prevention_tips": [
    "Water only at the root base early in the morning",
    "Space tomato plants at least 24 inches apart for maximum airflow",
    "Practice 3-year crop rotation avoiding Solanaceae family members"
  ],
  "alternatives": []
}"""

def clean_json_string(text: str) -> str:
    """Strip markdown code fences and whitespace from model response."""
    text = text.strip()
    if text.startswith("```"):
        text = re.sub(r"^```[a-zA-Z]*\n?", "", text)
        text = re.sub(r"\n?```$", "", text)
    return text.strip()

def resize_image(image_bytes: bytes, max_size: int = 1024) -> Image.Image:
    """Resize image to max 1024x1024 to speed up transmission while maintaining detail."""
    img = Image.open(io.BytesIO(image_bytes))
    if img.mode != "RGB":
        img = img.convert("RGB")
    
    width, height = img.size
    if max(width, height) > max_size:
        if width > height:
            new_width = max_size
            new_height = int(height * (max_size / width))
        else:
            new_height = max_size
            new_width = int(width * (max_size / height))
        img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    return img

async def call_gemini_vision(img: Image.Image, custom_key: Optional[str] = None) -> Dict[str, Any]:
    """Call Gemini Vision API via google-genai or google.generativeai."""
    key = (custom_key or os.getenv("GEMINI_API_KEY", "")).strip()
    if not key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="GEMINI_API_KEY is not configured in backend/.env. Please add your key to enable real AI identification."
        )

    # Convert PIL Image to JPEG bytes
    buffer = io.BytesIO()
    img.save(buffer, format="JPEG", quality=88)
    image_bytes = buffer.getvalue()

    # Try modern google-genai SDK first
    try:
        from google import genai
        from google.genai import types

        client = genai.Client(api_key=key)
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                types.Part.from_bytes(data=image_bytes, mime_type="image/jpeg"),
                ANALYSIS_SYSTEM_PROMPT
            ],
            config=types.GenerateContentConfig(
                temperature=0.2,
                response_mime_type="application/json",
            )
        )
        cleaned = clean_json_string(response.text or "{}")
        return json.loads(cleaned)
    except Exception as e:
        # Fallback to google.generativeai if available
        try:
            import google.generativeai as legacy_genai
            legacy_genai.configure(api_key=key)
            model = legacy_genai.GenerativeModel("gemini-1.5-flash")
            response = model.generate_content([
                ANALYSIS_SYSTEM_PROMPT,
                img
            ])
            cleaned = clean_json_string(response.text or "{}")
            return json.loads(cleaned)
        except Exception as e_inner:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gemini API execution failed: {str(e_inner or e)}"
            )

@app.get("/")
def root():
    return {
        "status": "online",
        "service": "FloraScan / PLOW AI Backend",
        "version": "2.0.0",
        "endpoints": ["/analyze", "/chat", "/health"]
    }

@app.get("/health")
def health_check():
    key_set = bool(os.getenv("GEMINI_API_KEY", "").strip())
    return {
        "status": "healthy",
        "gemini_api_configured": key_set
    }

@app.post("/analyze")
async def analyze_plant_image(
    file: UploadFile = File(...),
    x_gemini_key: Optional[str] = Header(None, alias="X-Gemini-Key")
):
    """Analyze uploaded plant photo for identification, health condition, and treatment."""
    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file must be a valid image (JPEG, PNG, WEBP)."
        )

    content = await file.read()
    if len(content) > 15 * 1024 * 1024:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image size exceeds maximum limit of 15 MB."
        )

    try:
        pil_image = resize_image(content, max_size=1024)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unable to decode image. Please upload a valid PNG or JPEG image."
        )

    raw_result = await call_gemini_vision(pil_image, custom_key=x_gemini_key)

    # Safe validation & fallback normalization
    is_plant = bool(raw_result.get("is_plant", True))
    common_name = str(raw_result.get("common_name", "Unknown Plant")).strip()
    scientific_name = str(raw_result.get("scientific_name", "")).strip()
    family = str(raw_result.get("family", "")).strip()
    plant_type = str(raw_result.get("plant_type", "other")).strip().lower()
    confidence = int(raw_result.get("confidence", 80))
    health_status = str(raw_result.get("health_status", "unknown")).strip().lower()
    disease_name = raw_result.get("disease_name")
    if disease_name:
        disease_name = str(disease_name).strip()
    disease_confidence = int(raw_result.get("disease_confidence", 0))
    symptoms_seen = [str(s) for s in raw_result.get("symptoms_seen", [])]
    severity = int(raw_result.get("severity", 0))
    likely_causes = [str(c) for c in raw_result.get("likely_causes", [])]
    treatment_steps = [str(t) for t in raw_result.get("treatment_steps", [])]
    prevention_tips = [str(p) for p in raw_result.get("prevention_tips", [])]
    alternatives = raw_result.get("alternatives", [])

    # Strict rule enforcement
    if not is_plant:
        health_status = "unknown"
        disease_name = None
        severity = 0

    if health_status == "healthy":
        disease_name = None
        disease_confidence = 0
        severity = 0

    return {
        "is_plant": is_plant,
        "common_name": common_name,
        "scientific_name": scientific_name,
        "family": family,
        "plant_type": plant_type,
        "confidence": max(0, min(100, confidence)),
        "health_status": health_status,
        "disease_name": disease_name,
        "disease_confidence": max(0, min(100, disease_confidence)),
        "symptoms_seen": symptoms_seen,
        "severity": max(0, min(100, severity)),
        "likely_causes": likely_causes,
        "treatment_steps": treatment_steps,
        "prevention_tips": prevention_tips,
        "alternatives": alternatives
    }

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    message: str
    plant_context: Optional[Dict[str, Any]] = None
    history: Optional[List[ChatMessage]] = None

@app.post("/chat")
async def agronomist_chat(
    req: ChatRequest,
    x_gemini_key: Optional[str] = Header(None, alias="X-Gemini-Key")
):
    """Agronomist AI Chatbot that answers questions with plant diagnosis context."""
    key = (x_gemini_key or os.getenv("GEMINI_API_KEY", "")).strip()
    if not key:
        return {
            "reply": "I am the FloraScan Agronomist AI. To enable live conversational AI, please add your GEMINI_API_KEY in backend/.env or enter it in settings. For now, consult the treatment and care tips listed in the dossier."
        }

    ctx = req.plant_context or {}
    plant_name = ctx.get("common_name", "the plant")
    disease = ctx.get("disease_name", "general care")
    health = ctx.get("health_status", "unknown")

    system_instruction = (
        f"You are Dr. Elena Carter, an expert senior agronomist and phytopathologist for FloraScan. "
        f"The user is asking questions about: {plant_name} (Status: {health}, Disease/Condition: {disease}). "
        f"Give concise, warm, highly practical, and scientifically backed agricultural advice in 2-3 short paragraphs. "
        f"Emphasize organic solutions, proper watering, and pathogen prevention."
    )

    try:
        from google import genai
        client = genai.Client(api_key=key)
        prompt = f"{system_instruction}\n\nUser Question: {req.message}"
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt,
        )
        return {"reply": response.text or "I recommend checking soil moisture and isolating the plant."}
    except Exception as e:
        try:
            import google.generativeai as legacy_genai
            legacy_genai.configure(api_key=key)
            model = legacy_genai.GenerativeModel("gemini-1.5-flash")
            response = model.generate_content(f"{system_instruction}\n\nUser Question: {req.message}")
            return {"reply": response.text or "I recommend checking soil moisture and isolating the plant."}
        except Exception as e2:
            return {
                "reply": f"Agronomist advice currently unavailable ({str(e2 or e)}). Please follow the recommended treatment plan."
            }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    host = os.getenv("HOST", "0.0.0.0")
    uvicorn.run("main:app", host=host, port=port, reload=True)
