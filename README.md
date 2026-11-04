FloraScan • PLOW — AI Plant Care & Phytosanitary Diagnosis

A modern, responsive **AI Plant Care & Disease Detection Web Application** built with Flutter Web, a FastAPI backend proxy powered by Google Gemini Vision (`gemini-2.5-flash`), and an extensive database of 180+ botanical species and 40 plant diseases.

---

 Live Interactive Demo Link

The local live demo server is **running and accessible**:
 **[http://localhost:8080](http://localhost:8080)**

- **Desktop Website View**: Features an expanded website layout with a left sidebar navigation rail, two-column scanner workbench, searchable plant library grid, and care task management.
- **Mobile View**: Full-screen responsive mobile interface with glassmorphic bottom navigation and touch-optimized action targets (minimum 48×48dp).

---

 Architecture Overview

```
                      ┌───────────────────────────────────────┐
                      │          Flutter Web Client           │
                      │    (Responsive Mobile & Desktop)      │
                      └──────────────────┬────────────────────┘
                                         │
                        Multipart POST   │ JSON Response
                        /analyze, /chat  │
                                         ▼
                      ┌───────────────────────────────────────┐
                      │      FastAPI Backend Proxy            │
                      │      (Runs on http://localhost:8000)   │
                      └──────────────────┬────────────────────┘
                                         │
                        Secure API Call  │ Vision Inference
                        GEMINI_API_KEY   │
                                         ▼
                      ┌───────────────────────────────────────┐
                      │    Google Gemini 2.5 Flash Vision     │
                      │        (Structured JSON Schema)       │
                      └───────────────────────────────────────┘
```

> **Security First**: Your `GEMINI_API_KEY` is stored strictly in `backend/.env` (excluded via `.gitignore`) and is **never** embedded in client-side Flutter web JavaScript or Dart code.

---

##  Key Features

### 1.  Real AI Plant Identification & Disease Detection
- **Real Image Analysis**: Photos uploaded by the user are transmitted to the FastAPI backend and analyzed with Gemini Vision.
- **Strict Verification Rules**:
  - **Plant Identity First**: Returns common name, binomial scientific name, and AI confidence percentage before pathology details.
  - **Non-Plant Detection**: If an uploaded photo is not a plant, it warns the user ("Non-plant detected: [object]") and refuses to invent a disease.
  - **Healthy Plant Protection**: If a leaf looks healthy, it is celebrated as healthy (`health_status: "healthy"`). It **never** defaults to Tomato Early Blight!
  - **Low Confidence Safeguards**: If identification confidence is below 60%, the app flags the result, provides the closest alternative candidate species, and asks for a closer, clearer photograph.
  - **Labeled Demo Samples**: 4 built-in test specimens (Tomato Early Blight, Rose Powdery Mildew, Monstera Chlorosis, Healthy Golden Wheat) are clearly labeled as offline preview samples and are never used as a fallback for user uploads.

### 2. Comprehensive Plant & Disease Database
- **187 Detailed Species Profiles** (`assets/data/plants.json`):
  - Houseplants, fruit trees, common forest trees, vegetables, crops, and culinary herbs.
  - Deep coverage of Indian flora: *Tulsi (Holy Basil)*, *Neem*, *Mango*, *Banana*, *Hibiscus*, *Jasmine*, *Money Plant*, *Curry Leaves*, *Aloe Vera*, *Banyan*, *Peepal*, *Chili*, *Rice*, *Wheat*, *Maize*, etc.
  - Detailed parameters per plant: Local names (Hindi, Telugu, Kannada), scientific name, family, type, sunlight, water cadence in days, soil mix, temperature range, humidity, pet toxicity, human toxicity, growth notes, and botanical fun facts.
- **40 Phytosanitary Pathogen Profiles** (`assets/data/diseases.json`):
  - Fungal, bacterial, viral, and abiotic disorders with symptoms, causes, organic treatments, chemical controls, and cultural prevention steps.
- **Fuzzy Matching & Enrichment**: Automatically matches AI-identified plant names against the local database (supporting English, Latin binomials, and Hindi/Telugu/Kannada names). If matched, the result is enriched with verified care data and a "✓ Verified Botany DB Match" badge.

### 3. "My Garden" & Care Reminders
- Persisted locally via `localStorage` / `SharedPreferences`.
- Computes countdown to next watering based on species-specific `water_frequency_days`.
- Dynamic urgency badges: "Needs Water Today!" (red alert) vs "Water in X days" (cyan).
- One-tap **" Mark as Watered"** action with instant schedule reset.

### 4 Agronomist AI Follow-up Chat
- Contextual botanical chat powered by Gemini.
- Passes the currently diagnosed plant name, disease, and severity as context to Dr. Elena Carter (Agronomist AI).

---

##  Step-by-Step Run Instructions

### Step 1: Run the FastAPI Backend Proxy

1. Open a terminal and navigate to the `backend` folder:
   ```bash
   cd backend
   ```
2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Configure your Google Gemini API Key:
   - Create or edit `backend/.env`:
     ```env
     GEMINI_API_KEY=your_gemini_api_key_here
     PORT=8000
     HOST=0.0.0.0
     ```
   *(Get an API key for free at [Google AI Studio](https://aistudio.google.com/app/apikey))*
4. Start the backend server:
   ```bash
   python -m uvicorn main:app --port 8000 --reload
   ```
5. Verify health:
   - Open [http://localhost:8000/health](http://localhost:8000/health) in your browser. It should return `{"status": "healthy", "gemini_api_configured": true}`.

---

### Step 2: Run the Flutter Web App

1. Ensure Flutter is installed and accessible in your PATH:
   ```bash
   flutter --version
   ```
2. Get packages:
   ```bash
   flutter pub get
   ```
3. Run on Chrome:
   ```bash
   flutter run -d chrome
   ```
4. Run tests:
   ```bash
   flutter test
   ```

---

### Step 3: Run the Live HTML5 Preview (Instant Browser Demo)

If you wish to demo the app immediately without building Flutter assets:
```bash
python -m http.server 8080 --directory preview_app
```
Then visit **[http://localhost:8080](http://localhost:8080)** in Chrome, Edge, or mobile Safari.

---

## 🧪 Testing Suite

- **Responsive Breakpoint Widget Tests** (`test/responsive_test.dart`):
  - Validates layouts at 320px (compact mobile), 390px (smartphone), 768px (tablet), and 1440px (desktop).
  - Tests `ResponsiveBuilder`, `ResponsiveContainer`, and `clampedTextScale` (0.9 to 1.2 bounds).
- **Botanical Matching Unit Tests** (`test/plant_repository_test.dart`):
  - Validates JSON parsing of `PlantSpecies` and `PlantDisease`.
  - Tests fuzzy matching on common name, scientific name, and Indian regional names (*tulsi*, *neem*, *vepa*).
  - Validates `DiagnosisReport` enrichment with verified database care profiles.
- **Backend Integration Tests** (`test_backend.py`):
  - Tests `/health`, `/chat`, and `/analyze` multipart image handling.

---

##  Limitations & Disclaimers

1. **AI Output is Probabilistic**: Identification and disease diagnoses generated by multimodal vision models are estimates based on visual training patterns.
2. **Ambiguous Foliar Symptoms**: Nutrient deficiencies (e.g. Iron chlorosis), root rot from overwatering, and fungal leaf spot can present nearly identical visual chlorosis on certain cultivars.
3. **Not a Substitute for Laboratory Testing**: For commercial farming, high-value agricultural crops, or suspected quarantine pests, always verify diagnoses with your local agricultural extension service or certified plant pathologist.
4. **Internet Connection Required**: Live AI identification requires an active network connection to the FastAPI proxy and Gemini API. When offline, use the labeled Demo Samples or browse the 187 species in the Plant Library.

---

##  Pushing to GitHub

When ready to publish:

```bash
git add .
git commit -m "feat: complete FloraScan real AI identification, 180+ plants DB, responsive UI, and backend proxy"
git remote add origin https://github.com/<your-username>/plow-plant-care.git
git branch -M main
git push -u origin main
```
