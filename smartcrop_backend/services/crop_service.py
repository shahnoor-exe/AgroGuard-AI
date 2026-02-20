"""
Crop Recommendation Service
Loads and uses the trained RandomForestClassifier model
"""

import os
import pickle
import numpy as np
import logging

logger = logging.getLogger(__name__)


class CropRecommender:
    """Service for crop recommendation using ML model"""
    
    def __init__(self):
        """Initialize crop recommender with trained model"""
        self.model = None
        self.crops = [
            'Rice', 'Maize', 'Chickpea', 'Kidneybeans', 'Pigeonpeas',
            'Mothbeans', 'Mungbean', 'Blackgram', 'Lentil', 'Pomegranate',
            'Banana', 'Mango', 'Grapes', 'Watermelon', 'Muskmelon',
            'Apple', 'Orange', 'Papaya', 'Coconut', 'Cotton',
            'Sugarcane', 'Tobacco', 'Arecanut', 'Turmeric', 'Pepper',
            'Cardamom', 'Chick_pea', 'Corn', 'Wheat'
        ]
        
        self.load_model()
    
    def load_model(self):
        """Load trained crop model from pickle file"""
        try:
            model_path = 'models/crop_model.pkl'
            
            if os.path.exists(model_path):
                with open(model_path, 'rb') as f:
                    self.model = pickle.load(f)
                logger.info("✅ Crop model loaded successfully")
            else:
                logger.warning(f"⚠️ Model not found at {model_path}, using mock model")
                self.model = None
                
        except Exception as e:
            logger.error(f"❌ Error loading crop model: {str(e)}")
            self.model = None
    
    def predict(self, features):
        """
        Predict recommended crop
        
        Args:
            features: List of [N, P, K, temperature, humidity, pH, rainfall]
        
        Returns:
            Dict with crop name and confidence
        """
        try:
            if self.model is None:
                # Return mock prediction
                return {
                    'crop': 'Rice',
                    'confidence': 0.92
                }
            
            # Prepare features
            X = np.array([features])
            
            # Get prediction and probability
            prediction = self.model.predict(X)[0]
            probabilities = self.model.predict_proba(X)[0]
            confidence = float(max(probabilities))
            
            logger.info(f"Crop prediction: {prediction} (confidence: {confidence:.2%})")
            
            return {
                'crop': str(prediction),
                'confidence': round(confidence, 4)
            }
            
        except Exception as e:
            logger.error(f"Error in crop prediction: {str(e)}")
            raise
    
    def get_crop_info(self, crop_name):
        """Get information about a specific crop"""
        crop_info = {
            'Rice': {
                'nitrogen': '80-100',
                'phosphorus': '40-60',
                'potassium': '40-60',
                'ideal_temperature': '20-30°C',
                'ideal_humidity': '70-80%',
                'ideal_ph': '6.0-7.0',
                'min_rainfall': '100-200cm'
            },
            'Maize': {
                'nitrogen': '100-150',
                'phosphorus': '60-80',
                'potassium': '40-60',
                'ideal_temperature': '20-27°C',
                'ideal_humidity': '60-70%',
                'ideal_ph': '6.0-7.5',
                'min_rainfall': '50-100cm'
            },
            'Wheat': {
                'nitrogen': '80-120',
                'phosphorus': '60-90',
                'potassium': '40-70',
                'ideal_temperature': '15-25°C',
                'ideal_humidity': '60-70%',
                'ideal_ph': '6.0-7.5',
                'min_rainfall': '40-100cm'
            }
        }
        
        return crop_info.get(crop_name, {})
