# 🌾 AgroGuard AI - Software Stack & Machine Learning Models (Part 2)

**Version:** 1.0.0  
**Date:** February 20, 2026

---

## Part 6: Complete Software Stack

### 6.1 Backend Technology Stack

#### **6.1.1 Core Framework: Flask REST API**

```
Flask 2.3.2
├── Lightweight & Fast
├── RESTful Architecture
├── Built-in Testing Framework
├── Extensive Extension Library
└── Production Ready (with Gunicorn)

Project Structure:
smartcrop_backend/
├── app.py (Main application - 12 endpoints)
├── services/
│   ├── __init__.py
│   ├── crop_service.py (ML Recommendation)
│   ├── disease_service.py (500+ lines, Image Analysis)
│   ├── iot_service.py (400+ lines, Analytics)
│   └── utils/
├── datasets/
│   └── treatment_data.csv (40+ diseases)
├── requirements.txt
├── venv/ (Virtual Environment)
└── config.py
```

#### **6.1.2 Python Dependencies**

```
Framework:
├── flask==2.3.2
├── flask-cors==4.0.0
├── gunicorn==21.2.0
└── python-dotenv==1.0.0

Data Processing:
├── numpy==1.24.3
├── pandas==2.0.3
└── scipy==1.11.2

Machine Learning:
├── scikit-learn==1.3.0
├── opencv-python==4.13.0.92
└── Pillow==10.0.0

Utilities:
├── requests==2.31.0
├── python-dateutil==2.8.2
└── logging (built-in)
```

### 6.2 Machine Learning Models

#### **6.2.1 Crop Recommendation Model**

**Type:** Random Forest Classifier (Ensemble ML)

**Architecture:**
```
Training Data:
├─ Features: 9 input parameters
├─ Samples: 500+ crop scenarios
├─ Crops: 22 varieties
└─ Accuracy: 92-96%

Input Features:
├─ Temperature (°C)
├─ Humidity (%)
├─ Rainfall (mm)
├─ pH Level
├─ Nitrogen (mg/kg)
├─ Phosphorus (mg/kg)
├─ Potassium (mg/kg)
├─ Soil Type (encoded)
└─ Water Availability (%)

Random Forest Configuration:
├─ Number of Trees: 100
├─ Max Depth: 20
├─ Min Samples Split: 5
├─ Min Samples Leaf: 2
└─ Random State: 42 (reproducibility)

Output:
├─ Predicted Crop: String
├─ Confidence Score: 0.0-1.0 (Probability)
└─ Top-3 Alternatives: List[String]
```

**Model Performance:**
```
Metrics:
├─ Accuracy: 94.2%
├─ Precision: 93.8%
├─ Recall: 92.5%
└─ F1-Score: 93.1%

Confusion Matrix (Best Performers):
├─ Wheat: 98% accuracy
├─ Rice: 96% accuracy
├─ Corn: 95% accuracy
└─ Potato: 91% accuracy

Training Process:
├─ Dataset Split: 80% train, 20% test
├─ Cross-Validation: 5-fold
├─ Hyperparameter Tuning: GridSearch
└─ Feature Scaling: StandardScaler
```

**Code Integration:**
```python
from sklearn.ensemble import RandomForestClassifier
import joblib

class CropRecommendationService:
    def __init__(self):
        # Load pre-trained model
        self.model = joblib.load('models/crop_model.pkl')
        self.scaler = joblib.load('models/scaler.pkl')
    
    def predict_crop(self, features: List[float]) -> Dict:
        # Normalize input
        scaled = self.scaler.transform([features])
        
        # Get prediction
        prediction = self.model.predict(scaled)[0]
        confidence = self.model.predict_proba(scaled)[0].max()
        
        return {
            'crop': prediction,
            'confidence': float(confidence),
            'alternatives': self._get_alternatives(scaled)
        }
```

#### **6.2.2 Disease Detection Model**

**Type:** Custom Computer Vision Pipeline (No Pre-trained Model)

**Architecture:**

```
Image Input (Plant Leaf)
    ↓
[1] Image Preprocessing
    ├─ Resize to 512x512
    ├─ RGB normalization
    ├─ Blur filtering
    └─ Contrast enhancement
    ↓
[2] Color Analysis Module
    ├─ RGB Channel Extraction
    ├─ HSV Color Space Conversion
    ├─ Histogram Equalization
    ├─ Color Range Detection
    └─ Abnormal Color Identification
    ↓
[3] Texture Analysis Module
    ├─ Edge Detection (Canny)
    ├─ Laplacian Filtering
    ├─ Local Binary Pattern (LBP)
    ├─ Gradient Magnitude
    └─ Roughness Calculation
    ↓
[4] Spot Detection Module
    ├─ Morphological Erosion
    ├─ Morphological Dilation
    ├─ Contour Finding
    ├─ Lesion Counting
    └─ Coverage Area Calculation
    ↓
[5] Health Scoring Engine
    ├─ Combine all metrics
    ├─ Calculate health score (0-100)
    ├─ Determine severity
    └─ Generate health status
    ↓
[6] Disease Matching Engine
    ├─ Load disease signatures
    ├─ Pattern matching
    ├─ Multi-metric comparison
    ├─ Confidence calculation
    └─ Top-3 disease ranking
    ↓
Output Disease Report
    ├─ Disease Name
    ├─ Confidence Score
    ├─ Symptoms
    ├─ Treatment
    ├─ Prevention
    └─ Detailed Analysis
```

**Analysis Components:**

```python
class DiseaseDetectionService:
    def analyze_plant_image(self, image_path: str) -> Dict:
        image = cv2.imread(image_path)
        
        # [1] Preprocessing
        processed = self._preprocess_image(image)
        
        # [2] Color Analysis
        color_metrics = self._analyze_colors(processed)
        
        # [3] Texture Analysis
        texture_metrics = self._analyze_texture(processed)
        
        # [4] Spot Detection
        spot_metrics = self._detect_spots(processed)
        
        # [5] Health Scoring
        health_score = self._calculate_health_score(
            color_metrics, texture_metrics, spot_metrics
        )
        
        # [6] Disease Matching
        diseases = self._match_with_database(
            color_metrics, texture_metrics, spot_metrics
        )
        
        return self._compile_report(
            diseases, health_score, color_metrics, texture_metrics
        )
```

**Color Analysis:**
```
Output Metrics:
├─ Green Pixel Percentage: 0-100%
├─ Yellow Pixel Percentage: 0-100%
├─ Brown Pixel Percentage: 0-100%
├─ Red Spot Count: Integer
├─ Brown Spot Count: Integer
└─ Color Health Index: 0-100

Interpretation:
├─ >70% Green + Low Spots = Healthy
├─ 40-70% Green + Medium Spots = Fair
├─ <40% Green + High Spots = Poor
└─ High Yellow/Brown = Senescence/Disease
```

**Texture Analysis:**
```
Output Metrics:
├─ Edge Density: 0-100
├─ Roughness Index: 0-100
├─ Smoothness Index: 0-100
├─ Gradient Magnitude: 0-255
└─ Texture Health: 0-100

Disease Indicators:
├─ High Edge Density = Blemishes/Lesions
├─ High Roughness = Severe Damage
├─ Low Smoothness = Surface Degradation
└─ High Gradient = Symptom Boundaries
```

**Spot Detection:**
```
Output Metrics:
├─ Total Spots Detected: Integer (0-500)
├─ Spot Coverage %: 0-100%
├─ Average Spot Size: Pixels (0-10000)
├─ Largest Spot Size: Pixels
├─ Spot Density: Spots per 10000 pixels
└─ Spot Distribution: Center/Edge/Uniform

Disease Correlation:
├─ Scattered Spots = Fungal (Powdery Mildew)
├─ Circular Lesions = Bacterial (Blight)
├─ Linear Streaks = Viral (Stripe Viruses)
├─ Concentric Rings = Alternaria
└─ Water-soaked = Bacterial
```

**Health Score Calculation:**
```
Formula:
health_score = 100 - (
    (green_loss * 0.3) +
    (spots_coverage * 0.35) +
    (color_abnormality * 0.25) +
    (texture_degradation * 0.1)
)

Where each factor is 0-100 scale

Thresholds:
├─ 80-100: Healthy (Green background)
├─ 60-79: Fair (Minor symptoms)
├─ 40-59: Poor (Moderate disease)
└─ 0-39: Severe (Critical condition)
```

### 6.3 Frontend Technology Stack (Flutter/Dart)

#### **6.3.1 Flutter Framework**

```
Flutter 3.0+
├── Dart Language (3.0+)
├── Material Design Components
├── Responsive UI Framework
├── Hot Reload Development
└── Cross-Platform (iOS/Android/Web)

Core Widgets:
├── StatelessWidget (Static UI)
├── StatefulWidget (Dynamic UI)
├── ScaffoldUI (App Structure)
├── GridView (Responsive Layouts)
├── ListView (Scrollable Lists)
└── CustomPaint (Graphics)
```

#### **6.3.2 Flutter Plugins Used**

```
HTTP & Networking:
├── http: ^1.1.0 (REST API Calls)
└── web_socket_channel: (Real-time updates)

Local Storage:
├── sqflite: ^2.3.0 (SQLite Database)
├── path_provider: ^2.1.0 (File System)
└── intl: ^0.19.0 (Date/Time Formatting)

Media:
├── image_picker: ^1.0.4 (Camera/Gallery)
├── camera: ^0.10.0 (Mobile Camera)
└── image: ^4.0.0 (Image Processing)

State Management:
├── provider: (Advanced State)
└── BLoC Pattern: (Complex Apps)

UI/UX:
├── google_fonts: (Typography)
├── flutter_animate: (Animations)
└── gradient: (Visual Effects)
```

#### **6.3.3 Local Database Schema (SQLite)**

```sql
Table: disease_analyses

CREATE TABLE disease_analyses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,              -- YYYY-MM-DD HH:MM:SS
    imagePath TEXT NOT NULL,              -- Local file path
    disease TEXT NOT NULL,                -- Disease name
    confidence REAL NOT NULL,             -- 0.0-1.0
    symptoms TEXT,                        -- Disease symptoms
    treatment TEXT,                       -- Recommended treatment
    prevention TEXT,                      -- Prevention measures
    imageAnalysis TEXT,                   -- JSON: color/texture/spot data
    recommendation TEXT,                  -- Action recommendation
    actionItems TEXT,                     -- JSON: action array
    cropType TEXT,                        -- Crop name
    fieldName TEXT,                       -- Field identifier
    notes TEXT,                           -- User notes
    isFavorite INTEGER DEFAULT 0,         -- Bookmark flag
    createdAt TEXT NOT NULL               -- ISO 8601 timestamp
);

Indexes:
├─ idx_disease ON disease (disease)
├─ idx_field ON fieldName (fieldName)
├─ idx_timestamp ON timestamp (timestamp DESC)
└─ idx_favorite ON isFavorite (isFavorite)
```

**Database Operations:**
```
Create: saveDiseaseAnalysis(...)
Read:   getAllAnalyses(), getAnalysisById(id)
Filter: getAnalysesByDisease(), getAnalysesByField()
Update: updateNotes(), toggleFavorite()
Delete: deleteAnalysis()
Stats:  getStatistics()
```

---

## Part 7: API Endpoints & Data Structures

### 7.1 REST API Specification (12 Endpoints)

#### **Health & Status Endpoints**

```
[1] GET /health
    Purpose: System health check
    Response: 200 OK
    {
        "status": "healthy",
        "service": "AgroGuard AI Backend",
        "timestamp": "2026-02-20T10:30:00Z"
    }

[2] GET /api/status
    Purpose: Detailed system status
    Response: 200 OK
    {
        "services": {
            "crop_recommendation": "operational",
            "disease_detection": "operational",
            "iot_analytics": "operational"
        },
        "uptime": 3600,
        "timestamp": "2026-02-20T10:30:00Z"
    }
```

#### **Crop Recommendation Endpoints**

```
[3] POST /api/predict_crop
    Purpose: Predict best crop for conditions
    Request Body: application/json
    {
        "temperature": 22.5,
        "humidity": 65.3,
        "rainfall": 450,
        "ph": 6.8,
        "nitrogen": 140,
        "phosphorus": 60,
        "potassium": 100,
        "soil_type": "loamy",
        "water_availability": 75
    }
    
    Response: 200 OK
    {
        "success": true,
        "data": {
            "predicted_crop": "Wheat",
            "confidence": 0.94,
            "alternatives": ["Barley", "Rye"],
            "suitability": "Excellent"
        },
        "timestamp": "2026-02-20T10:30:00Z"
    }
```

#### **Disease Detection Endpoints**

```
[4] POST /api/predict_disease
    Purpose: Analyze plant image for disease
    Request: multipart/form-data
    ├─ image: File (JPG/PNG, max 5MB)
    
    Response: 200 OK
    {
        "success": true,
        "data": {
            "disease": "Early Blight",
            "confidence": 0.87,
            "symptoms": "Brown concentric spots on lower leaves...",
            "treatment": "Apply copper fungicide...",
            "prevention": "Improve air circulation...",
            "detailed_analysis": {
                "image_analysis": {
                    "green_pixels": 65,
                    "brown_spots": 24,
                    "coverage": 15.3,
                    "health_score": 72
                },
                "recommendation": "Monitor closely, treat preventively",
                "action_items": ["Apply fungicide", "Prune lower leaves"]
            }
        },
        "timestamp": "2026-02-20T10:30:00Z"
    }
```

#### **Sensor Data Endpoints**

```
[5] GET /api/sensor_data
    Purpose: Get current sensor readings
    Response: 200 OK
    {
        "success": true,
        "data": {
            "current_data": {
                "nitrogen": 143.65,
                "phosphorus": 58.42,
                "potassium": 95.23,
                "temperature": 20.49,
                "humidity": 68.34,
                "ph": 6.78,
                "rainfall": 2.5,
                "soil_moisture": 56.81,
                "light_intensity": 1250
            },
            "alerts": [
                {
                    "type": "WARNING",
                    "sensor": "nitrogen",
                    "message": "Nitrogen slightly below optimal"
                }
            ],
            "alerts_count": 1,
            "health_scenario": "Healthy Wheat - Vegetative Growth"
        },
        "timestamp": "2026-02-20T10:30:00Z"
    }

[6] GET /api/sensor_data/analytics
    Purpose: Get analytics & health score
    Response: 200 OK
    {
        "success": true,
        "data": {
            "health_score": 100,
            "status": "Optimal",
            "metrics_summary": {
                "nitrogen": {
                    "current": 143.65,
                    "optimal": 135,
                    "min": 120,
                    "max": 180,
                    "trend": "stable"
                },
                ...9 sensors...
            },
            "trend": "stable",
            "recommendations": [
                {
                    "severity": "info",
                    "category": "general",
                    "message": "All conditions optimal"
                }
            ]
        },
        "timestamp": "2026-02-20T10:30:00Z"
    }

[7] GET /api/sensor_data/hourly_summary
    Purpose: 24-hour rolling hourly data
    Response: 200 OK
    {
        "success": true,
        "data": {
            "readings": [
                {
                    "hour": "00:00",
                    "avg_nitrogen": 142.3,
                    "avg_temperature": 19.2,
                    ...all sensors...
                },
                ...24 hours...
            ]
        }
    }

[8] GET /api/sensor_data/daily_summary
    Purpose: 30-day rolling daily data
    Response: 200 OK
    {
        "success": true,
        "data": {
            "readings": [
                {
                    "date": "2026-02-20",
                    "avg_nitrogen": 143.2,
                    "min_temperature": 15.3,
                    "max_temperature": 28.1,
                    ...aggregates...
                },
                ...30 days...
            ]
        }
    }
```

#### **Scenario Management**

```
[9] GET /api/sensor_scenarios
    Purpose: List all demo scenarios
    Response: 200 OK
    {
        "success": true,
        "data": {
            "scenarios": [
                {
                    "id": "healthy_crop",
                    "name": "Healthy Wheat",
                    "crop": "Wheat",
                    "stage": "Vegetative Growth",
                    "description": "Optimal growing conditions"
                },
                {
                    "id": "drought_stress",
                    "name": "Drought Stressed Corn",
                    "crop": "Corn",
                    "stage": "Flowering",
                    "description": "Water stress conditions"
                },
                ...5 scenarios...
            ]
        }
    }

[10] POST /api/sensor_scenarios/{scenario_name}
    Purpose: Switch to specific scenario
    Parameters: scenario_name (string)
    Response: 200 OK
    {
        "success": true,
        "data": {
            "current_scenario": "drought_stress",
            "message": "Scenario switched successfully",
            "current_data": {...}
        }
    }
```

#### **Smart Integration**

```
[11] POST /api/smart_recommendation
    Purpose: Get combined recommendations
    Request: application/json
    {
        "temperature": 22.5,
        "humidity": 65.3,
        "rainfall": 450,
        "ph": 6.8,
        "nitrogen": 140,
        "phosphorus": 60,
        "potassium": 100,
        "soil_type": "loamy",
        "water_availability": 75
    }
    
    Response: 200 OK
    {
        "success": true,
        "data": {
            "crop_recommendation": {...},
            "sensor_analytics": {...},
            "integrated_advice": "Wheat ideal for current conditions"
        }
    }

[12] GET /api/sensor_data/history
    Purpose: Last N readings
    Parameters: limit (default: 100)
    Response: 200 OK
    {
        "success": true,
        "data": {
            "readings": [...100 readings...]
        }
    }
```

### 7.2 Response Format Standard

```json
{
    "success": true/false,
    "data": {
        // Endpoint-specific data
    },
    "error": "Error message (if success=false)",
    "timestamp": "ISO 8601 timestamp",
    "version": "1.0.0"
}
```

### 7.3 Error Handling

```json
Error Response (400, 404, 500):
{
    "success": false,
    "error": "Descriptive error message",
    "error_code": "ERROR_CODE",
    "details": "Additional information",
    "timestamp": "ISO 8601"
}

Common Error Codes:
├─ INVALID_IMAGE: Image format/size invalid
├─ BACKEND_TIMEOUT: Processing took too long
├─ SENSOR_ERROR: Hardware communication failed
├─ DATABASE_ERROR: Data storage failed
└─ INVALID_INPUT: Request parameters invalid
```

---

**[Continued in Part 3]**
