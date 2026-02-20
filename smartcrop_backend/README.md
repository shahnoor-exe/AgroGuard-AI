# 🌾 SmartCrop AI - Backend API

**Production-Ready REST API for Crop Recommendation & Disease Detection**

Complete Flask backend for the SmartCrop AI full-stack agriculture system.

---

## 🎯 Features

✅ **Crop Recommendation API** - AI-powered crop suggestions based on soil and weather data  
✅ **Disease Detection API** - CNN-based plant disease identification from leaf images  
✅ **IoT Sensor Integration** - Real-time sensor data with simulation mode  
✅ **Treatment Database** - Comprehensive disease treatment and prevention guide  
✅ **RESTful API** - Clean, well-documented REST endpoints  
✅ **CORS Enabled** - Cross-origin requests from Flutter frontend  
✅ **Error Handling** - Comprehensive error handling and logging  
✅ **Production Ready** - Scalable and maintainable codebase  

---

## 📁 Project Structure

```
smartcrop_backend/
├── app.py                      # Main Flask application
├── requirements.txt            # Python dependencies
├── services/
│   ├── __init__.py
│   ├── crop_service.py         # Crop recommendation logic
│   ├── disease_service.py      # Disease detection logic
│   └── iot_service.py          # IoT sensor simulator
├── models/
│   ├── crop_model.pkl          # Trained RandomForest model
│   └── disease_model.h5        # Trained CNN model
├── datasets/
│   └── treatment_data.csv      # Disease treatment database
├── uploads/                    # Temporary image uploads
├── smartcrop.log               # Application logs
└── README.md
```

---

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- pip package manager
- Virtual environment (recommended)

### Installation

1. **Create virtual environment**
```bash
python -m venv venv
source venv/Scripts/activate  # Windows
# or
source venv/bin/activate      # Linux/Mac
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Place your trained models**
```
models/
  ├── crop_model.pkl           # Place your trained model here
  └── disease_model.h5         # Place your trained model here
```

4. **Run the server**
```bash
python app.py
```

Server starts at: **http://localhost:5000**

---

## 📚 API Endpoints

### 1. Health Check
```
GET /health
```
**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-02-20T10:30:00",
  "service": "AgroGuard AI Backend"
}
```

### 2. Crop Recommendation
```
POST /api/predict_crop
Content-Type: application/json

{
  "nitrogen": 90.0,
  "phosphorus": 42.0,
  "potassium": 43.0,
  "temperature": 21.77,
  "humidity": 80.0,
  "ph": 6.89,
  "rainfall": 202.9
}
```

**Response:**
```json
{
  "success": true,
  "crop": "Rice",
  "confidence": 0.92,
  "input": {...},
  "timestamp": "2024-02-20T10:30:00"
}
```

### 3. Disease Detection
```
POST /api/predict_disease
Content-Type: multipart/form-data

image: <image_file>
```

**Response:**
```json
{
  "success": true,
  "disease": "Tomato_late_blight",
  "confidence": 0.89,
  "symptoms": "Water-soaked spots on leaves",
  "treatment": "Apply copper fungicide",
  "prevention": "Avoid overhead watering",
  "timestamp": "2024-02-20T10:30:00"
}
```

### 4. IoT Sensor Data
```
GET /api/sensor_data
```

**Response:**
```json
{
  "success": true,
  "data": {
    "nitrogen": 85.5,
    "phosphorus": 40.2,
    "potassium": 42.8,
    "temperature": 22.5,
    "humidity": 75.0,
    "ph": 6.8,
    "rainfall": 200.0,
    "soil_moisture": 65.0,
    "light_intensity": 500.0,
    "timestamp": "2024-02-20T10:30:00"
  },
  "timestamp": "2024-02-20T10:30:00"
}
```

### 5. Sensor History
```
GET /api/sensor_data/history?limit=10
```

**Response:**
```json
{
  "success": true,
  "data": [...],
  "count": 10,
  "timestamp": "2024-02-20T10:30:00"
}
```

### 6. Smart Recommendation (Combined)
```
POST /api/smart_recommendation
Content-Type: application/json

{
  "nitrogen": 90.0,
  "phosphorus": 42.0,
  ...
}
```

---

## 🔧 Configuration

### Environment Variables
Create `.env` file (optional):
```
FLASK_ENV=development
FLASK_DEBUG=True
UPLOAD_FOLDER=uploads
MAX_CONTENT_LENGTH=16777216
```

### Logging
Logs are saved to `smartcrop.log` and printed to console.

---

## 🤖 ML Models

### Crop Recommendation Model
- **Type**: RandomForestClassifier
- **Features**: N, P, K, Temperature, Humidity, pH, Rainfall
- **Output**: Crop Name
- **File**: `models/crop_model.pkl`

### Disease Detection Model
- **Type**: CNN (TensorFlow/Keras)
- **Input**: Leaf image (224x224)
- **Output**: Disease class
- **File**: `models/disease_model.h5`

---

## 📊 Treatment Database

Contains disease information for:
- Symptoms identification
- Treatment recommendations
- Prevention strategies
- 40+ plant diseases

**File**: `datasets/treatment_data.csv`

---

## 🐛 Error Handling

All errors return JSON with status code:

```json
{
  "error": "Error type",
  "message": "Detailed error message"
}
```

**Status Codes:**
- `200` - Success
- `400` - Bad request
- `404` - Not found
- `500` - Internal server error

---

## 📝 Development

### Adding New Endpoints

1. Create service method
2. Add route in `app.py`
3. Handle errors appropriately
4. Add logging
5. Test with curl or Postman

### Example:
```python
@app.route('/api/new_endpoint', methods=['POST'])
def new_endpoint():
    try:
        data = request.get_json()
        result = some_service.process(data)
        return jsonify({'success': True, 'data': result}), 200
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500
```

---

## 🚀 Deployment

### Docker
```dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

Run:
```bash
docker build -t smartcrop-api .
docker run -p 5000:5000 smartcrop-api
```

### Production Server (Gunicorn)
```bash
pip install gunicorn
gunicorn --workers 4 --bind 0.0.0.0:5000 app:app
```

### Cloud Deployment
- **Heroku**: Add `Procfile` with `web: gunicorn app:app`
- **AWS**: Deploy to EC2 or Lambda
- **Google Cloud**: Deploy to App Engine
- **Azure**: Deploy to App Service

---

## 📋 Testing

### Test Crop Prediction
```bash
curl -X POST http://localhost:5000/api/predict_crop \
  -H "Content-Type: application/json" \
  -d '{
    "nitrogen": 90,
    "phosphorus": 42,
    "potassium": 43,
    "temperature": 21.77,
    "humidity": 80,
    "ph": 6.89,
    "rainfall": 202.9
  }'
```

### Test Disease Detection
```bash
curl -X POST http://localhost:5000/api/predict_disease \
  -F "image=@leaf_image.jpg"
```

---

## 📚 Dependencies

- **Flask** - Web framework
- **scikit-learn** - ML models
- **TensorFlow** - Deep learning
- **Pillow** - Image processing
- **Pandas** - Data handling
- **NumPy** - Numerical computing

---

## 🔒 Security

- ✅ CORS enabled
- ✅ File upload validation
- ✅ Input validation
- ✅ Error handling
- ⚠️ Consider adding authentication for production

---

## 📖 Documentation

API documentation available at:
- Main app: http://localhost:5000/
- Health check: http://localhost:5000/health
- Status: http://localhost:5000/api/status

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Port 5000 in use | `lsof -ti:5000 \| xargs kill -9` or use different port |
| Model not found | Ensure models in `models/` folder |
| Import errors | `pip install -r requirements.txt` |
| CORS errors | Check CORS headers in response |
| Out of memory | Reduce image size or batch processing |

---

## 📞 Support

For issues:
1. Check `smartcrop.log`
2. Verify model files exist
3. Test endpoints with curl/Postman
4. Check Python version compatibility

---

## 📄 License

Part of AgroGuard AI project for agricultural innovation.

---

## 🎉 Ready to Deploy!

Your backend is production-ready and scalable! 🚀

Connect with Flutter frontend at `localhost:5000` 🌾
