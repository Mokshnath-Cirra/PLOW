# 🌿 FloraScan • PLOW — AI Plant Care & Disease Diagnosis Web-App

A modern, responsive **AI Plant Care & Disease Detection Web Application** built with Flutter & modern web standards, matching the **FloraScan** design system.

---

## 🌐 Live Interactive Demo Link

The local live demo server is **currently active and running**:
👉 **[http://localhost:8080](http://localhost:8080)**

> **Note**: You can toggle between **Mobile Mockup (Reference view)** and **Responsive Desktop Mode** using the top toolbar switch.

---

## 🌟 Key Features Implemented

### 1. 📷 Plant Identification (Photo Scan & Upload)
- Identify crops and houseplants through instant camera viewfinder scan or gallery photo upload.
- Supports drag-and-drop or file selection of your own custom leaf photos.
- Included 4 built-in test specimens for instant viva/lab demonstrations:
  - 🍅 **Tomato**: Early Blight (*Alternaria solani*)
  - 🌸 **Rose**: Powdery Mildew (*Podosphaera pannosa*)
  - 🪴 **Monstera**: Chlorosis & Drainage Stress
  - 🌾 **Golden Wheat**: Healthy & Pathogen-free

### 2. 🔬 Disease Detection & Symptom Analysis
- Real-time viewfinder HUD targeting with animated laser reticle and confidence indicator.
- Multispectral imaging simulation:
  - **RGB Natural Spectrum**
  - **NDVI Simulation**: Simulates relative vegetation chlorophyll density
  - **Thermal Stress**: Highlights evapotranspiration cold spots and stomatal closure

### 3. 🧠 Smart Diagnosis & Pathology ID (Reference Screens 3 & 4)
- **Pathological ID**: Classification (`Ascomycete Fungal`), Family (`Solanaceae`), Microclimate factors (`78% RH • 26.5°C`).
- **Severity Risk Matrix**: Real-time index gauge (`64 / 100 HIGH ALERT`) with animated SVG radial indicator.
- **Progression Wave**: 4-phase chronological disease lifecycle tracking:
  - Phase 1: Spore Germination (*Resolved*)
  - Phase 2: Bullseye Target Spots (*Active - High spore production*)
  - Phase 3: Foliar Blight & Defoliation (*Predicted in 48h*)
  - Phase 4: Stem Collar & Fruit Rot (*Preventable with Rx*)
- **Etiology & Vectors**: Identifies Primary Inoculum Trigger, Thermal Optimum, and Distinctive Diagnostic Markers.

### 4. 💊 Treatment Solutions & Step-by-Step Prescription
- **Step 1 Physical Containment**: Leaf pruning instructions with sterilized shears and safe disposal.
- **Step 2 Spray Prescription**: Organic OMRI-listed Liquid Copper Octanoate or *Bacillus subtilis* with specific dosage (2 fl oz / gal) and timing.
- **One-Click Calendar Integration**: Directly adds a 7-day recurring spray treatment reminder into the care schedule.

### 5. ☀️ Plant Care Tips & Prevention Guide
- Detailed guidelines for watering (basal drip only to prevent spore splash), sunlight exposure, canopy airflow spacing (24 inches), and soil mulching.
- Interactive **Agronomist AI Chat** modal for follow-up questions.
- **Export Phytosanitary Dossier / PDF** summary functionality.

---

## 🎨 UI Design & Reference Architecture

| UI Component | Reference Match | Responsive Adaptation |
| :--- | :--- | :--- |
| **Header Greeting** | "Good morning, Botanist! Your Fields Are **Thriving**" with green accent underline | Compact on mobile; wide-spaced on desktop |
| **Telemetry Hero Card** | "AI Drone Telemetry Active • 42 Acres Monitored • 92.4% Health Index" | Fluid aspect ratio scaling |
| **Crop Vitality Card** | Obsidian `#0D1912` card with radial 92% VIGOUR donut gauge and microclimate metrics | Stacked on mobile; horizontal row on desktop |
| **Monitored Plots** | Golden Wheat, Organic Tomato (Stage 2 alert), Sweet Maize, Monstera | Clean cards with direct inspection links |
| **AI Scanner HUD** | Targeting brackets, `Direct Daylight • 100% Locked`, floating diagnosis pill | Interactive viewfinder with camera modes |
| **Glassmorphic Bottom Bar** | Translucent floating pill with glowing center leaf action button | Docked on mobile, centered sticky on desktop |

---

## 🚀 How to Run Native Flutter Build

1. Ensure the Flutter SDK is on your PATH:
   ```bash
   flutter --version
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run directly on Chrome:
   ```bash
   flutter run -d chrome
   ```
4. Run Unit and Widget tests:
   ```bash
   flutter test
   ```

---

## 🐙 Pushing to GitHub (When Ready)

When you are ready to push this project to your GitHub account:

```bash
# 1. Initialize git (if not already done)
git init

# 2. Add all project files
git add .

# 3. Create initial commit
git commit -m "feat: complete FloraScan plant care reminder & disease detection web-app"

# 4. Link your GitHub remote repository
git remote add origin https://github.com/<your-username>/<your-repo-name>.git

# 5. Push to main branch
git branch -M main
git push -u origin main
```
