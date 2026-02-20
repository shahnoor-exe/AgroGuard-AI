"""
AgroGuard AI - Mock Backend Server
This is a simple Flask backend for testing the Flutter Web application
without needing to implement the full ML model.

Usage:
    pip install flask flask-cors pillow
    python mock_backend.py
    
The server will run on http://localhost:5000
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import base64
from datetime import datetime
import random
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Mock disease database
DISEASES = {
    'tomato': ['Early Blight', 'Late Blight', 'Septoria Leaf Spot', 'Healthy'],
    'potato': ['Late Blight', 'Early Blight', 'Healthy'],
    'corn': ['Northern Corn Leaf Blight', 'Gray Leaf Spot', 'Healthy'],
    'wheat': ['Powdery Mildew', 'Yellow Rust', 'Healthy'],
    'rice': ['Brown Spot', 'Leaf Blast', 'Healthy'],
}

RECOMMENDATIONS = {
    'Early Blight': 'Remove infected leaves. Apply copper-based fungicide. Improve air circulation.',
    'Late Blight': 'Use potassium phosphite fungicide. Maintain dry conditions. Remove infected tissue.',
    'Septoria Leaf Spot': 'Apply mancozeb fungicide. Remove infected leaves. Avoid overhead irrigation.',
    'Northern Corn Leaf Blight': 'Use triazole fungicide. Plant resistant varieties. Crop rotation.',
    'Gray Leaf Spot': 'Apply azoxystrobin fungicide. Use resistant hybrids. Remove crop debris.',
    'Powdery Mildew': 'Apply sulfur-based fungicide. Thin plants for better air flow. Avoid powdering.',
    'Yellow Rust': 'Use triazole fungicides. Plant resistant varieties. Scout regularly.',
    'Brown Spot': 'Improve drainage. Apply zinc and manganese fertilizer. Use resistant varieties.',
    'Leaf Blast': 'Use tricyclazole fungicide. Avoid overwatering. Reduce nitrogen fertilizer.',
    'Healthy': 'No action needed. Continue regular maintenance and monitoring.',
}


@app.route('/', methods=['GET'])
def index():
    """Health check endpoint"""
    return jsonify({
        'status': 'running',
        'app': 'AgroGuard AI Mock Backend',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    }), 200


@app.route('/predict', methods=['POST'])
def predict():
    """
    Disease prediction endpoint
    Accepts multipart form data with image file
    Returns predicted disease and confidence score
    """
    try:
        # Check if file is present
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Get file extension to determine crop type (mock logic)
        filename = file.filename.lower()
        crop_type = 'tomato'  # Default
        
        # Simple mock crop detection based on filename
        for crop in DISEASES.keys():
            if crop in filename:
                crop_type = crop
                break
        
        # Get random disease and confidence
        diseases = DISEASES.get(crop_type, DISEASES['tomato'])
        disease = random.choice(diseases)
        confidence = round(random.uniform(0.75, 0.99), 2)
        
        # Get recommendation
        recommendation = RECOMMENDATIONS.get(
            disease,
            'Regular monitoring recommended. Consult local agronomist for specific guidance.'
        )
        
        response = {
            'disease': disease,
            'crop': crop_type.capitalize(),
            'confidence': confidence,
            'recommendations': recommendation,
            'timestamp': datetime.now().isoformat(),
            'model': 'Mock AI Model v1.0'
        }
        
        print(f"[PREDICT] {crop_type} - {disease} (confidence: {confidence})")
        return jsonify(response), 200
        
    except Exception as e:
        print(f"[ERROR] Prediction failed: {str(e)}")
        return jsonify({'error': str(e)}), 500


@app.route('/sensor', methods=['GET'])
def get_sensor_data():
    """
    Real-time sensor data endpoint
    Returns mock soil moisture, temperature, and humidity readings
    """
    try:
        # Generate realistic mock sensor data
        soil_moisture = round(random.uniform(30, 80), 1)
        temperature = round(random.uniform(20, 35), 1)
        humidity = round(random.uniform(40, 90), 1)
        
        response = {
            'soil_moisture': soil_moisture,
            'temperature': temperature,
            'humidity': humidity,
            'timestamp': datetime.now().isoformat(),
            'unit_moisture': '%',
            'unit_temperature': '°C',
            'unit_humidity': '%',
            'location': 'Farm Plot 1'
        }
        
        print(f"[SENSOR] SM: {soil_moisture}% | Temp: {temperature}°C | Humidity: {humidity}%")
        return jsonify(response), 200
        
    except Exception as e:
        print(f"[ERROR] Sensor data failed: {str(e)}")
        return jsonify({'error': str(e)}), 500


@app.route('/sensor/history', methods=['GET'])
def get_sensor_history():
    """
    Historical sensor data endpoint (for future use)
    Returns list of past sensor readings
    """
    try:
        history = []
        for i in range(10):
            history.append({
                'timestamp': datetime.now().isoformat(),
                'soil_moisture': round(random.uniform(30, 80), 1),
                'temperature': round(random.uniform(20, 35), 1),
                'humidity': round(random.uniform(40, 90), 1),
            })
        
        return jsonify({
            'data': history,
            'count': len(history)
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/predictions/history', methods=['GET'])
def get_predictions_history():
    """
    Get historical predictions (for future use)
    Returns list of past predictions
    """
    try:
        crops = list(DISEASES.keys())
        history = []
        
        for i in range(5):
            crop = random.choice(crops)
            disease = random.choice(DISEASES[crop])
            
            history.append({
                'id': str(i + 1),
                'crop': crop.capitalize(),
                'disease': disease,
                'confidence': round(random.uniform(0.75, 0.99), 2),
                'recommendations': RECOMMENDATIONS.get(disease, 'Regular monitoring.'),
                'timestamp': datetime.now().isoformat(),
            })
        
        return jsonify({
            'predictions': history,
            'count': len(history)
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/health', methods=['GET'])
def health_check():
    """System health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'database': 'mock',
        'model_loaded': True
    }), 200


@app.route('/api/info', methods=['GET'])
def api_info():
    """Get API information"""
    return jsonify({
        'name': 'AgroGuard AI Backend',
        'version': '1.0.0',
        'description': 'AI-powered crop disease detection and smart farming advisory system',
        'endpoints': {
            'POST /predict': 'Predict disease from image',
            'GET /sensor': 'Get real-time sensor data',
            'GET /sensor/history': 'Get historical sensor data',
            'GET /predictions/history': 'Get past predictions',
            'GET /health': 'Health check',
            'GET /api/info': 'API information'
        }
    }), 200


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        'error': 'Endpoint not found',
        'message': 'Please check the API documentation'
    }), 404


@app.errorhandler(500)
def server_error(error):
    """Handle 500 errors"""
    return jsonify({
        'error': 'Internal server error',
        'message': str(error)
    }), 500


if __name__ == '__main__':
    print("=" * 60)
    print("🚀 AgroGuard AI - Mock Backend Server")
    print("=" * 60)
    print("Starting Flask server...")
    print("📍 Server running at: http://localhost:5000")
    print("\nEndpoints:")
    print("  POST /predict        - Disease prediction from image")
    print("  GET  /sensor         - Real-time sensor data")
    print("  GET  /health         - Health check")
    print("  GET  /api/info       - API information")
    print("\nPress Ctrl+C to stop the server")
    print("=" * 60)
    
    # Run Flask app
    app.run(
        debug=True,
        host='localhost',
        port=5000,
        use_reloader=True
    )
