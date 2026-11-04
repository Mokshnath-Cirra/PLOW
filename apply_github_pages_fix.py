import re

# Read current preview_app/index.html
with open('preview_app/index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# 1. Fix dataset fetch paths from /data/ to data/
html = html.replace("fetch('/data/plants.json')", "fetch('data/plants.json')")
html = html.replace("fetch('/data/diseases.json')", "fetch('data/diseases.json')")

# 2. Add client-side direct Gemini prompt & execution functions right before executeBackendAnalysis
client_gemini_code = '''
    const ANALYSIS_SYSTEM_PROMPT = `You are a world-class phytopathologist, botanist, and agronomist AI engine.
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
    "Fungal vector Alternaria solani surviving in soil debris"
  ],
  "treatment_steps": [
    "Prune and discard infected lower leaflets using sanitized shears",
    "Apply OMRI-listed organic copper octanoate or Bacillus subtilis spray"
  ],
  "prevention_tips": [
    "Water only at the root base early in the morning",
    "Space tomato plants at least 24 inches apart for maximum airflow"
  ],
  "alternatives": []
}`;

    function cleanJsonString(text) {
      text = text.trim();
      if (text.startsWith("```")) {
        text = text.replace(/^```[a-zA-Z]*\\n?/, "").replace(/\\n?```$/, "");
      }
      return text.trim();
    }

    async function callGeminiDirectlyFromBrowser(file, previewUrl, apiKey) {
      // Extract base64
      let base64Data = '';
      if (previewUrl.includes(',')) {
        base64Data = previewUrl.split(',')[1];
      } else {
        base64Data = previewUrl;
      }
      const mimeType = file.type || 'image/jpeg';

      const candidateModels = [
        'gemini-2.0-flash',
        'gemini-2.5-flash',
        'gemini-2.0-flash-exp',
        'gemini-1.5-flash-latest'
      ];

      const payload = {
        contents: [
          {
            parts: [
              {
                inline_data: {
                  mime_type: mimeType,
                  data: base64Data
                }
              },
              {
                text: ANALYSIS_SYSTEM_PROMPT
              }
            ]
          }
        ],
        generationConfig: {
          temperature: 0.2
        }
      };

      let lastError = null;
      for (const model of candidateModels) {
        try {
          const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
          const resp = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
          });
          if (resp.ok) {
            const jsonResp = await resp.json();
            const candidates = jsonResp.candidates || [];
            if (candidates.length > 0 && candidates[0].content && candidates[0].content.parts) {
              const text = candidates[0].content.parts[0].text;
              if (text) {
                const cleaned = cleanJsonString(text);
                return JSON.parse(cleaned);
              }
            }
          } else {
            const errJson = await resp.json().catch(() => ({}));
            lastError = new Error(errJson.error?.message || `Google API error (${resp.status})`);
          }
        } catch (e) {
          lastError = e;
        }
      }
      throw lastError || new Error("Failed to connect to Google Gemini Vision API");
    }

    async function callGeminiChatDirectlyFromBrowser(message, plantCtx, apiKey) {
      const systemInstruction = `You are Dr. Elena Carter, an expert senior agronomist and phytopathologist for FloraScan. The user is asking questions about: ${plantCtx.common_name || 'the plant'} (Status: ${plantCtx.health_status || 'unknown'}, Disease/Condition: ${plantCtx.disease_name || 'general care'}). Give concise, warm, highly practical, and scientifically backed agricultural advice in 2-3 short paragraphs. Emphasize organic solutions, proper watering, and pathogen prevention.`;

      const payload = {
        contents: [
          {
            parts: [
              { text: `${systemInstruction}\\n\\nUser Question: ${message}` }
            ]
          }
        ],
        generationConfig: {
          temperature: 0.7
        }
      };

      const candidateModels = ['gemini-2.0-flash', 'gemini-2.5-flash', 'gemini-1.5-flash-latest'];
      for (const model of candidateModels) {
        try {
          const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
          const resp = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
          });
          if (resp.ok) {
            const data = await resp.json();
            const candidates = data.candidates || [];
            if (candidates.length > 0 && candidates[0].content && candidates[0].content.parts) {
              return candidates[0].content.parts[0].text || "Check soil moisture and isolate the plant.";
            }
          }
        } catch (e) {}
      }
      return "I recommend monitoring soil moisture, ensuring adequate sunlight, and checking leaf undersides.";
    }
'''

# 3. Enhanced executeBackendAnalysis to try proxy first, then direct Gemini
new_execute_analysis = '''    // Execute Real AI Analysis (Supports both Backend Proxy and Direct Browser Gemini)
    async function executeBackendAnalysis(file, previewUrl) {
      const overlay = document.getElementById('scannerLoadingOverlay');
      overlay.style.display = 'flex';
      document.getElementById('loadingStatusText').innerText = 'Extracting leaf pathology with Gemini AI...';

      const customKey = (localStorage.getItem('plow_gemini_key') || '').trim();

      // Check if user has entered their key
      if (!customKey) {
        overlay.style.display = 'none';
        showToast('🔑 Please enter your Gemini API key in settings');
        openSettingsModal();
        return;
      }

      let result = null;

      // Method 1: If user configured a live backend proxy, try it first
      const hasConfiguredBackend = API_BASE && !API_BASE.includes('localhost') && API_BASE !== 'none';
      if (hasConfiguredBackend) {
        try {
          const formData = new FormData();
          formData.append('file', file);
          const headers = { 'X-Gemini-Key': customKey };

          const response = await fetch(`${API_BASE}/analyze`, {
            method: 'POST',
            headers: headers,
            body: formData
          });

          if (response.ok) {
            result = await response.json();
          }
        } catch (err) {
          console.warn('Backend proxy unreachable, falling back to direct browser Gemini API:', err);
        }
      }

      // Method 2: Direct Browser Gemini Vision Call (Works instantly on GitHub Pages!)
      if (!result) {
        try {
          document.getElementById('loadingStatusText').innerText = 'Calling Gemini 2.0 Flash Vision directly...';
          result = await callGeminiDirectlyFromBrowser(file, previewUrl, customKey);
        } catch (directErr) {
          overlay.style.display = 'none';
          console.error('Direct Gemini Vision error:', directErr);
          alert(`AI Plant Diagnosis Error:\\n${directErr.message}\\n\\nPlease check your Gemini API key in ⚙️ Settings.`);
          return;
        }
      }

      overlay.style.display = 'none';
      result.imageUrl = previewUrl;
      renderDiagnosisReport(result);
      switchViewScreen('diagnosis');
      showToast('✓ AI Diagnosis Complete!');
    }'''

# Replace old executeBackendAnalysis
old_analysis_pattern = re.compile(
    r'    // Execute Real Backend AI Analysis\s+async function executeBackendAnalysis\(file, previewUrl\) \{[\s\S]*?showToast\(\'✓ AI Diagnosis Complete!\'\);\s+\}\s+catch\s*\(err\)\s*\{[\s\S]*?\}\s+\}',
    re.MULTILINE
)

if old_analysis_pattern.search(html):
    html = old_analysis_pattern.sub(client_gemini_code + '\n' + new_execute_analysis, html)
    print("Successfully replaced executeBackendAnalysis with hybrid direct Gemini engine!")
else:
    print("Could not regex match executeBackendAnalysis, looking for fallback position...")
    target = "// Execute Real Backend AI Analysis"
    if target in html:
        parts = html.split(target)
        # find end of function
        rest = parts[1]
        end_idx = rest.find("// Trigger Current Feed")
        if end_idx != -1:
            html = parts[0] + client_gemini_code + '\n' + new_execute_analysis + '\n\n    ' + rest[end_idx:]
            print("Successfully replaced via split target!")

# 4. Enhance Agronomist Chat to support direct Gemini fallback
old_chat_send = '''      try {
        const response = await fetch(`${API_BASE}/chat`, {
          method: 'POST',
          headers: headers,
          body: JSON.stringify({
            message: text,
            plant_context: plantCtx
          })
        });

        if (response.ok) {
          const resJson = await response.json();
          aiBubble.innerText = resJson.reply || 'Check soil drainage and isolate the plant.';
        } else {
          aiBubble.innerText = 'Agronomist advice is currently unavailable. Ensure the FastAPI backend is running on port 8000.';
        }
      } catch (e) {
        aiBubble.innerText = 'Unable to reach Dr. Carter. Please verify your internet and backend connection.';
      }'''

new_chat_send = '''      let answered = false;
      if (API_BASE && !API_BASE.includes('localhost') && API_BASE !== 'none') {
        try {
          const response = await fetch(`${API_BASE}/chat`, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ message: text, plant_context: plantCtx })
          });
          if (response.ok) {
            const resJson = await response.json();
            aiBubble.innerText = resJson.reply || 'Check soil drainage and isolate the plant.';
            answered = true;
          }
        } catch (e) {}
      }

      if (!answered && customKey) {
        try {
          const directReply = await callGeminiChatDirectlyFromBrowser(text, plantCtx, customKey);
          aiBubble.innerText = directReply;
          answered = true;
        } catch (chatErr) {
          aiBubble.innerText = 'Dr. Carter advice unavailable. Please verify your Gemini API key in Settings.';
        }
      } else if (!answered) {
        aiBubble.innerText = 'Please add your Gemini API key in ⚙️ Settings to enable live AI agronomist chat.';
      }'''

html = html.replace(old_chat_send, new_chat_send)

# 5. Enhance checkBackendHealth to recognize GitHub Pages cloud mode
old_health = '''    // Check Backend Server Health
    async function checkBackendHealth() {
      const dot = document.getElementById('backendDot');
      const text = document.getElementById('backendStatusText');
      try {
        const res = await fetch(`${API_BASE}/health`, { method: 'GET' });
        if (res.ok) {
          const data = await res.json();
          dot.style.background = 'var(--accent-bright)';
          text.innerText = data.gemini_api_configured ? 'FastAPI + Gemini Ready' : 'FastAPI Ready (No Key)';
        } else {
          throw new Error('Not 200');
        }
      } catch (err) {
        dot.style.background = 'var(--alert-red)';
        text.innerText = 'Backend Offline';
        document.getElementById('backendSubText').innerText = 'Run: python -m uvicorn backend.main:app';
      }
    }'''

new_health = '''    // Check Backend Server Health
    async function checkBackendHealth() {
      const dot = document.getElementById('backendDot');
      const text = document.getElementById('backendStatusText');
      const subText = document.getElementById('backendSubText');
      const customKey = (localStorage.getItem('plow_gemini_key') || '').trim();
      const isGitHub = window.location.hostname.includes('github.io');

      try {
        const res = await fetch(`${API_BASE}/health`, { method: 'GET' });
        if (res.ok) {
          const data = await res.json();
          dot.style.background = 'var(--accent-bright)';
          text.innerText = data.gemini_api_configured ? 'FastAPI + Gemini Ready' : 'FastAPI Ready';
          subText.innerText = API_BASE;
          return;
        }
      } catch (err) {}

      // If backend is not available but running on GitHub Pages
      if (isGitHub || customKey) {
        if (customKey) {
          dot.style.background = 'var(--accent-bright)';
          text.innerText = 'Direct Gemini AI Ready';
          subText.innerText = 'Google Cloud Vision Active';
        } else {
          dot.style.background = 'var(--warning-amber)';
          text.innerText = 'Add Gemini Key';
          subText.innerText = 'Click ⚙️ Settings';
        }
      } else {
        dot.style.background = 'var(--alert-red)';
        text.innerText = 'Backend Offline';
        subText.innerText = 'Run: python -m uvicorn backend.main:app';
      }
    }'''

html = html.replace(old_health, new_health)

# Write to both preview_app/index.html and docs/index.html
with open('preview_app/index.html', 'w', encoding='utf-8') as f:
    f.write(html)

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print("Successfully updated preview_app/index.html and docs/index.html!")
