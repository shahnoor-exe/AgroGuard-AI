"""
AgroGuard AI Backend - Main Flask Application
Production-ready REST API for crop recommendation and disease detection
"""

import os
import sys
import json
import traceback
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('smartcrop.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Import services
from services.crop_service import CropRecommender
from services.disease_service import DiseaseDetector
from services.iot_service import IOTSimulator

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Configuration
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Initialize ML services
try:
    crop_recommender = CropRecommender()
    disease_detector = DiseaseDetector()
    iot_simulator = IOTSimulator()
    logger.info("✅ ML services initialized successfully")
except Exception as e:
    logger.error(f"❌ Failed to initialize ML services: {str(e)}")
    logger.error(traceback.format_exc())


def allowed_file(filename):
    """Check if file has allowed extension"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


# ============================================================================
# HEALTH CHECK ENDPOINTS
# ============================================================================

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'service': 'AgroGuard AI Backend'
    }), 200


@app.route('/api/status', methods=['GET'])
def api_status():
    """API status endpoint"""
    return jsonify({
        'status': 'operational',
        'version': '1.0.0',
        'endpoints': {
            'crop_recommendation': '/api/predict_crop',
            'disease_detection': '/api/predict_disease',
            'iot_data': '/api/sensor_data',
            'documentation': '/docs'
        }
    }), 200


# ============================================================================
# CROP RECOMMENDATION ENDPOINTS
# ============================================================================

@app.route('/api/predict_crop', methods=['POST'])
def predict_crop():
    """
    Crop recommendation endpoint
    
    Expected JSON:
    {
        "nitrogen": 90.0,
        "phosphorus": 42.0,
        "potassium": 43.0,
        "temperature": 21.77,
        "humidity": 80.0,
        "ph": 6.89,
        "rainfall": 202.9
    }
    """
    try:
        data = request.get_json()
        
        # Validate input
        required_fields = ['nitrogen', 'phosphorus', 'potassium', 
                          'temperature', 'humidity', 'ph', 'rainfall']
        
        if not all(field in data for field in required_fields):
            return jsonify({
                'error': 'Missing required fields',
                'required': required_fields
            }), 400
        
        # Extract features
        features = [
            float(data['nitrogen']),
            float(data['phosphorus']),
            float(data['potassium']),
            float(data['temperature']),
            float(data['humidity']),
            float(data['ph']),
            float(data['rainfall'])
        ]
        
        # Get prediction
        recommendation = crop_recommender.predict(features)
        
        logger.info(f"✅ Crop prediction successful: {recommendation['crop']}")
        
        return jsonify({
            'success': True,
            'crop': recommendation['crop'],
            'confidence': recommendation['confidence'],
            'input': data,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except ValueError as e:
        logger.error(f"❌ Invalid input values: {str(e)}")
        return jsonify({
            'error': 'Invalid input values',
            'message': str(e)
        }), 400
    
    except Exception as e:
        logger.error(f"❌ Crop prediction error: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({
            'error': 'Prediction failed',
            'message': str(e)
        }), 500


# ============================================================================
# DISEASE DETECTION ENDPOINTS
# ============================================================================

@app.route('/api/predict_disease', methods=['POST'])
def predict_disease():
    """
    Disease detection endpoint
    
    Expects multipart/form-data with 'image' file
    """
    try:
        # Check if image is provided
        if 'image' not in request.files:
            return jsonify({
                'error': 'No image provided',
                'message': 'Please upload an image file'
            }), 400
        
        file = request.files['image']
        
        if file.filename == '':
            return jsonify({
                'error': 'No file selected',
                'message': 'Please select a file to upload'
            }), 400
        
        if not allowed_file(file.filename):
            return jsonify({
                'error': 'Invalid file type',
                'allowed': list(ALLOWED_EXTENSIONS)
            }), 400
        
        # Save and process image
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # Get crop_type from form data (sent by Flutter frontend)
        crop_type = request.form.get('crop_type', None)
        
        # Get disease prediction
        result = disease_detector.predict(filepath, crop_type=crop_type)
        
        logger.info(f"✅ Disease prediction successful: {result['disease']}")
        
        # Clean up uploaded file
        if os.path.exists(filepath):
            os.remove(filepath)
        
        return jsonify({
            'success': True,
            'disease': result['disease'],
            'confidence': result['confidence'],
            'symptoms': result.get('symptoms', []),
            'treatment': result.get('treatment', ''),
            'prevention': result.get('prevention', ''),
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Disease prediction error: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({
            'error': 'Prediction failed',
            'message': str(e)
        }), 500


# ============================================================================
# IOT SENSOR DATA ENDPOINTS
# ============================================================================

@app.route('/api/sensor_data', methods=['GET'])
def get_sensor_data():
    """
    Get current IoT sensor data with alerts
    
    Returns current sensor readings and active alerts
    """
    try:
        sensor_data = iot_simulator.get_current_data()
        alerts = iot_simulator.get_alerts()
        
        return jsonify({
            'success': True,
            'current_data': sensor_data,
            'alerts': alerts,
            'alerts_count': len(alerts),
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Sensor data error: {str(e)}")
        return jsonify({
            'error': 'Failed to retrieve sensor data',
            'message': str(e)
        }), 500


@app.route('/api/sensor_data/analytics', methods=['GET'])
def get_sensor_analytics():
    """Get comprehensive sensor analytics and insights"""
    try:
        analytics = iot_simulator.get_analytics()
        
        return jsonify({
            'success': True,
            'analytics': analytics,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Analytics error: {str(e)}")
        return jsonify({
            'error': 'Failed to retrieve analytics',
            'message': str(e)
        }), 500


@app.route('/api/sensor_data/history', methods=['GET'])
def get_sensor_history():
    """Get sensor data history"""
    try:
        limit = request.args.get('limit', 10, type=int)
        history = iot_simulator.get_history(limit)
        
        return jsonify({
            'success': True,
            'data': history,
            'count': len(history),
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Sensor history error: {str(e)}")
        return jsonify({
            'error': 'Failed to retrieve sensor history',
            'message': str(e)
        }), 500


@app.route('/api/sensor_data/hourly_summary', methods=['GET'])
def get_hourly_summary():
    """Get hourly summary of last 24 hours"""
    try:
        summary = iot_simulator.get_hourly_summary()
        
        return jsonify({
            'success': True,
            'data': summary,
            'period': 'last_24_hours',
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Hourly summary error: {str(e)}")
        return jsonify({
            'error': 'Failed to retrieve hourly summary',
            'message': str(e)
        }), 500


@app.route('/api/sensor_data/daily_summary', methods=['GET'])
def get_daily_summary():
    """Get daily summary of last 30 days"""
    try:
        summary = iot_simulator.get_daily_summary()
        
        return jsonify({
            'success': True,
            'data': summary,
            'period': 'last_30_days',
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Daily summary error: {str(e)}")
        return jsonify({
            'error': 'Failed to retrieve daily summary',
            'message': str(e)
        }), 500


@app.route('/api/sensor_scenarios', methods=['GET'])
def get_scenarios():
    """Get available demo scenarios"""
    try:
        scenarios = iot_simulator.get_scenarios()
        current_scenario = iot_simulator.scenario
        
        return jsonify({
            'success': True,
            'scenarios': scenarios,
            'current_scenario': current_scenario,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Scenarios error: {str(e)}")
        return jsonify({
            'error': 'Failed to retrieve scenarios',
            'message': str(e)
        }), 500


@app.route('/api/sensor_scenarios/<scenario_name>', methods=['POST'])
def set_scenario(scenario_name):
    """Switch to a different demo scenario"""
    try:
        success = iot_simulator.set_scenario(scenario_name)
        
        if success:
            new_data = iot_simulator.get_current_data()
            return jsonify({
                'success': True,
                'message': f'Scenario switched to: {scenario_name}',
                'new_scenario': scenario_name,
                'current_data': new_data,
                'timestamp': datetime.now().isoformat()
            }), 200
        else:
            return jsonify({
                'success': False,
                'error': 'Invalid scenario name',
                'available_scenarios': list(iot_simulator.get_scenarios().keys())
            }), 400
        
    except Exception as e:
        logger.error(f"❌ Scenario switch error: {str(e)}")
        return jsonify({
            'error': 'Failed to switch scenario',
            'message': str(e)
        }), 500


# ============================================================================
# COMBINED RECOMMENDATION ENDPOINT
# ============================================================================

@app.route('/api/smart_recommendation', methods=['POST'])
def smart_recommendation():
    """
    Smart recommendation endpoint
    
    Combines crop recommendation and disease detection
    Also considers IoT sensor data
    """
    try:
        data = request.get_json()
        
        # Get crop recommendation
        crop_features = [
            float(data.get('nitrogen', 0)),
            float(data.get('phosphorus', 0)),
            float(data.get('potassium', 0)),
            float(data.get('temperature', 0)),
            float(data.get('humidity', 0)),
            float(data.get('ph', 0)),
            float(data.get('rainfall', 0))
        ]
        
        crop_result = crop_recommender.predict(crop_features)
        current_sensors = iot_simulator.get_current_data()
        
        return jsonify({
            'success': True,
            'recommendation': {
                'crop': crop_result['crop'],
                'confidence': crop_result['confidence'],
                'current_conditions': current_sensors
            },
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Smart recommendation error: {str(e)}")
        return jsonify({
            'error': 'Recommendation failed',
            'message': str(e)
        }), 500


# ============================================================================
# ERROR HANDLERS
# ============================================================================

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested endpoint does not exist',
        'path': request.path
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"❌ Internal server error: {str(error)}")
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An unexpected error occurred'
    }), 500


# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

if __name__ == '__main__':
    logger.info("🌾 AgroGuard AI Backend Starting...")
    logger.info("Loading ML models and services...")
    
    # Run Flask app
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True,
        use_reloader=False
    )
