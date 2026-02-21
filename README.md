# AgroGuard AI — Smart Agriculture Platform

<p align="center">
  <strong>🌾 AI-Powered Smart Farming System by CoderPirates</strong><br>
  Crop Recommendation &bull; Disease Detection &bull; IoT Monitoring &bull; Government Scheme Access &bull; Live Mandi Prices
</p>

---

## 📋 Project Overview

AgroGuard AI is a **complete production-ready full-stack smart farming platform** built for Indian farmers.
It combines AI/ML, IoT sensor monitoring, and direct integration with **5 Indian government agricultural portals** — all accessible in **5 regional languages** from a beautiful Flutter mobile app.

| Layer | Technology | Status |
|-------|-----------|--------|
| Mobile App | Flutter (Dart) | ✅ Live |
| Backend API | Python Flask | ✅ Live |
| ML Models | scikit-learn + TensorFlow/Keras | ✅ (with fallback) |
| Govt Integrations | eNAM · Agmarknet · mKisan · myScheme · PMFBY | ✅ Live |
| Multi-language | English · Hindi · Punjabi · Tamil · Bengali | ✅ Live |

---

## ✨ Key Features

### 🌱 AI Crop Recommendation
- Input soil NPK levels + weather conditions
- RandomForest ML model suggests the best crop with confidence scores
- Crop-specific requirement display
- Mock fallback model when ML model file is not present

### 🔍 AI Disease Detection
- Upload or capture a plant leaf photo
- CNN-based image analysis identifies the disease
- Shows symptoms, treatment protocols, and prevention tips
- Covers **40+ plant diseases** across 14 crop families

### 📡 IoT Sensor Dashboard
- Real-time monitoring of **9 sensor metrics**:
  - Soil: Nitrogen, Phosphorus, Potassium, pH, Moisture
  - Environment: Temperature, Humidity, Light Intensity, Rainfall
- Color-coded status: Optimal / Caution / Alert
- Auto-refresh every 5 s with threshold-based alert system and historical tracking

### 🏛️ Government Portal Hub *(NEW)*

Central hub linking all 5 Indian government agricultural portals from one screen:

| Module | Portal | What it does |
|--------|--------|-------------|
| 📊 Mandi Prices | eNAM + Agmarknet | Live commodity prices, cross-mandi comparison, price trends, seasonal calendar, market alerts |
| 📜 Scheme Checker | myScheme | Farmer fills profile → AI matches eligible government schemes and subsidies |
| 🛡️ Crop Insurance | PMFBY | Premium calculator (crop/season/area), claim status tracker, enrollment deadlines |
| 📢 Advisory Feed | mKisan | Government advisories on weather, pest, crop management, market, and schemes |
| 💰 Market Alerts | Agmarknet | Price spike/fall alerts, commodity trend analysis, 6-month trend charts |

### 🌐 Multi-Language Support *(NEW)*

Full UI available in **5 languages** — every screen, label, button, and error message:

| Flag | Language |
|------|----------|
| 🇬🇧 | English |
| 🇮🇳 | Hindi (हिन्दी) |
| 🇮🇳 | Punjabi (ਪੰਜਾਬੀ) |
| 🇮🇳 | Tamil (தமிழ்) |
| 🇧🇩 | Bengali (বাংলা) |

Language toggle is in the app bar on every screen. Powered by a global `AppLang` ValueNotifier — updates the entire UI instantly without a restart.

---

## 📦 Project Structure

```
AgroGuard-AI/
│
├── smartcrop_backend/                  # Flask REST API Server
│   ├── app.py                          # Main WSGI application
│   ├── requirements.txt                # Python dependencies
│   ├── services/
│   │   ├── crop_service.py             # RandomForest crop recommendation
│   │   ├── disease_service.py          # CNN disease detection (40+ diseases)
│   │   └── iot_service.py              # 9-sensor IoT simulator
│   ├── govt_integrations/              # ← NEW: Govt Portal Backend
│   │   ├── govt_routes.py              # Blueprint — 20+ govt API routes
│   │   ├── enam_scraper.py             # eNAM mandi prices & commodity data
│   │   ├── agmarknet_scraper.py        # Agmarknet trends & market alerts
│   │   ├── mkisan_fetcher.py           # mKisan government advisories
│   │   ├── myscheme_scraper.py         # myScheme eligibility checker
│   │   └── pmfby_checker.py            # PMFBY insurance calculator
│   └── datasets/
│       └── treatment_data.csv          # Disease treatment database
│
└── smartcrop_mobile/                   # Flutter Mobile Application
    └── lib/
        ├── main.dart                   # App entry, Material 3 theme
        ├── core/
        │   └── lang_provider.dart      # ← NEW: 5-language translation engine
        ├── screens/
        │   ├── home_screen.dart
        │   ├── crop_recommendation_screen.dart
        │   ├── disease_detection_screen.dart
        │   ├── sensor_dashboard_screen.dart
        │   ├── govt_portal_screen.dart     # ← NEW: Govt Hub
        │   ├── mandi_price_screen.dart     # ← NEW: eNAM + Agmarknet
        │   ├── scheme_checker_screen.dart  # ← NEW: myScheme eligibility
        │   ├── insurance_screen.dart       # ← NEW: PMFBY calculator
        │   └── advisory_feed_screen.dart   # ← NEW: mKisan advisories
        └── services/
            └── govt_api_service.dart   # ← NEW: Govt API client
```

---

## 🚀 Quick Start (Windows — One Command)

### Prerequisites
- **Python 3.10+** — [python.org](https://python.org)
- **Flutter 3.0+** — [flutter.dev](https://flutter.dev)

### Step 1 — Install all dependencies (run once)

Open PowerShell in the project root and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass; .\setup.ps1
```

This will automatically:
- Create a Python virtual environment
- Install all Python packages (`smartcrop_backend/requirements.txt`)
- Run `flutter pub get` for the mobile app

### Step 2 — Launch the app (every time)

```powershell
Set-ExecutionPolicy -Scope Process Bypass; .\start.ps1
```

This single command:
- Starts the **Flask backend** at `http://localhost:5000` in a new terminal window
- Launches the **Flutter web app** in Microsoft Edge automatically

> No need to manually activate a venv, run `pip install`, or `flutter pub get` again.

---

### Manual Start (optional — if you prefer individual commands)

**Backend:**
```bash
cd smartcrop_backend
# Windows
venv\Scripts\python.exe app.py
```
Backend: **http://localhost:5000**

**Flutter App:**
```bash
cd smartcrop_mobile
flutter pub get
flutter run -d edge        # browser (Microsoft Edge)
flutter run                # connected device / emulator
```

---

## 🔌 API Endpoints

Base URL: `http://localhost:5000`

### Core ML Endpoints
| Method | Route | Description |
|--------|-------|-------------|
| GET | `/health` | Health check |
| GET | `/api/status` | Service status |
| POST | `/api/predict_crop` | Crop recommendation |
| POST | `/api/predict_disease` | Disease detection from image |
| GET | `/api/sensor_data` | Live IoT sensor readings |

### Government Portal Endpoints *(NEW)*

**eNAM — Mandi Prices**

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/govt/mandi/prices` | Prices (`?state=&commodity=&mandi=`) |
| GET | `/api/govt/mandi/compare/<commodity>` | Cross-mandi comparison |
| GET | `/api/govt/mandi/states` | Available states |
| GET | `/api/govt/mandi/commodities` | Commodities with MSP info |
| GET | `/api/govt/mandi/mandis/<state>` | Mandis in a state |

**Agmarknet — Market Analysis**

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/govt/market/trend/<commodity>` | Price trend (`?months=6`) |
| GET | `/api/govt/market/alerts` | Market price alerts |
| GET | `/api/govt/market/calendar` | Seasonal buy/sell calendar |

**mKisan — Government Advisories**

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/govt/advisory/feed` | Advisories (`?category=&state=`) |
| GET | `/api/govt/advisory/categories` | Advisory categories |

**myScheme — Scheme Eligibility**

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/govt/schemes/list` | All schemes (`?state=&farmer_type=`) |
| POST | `/api/govt/schemes/check` | Farmer eligibility check |

**PMFBY — Crop Insurance**

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/govt/insurance/crops` | Insurable crops |
| POST | `/api/govt/insurance/premium` | Premium calculator |
| GET | `/api/govt/insurance/status/<app_id>` | Claim status |
| GET | `/api/govt/insurance/deadlines` | Enrollment deadlines |

**Dashboard**

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/govt/dashboard` | Aggregated govt portal summary |

---

## 📱 Mobile App Screens

| Screen | Description |
|--------|-------------|
| **Home** | Hero section, 6 feature cards, navigation hub |
| **Crop Recommendation** | 7-field form → AI crop suggestion with confidence bar |
| **Disease Detection** | Camera/gallery upload → disease + treatment card |
| **Sensor Dashboard** | 9-sensor grid, 5 s live refresh, colour-coded alerts |
| **Govt Portal Hub** | *(NEW)* Central screen linking all 5 govt integrations |
| **Mandi Prices** | *(NEW)* Live prices, cross-mandi comparison, price trends, seasonal calendar |
| **Scheme Checker** | *(NEW)* Profile form → matched schemes with benefit and link |
| **Crop Insurance** | *(NEW)* PMFBY premium calculator, claim tracker, deadlines |
| **Advisory Feed** | *(NEW)* mKisan advisories filtered by category and state |

---

## 🛠️ Technology Stack

### Backend
| Technology | Purpose |
|-----------|---------|
| **Flask** | RESTful API framework |
| **scikit-learn** | RandomForest crop recommendation |
| **TensorFlow / Keras** | CNN plant disease detection |
| **OpenCV + Pillow** | Image preprocessing |
| **NumPy / Pandas** | Data processing |
| **BeautifulSoup + lxml** | Govt portal data scraping |
| **SQLite (govt_cache.db)** | Govt data caching |

### Frontend
| Technology | Purpose |
|-----------|---------|
| **Flutter** | Cross-platform mobile + web |
| **Dart** | Programming language |
| **Material Design 3** | UI components and theming |
| **ValueNotifier** | Reactive multi-language state |
| **HTTP package** | REST API client |
| **image_picker** | Camera and gallery access |

---

## 🏛️ Government Integrations — Detail

### 1. eNAM (National Agriculture Market)
- Live commodity prices from mandis across all Indian states
- Filter by state, mandi, and commodity
- Minimum Support Price (MSP) reference for each commodity
- Cross-mandi price comparison to help farmers choose the best market

### 2. Agmarknet (Agricultural Marketing)
- Historical price trend charts (1–12 months)
- Market alerts for significant price movements (spike / fall)
- Seasonal buy/sell calendar — best time to sell each crop

### 3. mKisan (Mobile Kisaan)
- Government SMS advisory feed
- Categories: Weather warnings, Pest alerts, Crop management, Scheme announcements, Market updates
- Severity levels: Info / Warning / Alert — filterable by state and category

### 4. myScheme (Government Scheme Portal)
- 20+ central and state government schemes database
- Eligibility checker — inputs: age, land holding, state, gender, farmer type
- Returns matched schemes with description, benefit amount, and application link
- Covers PM-KISAN, Kisan Credit Card, Soil Health Card, PMFBY, and more

### 5. PMFBY (Pradhan Mantri Fasal Bima Yojana)
- **Premium Calculator** — crop + season (Kharif/Rabi/Zaid) + area → premium + sum insured
- **Claim Status Tracker** — enter application ID to check claim processing status
- **Enrollment Deadlines** — upcoming cutoff dates by season

---

## 🌐 Multi-Language Support — Detail

Custom `AppLang` + `AppStrings` system — zero external packages required:

- **Languages**: English, Hindi, Punjabi, Tamil, Bengali
- **Scope**: All 9 screens, every label, button, tooltip, and message
- **Switching**: Language picker in app bar → instant UI update via `ValueListenableBuilder`
- **Architecture**: Single `lang_provider.dart` with all translations in one map (~1200 lines)

---

## 🎨 Design System

| Element | Value |
|---------|-------|
| Primary Green | `#2ecc71` |
| Dark Green | `#27ae60` |
| Background | `#FAFAF5` |
| Alert Red | `#e74c3c` |
| Warning Amber | `#E9A23B` |
| Card Radius | 16 dp |

---

## 🔒 Security & Reliability

- Input validation on all backend endpoints
- File type and size validation for image uploads (max 16 MB)
- CORS enabled for cross-origin Flutter web requests
- Graceful fallbacks: ML services degrade to mock predictions if models are not loaded
- Government data cached in SQLite to minimise external API dependency

---

## 📊 Project Stats

| Metric | Value |
|--------|-------|
| Total screens | 9 |
| Backend API routes | 25+ |
| Supported languages | 5 |
| Government portals integrated | 5 |
| Diseases in database | 40+ |
| IoT sensor types | 9 |
| Supported platforms | Android, iOS, Web |
| Avg API response time | < 500 ms |

---

## 🧪 Testing the API

```bash
# Health check
curl http://localhost:5000/health

# Crop prediction
curl -X POST http://localhost:5000/api/predict_crop \
  -H "Content-Type: application/json" \
  -d '{"nitrogen":60,"phosphorus":25,"potassium":45,"temperature":28,"humidity":75,"ph":7.0,"rainfall":215}'

# Mandi prices — Wheat in Punjab
curl "http://localhost:5000/api/govt/mandi/prices?state=Punjab&commodity=Wheat"

# Scheme eligibility
curl -X POST http://localhost:5000/api/govt/schemes/check \
  -H "Content-Type: application/json" \
  -d '{"age":35,"land_acres":2.5,"state":"Punjab","gender":"male","farmer_type":"small"}'

# PMFBY premium
curl -X POST http://localhost:5000/api/govt/insurance/premium \
  -H "Content-Type: application/json" \
  -d '{"crop":"Wheat","season":"Rabi","area_acres":2.0}'

# mKisan advisories
curl "http://localhost:5000/api/govt/advisory/feed?category=weather&state=Punjab"
```

---

## 🐳 Docker

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

```bash
docker build -t agroguard-backend .
docker run -p 5000:5000 agroguard-backend
```

---

## ☁️ Cloud Deployment

```bash
# Heroku
heroku create agroguard-api && git push heroku main

# Google Cloud Run
gcloud run deploy agroguard-api --source .

# Flutter Web
flutter build web --release
# → deploy build/web/ to Firebase Hosting, Netlify, or Vercel

# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🚨 Troubleshooting

| Issue | Fix |
|-------|-----|
| Connection refused | Check backend is running: `curl http://localhost:5000/health` |
| Govt data not loading | Check internet; SQLite cache serves as fallback |
| Image picker not working | Add permissions to `AndroidManifest.xml` / `Info.plist` |
| Language not changing | Ensure `ValueListenableBuilder` wraps the full widget tree |
| TensorFlow not found | Python 3.13 is unsupported by TF; disease detection uses mock fallback |

---

## 📝 Changelog

### v2.0 — Government Portal & Language Update
- Added 5 government portal integrations (eNAM, Agmarknet, mKisan, myScheme, PMFBY)
- Added `govt_portal_screen.dart` — central navigation hub
- Added `mandi_price_screen.dart` — live prices, cross-mandi comparison, trends
- Added `scheme_checker_screen.dart` — farmer scheme eligibility checker
- Added `insurance_screen.dart` — PMFBY premium calculator and claim tracker
- Added `advisory_feed_screen.dart` — mKisan advisory feed with category filter
- Added `lang_provider.dart` — 5-language translation engine (EN / HI / PA / TA / BN)
- Added 20+ new backend API routes in `govt_routes.py`
- Fixed `CardTheme` → `CardThemeData` for Flutter 3.35 compatibility

### v1.0 — Initial Release
- Crop recommendation (RandomForest ML)
- Disease detection (CNN, 40+ diseases)
- IoT sensor dashboard (9 metrics, real-time)
- Core Flutter app (Android, iOS, Web)

---

## 🤝 Contributing

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit: `git commit -m "feat: your feature"`
4. Push and open a Pull Request

---

## 📜 License

© 2025–2026 AgroGuard AI by CoderPirates. All rights reserved.

---

<p align="center">
  <strong>🌾 Built with ❤️ for Indian Farmers — by CoderPirates</strong><br>
  AI · IoT · Government Schemes · Multi-Language · Production Ready
</p>

---

## Quick Reference

| Task | Command |
|------|---------|
| Start backend | `cd smartcrop_backend && python app.py` |
| Start Flutter (web) | `cd smartcrop_mobile && flutter run -d edge --web-port 8080` |
| Start Flutter (device) | `cd smartcrop_mobile && flutter run` |
| Test API health | `curl http://localhost:5000/health` |
| Test mandi prices | `curl http://localhost:5000/api/govt/mandi/prices` |
| View backend logs | `smartcrop_backend/smartcrop.log` |
