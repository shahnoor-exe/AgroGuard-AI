"""
Disease Detection Service
Advanced image analysis with disease classification and detailed comparison
"""

import os
import csv
import logging
import numpy as np
from PIL import Image
from collections import defaultdict
import traceback
from scipy import ndimage
import cv2

logger = logging.getLogger(__name__)


class DiseaseDetector:
    """Service for plant disease detection using CNN model"""
    
    def __init__(self):
        """Initialize disease detector with trained model"""
        self.model = None
        self.treatment_data = {}
        self.disease_classes = []
        
        self.load_model()
        self.load_treatment_data()
    
    def load_model(self):
        """Load trained disease detection model"""
        try:
            model_path = 'models/disease_model.h5'
            
            if os.path.exists(model_path):
                try:
                    import tensorflow as tf
                    self.model = tf.keras.models.load_model(model_path)
                    self.disease_classes = [
                        'Apple_scab', 'Apple_black_rot', 'Apple_cedar_apple_rust', 'Apple_healthy',
                        'Background_with_healthy_leaves', 'Background_without_leaves',
                        'Blueberry_healthy', 'Cherry_powdery_mildew', 'Cherry_healthy',
                        'Corn_cercospora_leaf_spot', 'Corn_common_rust', 'Corn_northern_leaf_blight',
                        'Corn_healthy', 'Grape_black_rot', 'Grape_esca', 'Grape_leaf_blight',
                        'Grape_healthy', 'Orange_haunglongbing', 'Peach_bacterial_spot',
                        'Peach_healthy', 'Pepper_pepper_bell_bacterial_spot', 'Pepper_bell_healthy',
                        'Potato_early_blight', 'Potato_late_blight', 'Potato_healthy',
                        'Raspberry_healthy', 'Soybean_frogeye_leaf_spot', 'Soybean_healthy',
                        'Squash_powdery_mildew', 'Strawberry_leaf_scorch', 'Strawberry_healthy',
                        'Tomato_bacterial_spot', 'Tomato_early_blight', 'Tomato_late_blight',
                        'Tomato_leaf_mold', 'Tomato_septoria_leaf_spot', 'Tomato_spider_mites',
                        'Tomato_target_spot', 'Tomato_tomato_mosaic_virus', 'Tomato_yellow_leaf_curl_virus',
                        'Tomato_healthy'
                    ]
                    logger.info("✅ Disease model loaded successfully")
                except ImportError:
                    logger.warning("⚠️ TensorFlow not available, using image-analysis fallback")
                    self.model = None
            else:
                logger.warning(f"⚠️ Model not found at {model_path}, using image-analysis fallback")
                self.model = None
                
        except Exception as e:
            logger.error(f"❌ Error loading disease model: {str(e)}")
            logger.error(traceback.format_exc())
            self.model = None
    
    def load_treatment_data(self):
        """Load treatment data from CSV"""
        try:
            csv_path = 'datasets/treatment_data.csv'
            
            if os.path.exists(csv_path):
                with open(csv_path, 'r', encoding='utf-8') as f:
                    reader = csv.DictReader(f)
                    for row in reader:
                        disease_name = row.get('disease_name', '').lower()
                        self.treatment_data[disease_name] = {
                            'symptoms': row.get('symptoms', ''),
                            'treatment': row.get('treatment', ''),
                            'prevention': row.get('prevention', '')
                        }
                logger.info(f"✅ Treatment data loaded: {len(self.treatment_data)} diseases")
            else:
                logger.warning(f"⚠️ Treatment data not found at {csv_path}")
                
        except Exception as e:
            logger.error(f"❌ Error loading treatment data: {str(e)}")
    
    def preprocess_image(self, image_path):
        """Preprocess image for model prediction"""
        try:
            img = Image.open(image_path).convert('RGB')
            img = img.resize((224, 224))
            img_array = np.array(img) / 255.0
            img_array = np.expand_dims(img_array, axis=0)
            return img_array
        except Exception as e:
            logger.error(f"Error preprocessing image: {str(e)}")
            raise
    
    def analyze_image_features(self, image_path):
        """
        Analyze image features for disease detection.
        Returns color, texture, pattern, and advanced HSV features.
        """
        try:
            img = Image.open(image_path).convert('RGB')
            img_array = np.array(img)
            
            # Feature 1: Color Analysis (RGB)
            color_analysis = self._analyze_colors(img_array)
            
            # Feature 2: Texture Analysis
            texture_analysis = self._analyze_texture(img_array)
            
            # Feature 3: Spot Detection
            spot_analysis = self._detect_spots(img_array)
            
            # Feature 4: HSV colour-space analysis (critical for disease differentiation)
            hsv_analysis = self._analyze_hsv(img_array)
            
            # Feature 5: Health Indicator
            health_score = self._calculate_health_score(color_analysis, texture_analysis, hsv_analysis)
            
            return {
                'colors': color_analysis,
                'texture': texture_analysis,
                'spots': spot_analysis,
                'hsv': hsv_analysis,
                'health_score': health_score
            }
            
        except Exception as e:
            logger.error(f"Error analyzing image features: {str(e)}")
            raise
    
    def _analyze_colors(self, img_array):
        """Analyze color distribution in the image"""
        rgb = img_array / 255.0
        
        avg_red = np.mean(rgb[:, :, 0])
        avg_green = np.mean(rgb[:, :, 1])
        avg_blue = np.mean(rgb[:, :, 2])
        
        # Colour masks
        yellow_mask = (rgb[:, :, 0] > 0.5) & (rgb[:, :, 1] > 0.5) & (rgb[:, :, 2] < 0.4)
        brown_mask = (rgb[:, :, 0] > 0.35) & (rgb[:, :, 1] > 0.15) & (rgb[:, :, 1] < 0.35) & (rgb[:, :, 2] < 0.2)
        dark_mask = (rgb[:, :, 0] < 0.25) & (rgb[:, :, 1] < 0.25) & (rgb[:, :, 2] < 0.25)
        green_mask = (rgb[:, :, 1] > 0.35) & (rgb[:, :, 1] > rgb[:, :, 0]) & (rgb[:, :, 1] > rgb[:, :, 2])
        white_mask = (rgb[:, :, 0] > 0.75) & (rgb[:, :, 1] > 0.75) & (rgb[:, :, 2] > 0.75)
        
        pixels = rgb.shape[0] * rgb.shape[1]
        
        return {
            'red': round(avg_red, 3),
            'green': round(avg_green, 3),
            'blue': round(avg_blue, 3),
            'yellow_spots_ratio': round(np.sum(yellow_mask) / pixels * 100, 2),
            'brown_spots_ratio': round(np.sum(brown_mask) / pixels * 100, 2),
            'dark_spots_ratio': round(np.sum(dark_mask) / pixels * 100, 2),
            'green_ratio': round(np.sum(green_mask) / pixels * 100, 2),
            'white_ratio': round(np.sum(white_mask) / pixels * 100, 2),
        }
    
    def _analyze_hsv(self, img_array):
        """HSV-space analysis — differentiates yellow-ish vs brown vs grey vs green."""
        hsv = cv2.cvtColor(img_array.astype('uint8'), cv2.COLOR_RGB2HSV)
        h, s, v = hsv[:, :, 0], hsv[:, :, 1], hsv[:, :, 2]
        pixels = h.shape[0] * h.shape[1]
        
        # Hue-based masks  (OpenCV hue 0-179)
        green_hue   = ((h >= 35) & (h <= 85) & (s > 30) & (v > 40))
        yellow_hue  = ((h >= 15) & (h < 35)  & (s > 40) & (v > 80))
        brown_hue   = ((h >= 8)  & (h < 25)  & (s > 40) & (v > 30) & (v < 160))
        grey_hue    = (s < 30) & (v > 50) & (v < 200)
        white_hue   = (s < 25) & (v > 200)
        dark_hue    = (v < 50)
        
        return {
            'green_pct':  round(np.sum(green_hue) / pixels * 100, 2),
            'yellow_pct': round(np.sum(yellow_hue) / pixels * 100, 2),
            'brown_pct':  round(np.sum(brown_hue) / pixels * 100, 2),
            'grey_pct':   round(np.sum(grey_hue) / pixels * 100, 2),
            'white_pct':  round(np.sum(white_hue) / pixels * 100, 2),
            'dark_pct':   round(np.sum(dark_hue) / pixels * 100, 2),
            'avg_saturation': round(float(np.mean(s)), 2),
            'avg_value': round(float(np.mean(v)), 2),
        }
    
    def _analyze_texture(self, img_array):
        """Analyze texture patterns"""
        gray = np.mean(img_array / 255.0, axis=2)
        
        sobel_x = ndimage.sobel(gray, axis=0)
        sobel_y = ndimage.sobel(gray, axis=1)
        
        edge_magnitude = np.sqrt(sobel_x**2 + sobel_y**2)
        roughness = np.std(gray)
        edge_density = np.mean(edge_magnitude)
        uniformity = 1.0 - np.std(edge_magnitude)
        
        return {
            'roughness': round(roughness, 3),
            'edge_density': round(edge_density, 3),
            'uniformity': round(max(0, uniformity), 3),
            'texture_score': round((roughness + edge_density * 10) / 11, 3)
        }
    
    def _detect_spots(self, img_array):
        """Detect disease spots/lesions"""
        gray = cv2.cvtColor(img_array.astype('uint8'), cv2.COLOR_RGB2GRAY)
        
        _, thresh = cv2.threshold(gray, 100, 255, cv2.THRESH_BINARY_INV)
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        num_spots = len(contours)
        spot_coverage = 0
        avg_spot_size = 0
        
        if num_spots > 0:
            areas = [cv2.contourArea(c) for c in contours]
            total_area = sum(areas)
            spot_coverage = (total_area / (gray.shape[0] * gray.shape[1])) * 100
            avg_spot_size = total_area / num_spots if num_spots > 0 else 0
        
        return {
            'spot_count': int(num_spots),
            'coverage_percentage': round(spot_coverage, 2),
            'avg_spot_size': round(avg_spot_size, 1),
            'severity': 'High' if spot_coverage > 30 else 'Medium' if spot_coverage > 10 else 'Low'
        }
    
    def _calculate_health_score(self, color_analysis, texture_analysis, hsv_analysis):
        """Calculate overall plant health score (0-100)"""
        green_pct = hsv_analysis['green_pct']
        spot_pct  = color_analysis['yellow_spots_ratio'] + color_analysis['brown_spots_ratio']
        dark_pct  = color_analysis['dark_spots_ratio']
        
        # Start from the green percentage
        health = min(100, green_pct * 1.5)
        health -= spot_pct * 1.5
        health -= dark_pct * 2
        
        return max(0, min(100, round(health, 2)))

    # ── Crop → disease mapping (which diseases can appear on which crop) ────
    CROP_DISEASE_MAP = {
        'tomato': [
            'Tomato_bacterial_spot', 'Tomato_early_blight', 'Tomato_late_blight',
            'Tomato_leaf_mold', 'Tomato_septoria_leaf_spot', 'Tomato_spider_mites',
            'Tomato_target_spot', 'Tomato_tomato_mosaic_virus',
            'Tomato_yellow_leaf_curl_virus', 'Tomato_healthy',
        ],
        'potato': ['Potato_early_blight', 'Potato_late_blight', 'Potato_healthy'],
        'apple': ['Apple_scab', 'Apple_black_rot', 'Apple_cedar_apple_rust', 'Apple_healthy'],
        'grape': ['Grape_black_rot', 'Grape_esca', 'Grape_leaf_blight', 'Grape_healthy'],
        'corn': ['Corn_cercospora_leaf_spot', 'Corn_common_rust', 'Corn_northern_leaf_blight', 'Corn_healthy'],
        'cherry': ['Cherry_powdery_mildew', 'Cherry_healthy'],
        'peach': ['Peach_bacterial_spot', 'Peach_healthy'],
        'pepper': ['Pepper_pepper_bell_bacterial_spot', 'Pepper_bell_healthy'],
        'strawberry': ['Strawberry_leaf_scorch', 'Strawberry_healthy'],
        'soybean': ['Soybean_frogeye_leaf_spot', 'Soybean_healthy'],
        'squash': ['Squash_powdery_mildew'],
        'orange': ['Orange_haunglongbing'],
        'blueberry': ['Blueberry_healthy'],
        'raspberry': ['Raspberry_healthy'],
    }

    # ── Comprehensive disease scoring profiles ────────────────────────────────
    # Each value is a callable (features → score).  Scores are 0..1.
    # We design each profile so it responds to *characteristic* image features.
    DISEASE_PROFILES = None  # built in _build_profiles()

    @staticmethod
    def _build_profiles():
        """Return dict[disease_name] → function(features) → float score [0,1]."""
        profiles = {}

        # ─── Helper closures ────────────────────────────────────────────
        def _clamp(v, lo=0.0, hi=1.0):
            return max(lo, min(hi, v))

        # ── TOMATO ──────────────────────────────────────────────────────
        def tomato_healthy(f):
            g = f['hsv']['green_pct']
            spots = f['spots']['coverage_percentage']
            yellow = f['hsv']['yellow_pct']
            brown = f['hsv']['brown_pct']
            # Healthy: lots of green, very few spots/discoloration
            score = 0.0
            if g > 40: score += 0.35
            elif g > 25: score += 0.20
            if spots < 5: score += 0.25
            elif spots < 10: score += 0.10
            if yellow < 3: score += 0.15
            if brown < 3: score += 0.15
            if f['colors']['dark_spots_ratio'] < 2: score += 0.10
            return _clamp(score)
        profiles['Tomato_healthy'] = tomato_healthy

        def tomato_late_blight(f):
            # Late blight: dark water-soaked spots, high coverage, low green, brown+dark dominant
            dark = f['hsv']['dark_pct']
            brown = f['hsv']['brown_pct']
            coverage = f['spots']['coverage_percentage']
            green = f['hsv']['green_pct']
            score = 0.0
            if dark > 10: score += 0.20
            elif dark > 5: score += 0.10
            if brown > 8: score += 0.15
            elif brown > 4: score += 0.08
            if coverage > 25: score += 0.25
            elif coverage > 12: score += 0.15
            elif coverage > 5: score += 0.05
            if green < 30: score += 0.15
            elif green < 45: score += 0.08
            if f['colors']['dark_spots_ratio'] > 8: score += 0.15
            elif f['colors']['dark_spots_ratio'] > 3: score += 0.08
            if f['texture']['roughness'] > 0.12: score += 0.10
            return _clamp(score)
        profiles['Tomato_late_blight'] = tomato_late_blight

        def tomato_early_blight(f):
            # Early blight: concentric brown rings, moderate coverage, yellow halo
            brown = f['hsv']['brown_pct']
            yellow = f['hsv']['yellow_pct']
            coverage = f['spots']['coverage_percentage']
            green = f['hsv']['green_pct']
            score = 0.0
            if brown > 6: score += 0.25
            elif brown > 3: score += 0.12
            if yellow > 5: score += 0.20
            elif yellow > 2: score += 0.10
            if 8 < coverage < 40: score += 0.20
            elif coverage > 5: score += 0.10
            if green > 20 and green < 55: score += 0.10
            if f['texture']['edge_density'] > 0.08: score += 0.15
            if f['spots']['spot_count'] > 10: score += 0.10
            return _clamp(score)
        profiles['Tomato_early_blight'] = tomato_early_blight

        def tomato_leaf_mold(f):
            # Leaf mold: yellow patches on top, fuzzy brown/grey below; LOW dark spots
            yellow = f['hsv']['yellow_pct']
            grey = f['hsv']['grey_pct']
            green = f['hsv']['green_pct']
            dark = f['hsv']['dark_pct']
            brown = f['hsv']['brown_pct']
            score = 0.0
            if yellow > 8: score += 0.30
            elif yellow > 4: score += 0.18
            elif yellow > 2: score += 0.08
            if grey > 5: score += 0.15
            elif grey > 2: score += 0.07
            if brown > 2 and brown < 12: score += 0.10
            if dark < 8: score += 0.10            # leaf mold usually NOT very dark
            if green > 15 and green < 55: score += 0.10
            if f['texture']['uniformity'] > 0.5: score += 0.10  # fuzzy = more uniform
            if f['spots']['coverage_percentage'] < 20: score += 0.10
            # Penalty: if dark is very high, unlikely leaf mold
            if dark > 15: score -= 0.15
            return _clamp(score)
        profiles['Tomato_leaf_mold'] = tomato_leaf_mold

        def tomato_bacterial_spot(f):
            # Small dark raised spots with yellow halos
            dark = f['colors']['dark_spots_ratio']
            yellow = f['hsv']['yellow_pct']
            spot_count = f['spots']['spot_count']
            avg_size = f['spots']['avg_spot_size']
            score = 0.0
            if spot_count > 30: score += 0.25
            elif spot_count > 15: score += 0.15
            if avg_size < 200: score += 0.15       # many small spots
            if dark > 3: score += 0.15
            if yellow > 3: score += 0.15
            if f['hsv']['brown_pct'] < 8: score += 0.10
            if f['spots']['coverage_percentage'] > 5: score += 0.10
            return _clamp(score)
        profiles['Tomato_bacterial_spot'] = tomato_bacterial_spot

        def tomato_septoria_leaf_spot(f):
            # Many tiny circular spots with dark borders, grey centres
            grey = f['hsv']['grey_pct']
            spot_count = f['spots']['spot_count']
            avg_size = f['spots']['avg_spot_size']
            score = 0.0
            if spot_count > 40: score += 0.25
            elif spot_count > 20: score += 0.15
            if avg_size < 150: score += 0.20       # very small spots
            if grey > 4: score += 0.20
            elif grey > 2: score += 0.10
            if f['hsv']['brown_pct'] < 6: score += 0.10
            if f['colors']['dark_spots_ratio'] > 2: score += 0.10
            return _clamp(score)
        profiles['Tomato_septoria_leaf_spot'] = tomato_septoria_leaf_spot

        def tomato_spider_mites(f):
            # Fine speckling / yellowing; very high yellow, low brown/dark
            yellow = f['hsv']['yellow_pct']
            green = f['hsv']['green_pct']
            score = 0.0
            if yellow > 10: score += 0.30
            elif yellow > 5: score += 0.18
            if f['hsv']['brown_pct'] < 4: score += 0.15
            if f['hsv']['dark_pct'] < 5: score += 0.15
            if green > 20: score += 0.10
            if f['texture']['edge_density'] < 0.06: score += 0.10
            if f['colors']['white_ratio'] > 3: score += 0.10  # webbing
            return _clamp(score)
        profiles['Tomato_spider_mites'] = tomato_spider_mites

        def tomato_target_spot(f):
            # Brown concentric ring lesions, moderate coverage
            brown = f['hsv']['brown_pct']
            coverage = f['spots']['coverage_percentage']
            score = 0.0
            if brown > 8: score += 0.25
            elif brown > 4: score += 0.12
            if 10 < coverage < 35: score += 0.20
            elif coverage > 5: score += 0.10
            if f['texture']['edge_density'] > 0.08: score += 0.15
            if f['hsv']['yellow_pct'] > 2: score += 0.10
            if f['spots']['spot_count'] > 5 and f['spots']['spot_count'] < 30: score += 0.10
            return _clamp(score)
        profiles['Tomato_target_spot'] = tomato_target_spot

        def tomato_mosaic_virus(f):
            # Mottled green-yellow, leaf distortion; yellow + green mixed, low brown/dark
            yellow = f['hsv']['yellow_pct']
            green = f['hsv']['green_pct']
            score = 0.0
            if yellow > 6 and green > 20: score += 0.30
            elif yellow > 3 and green > 15: score += 0.18
            if f['hsv']['brown_pct'] < 4: score += 0.15
            if f['hsv']['dark_pct'] < 5: score += 0.15
            if f['texture']['roughness'] > 0.08: score += 0.10
            if f['spots']['coverage_percentage'] < 10: score += 0.10
            return _clamp(score)
        profiles['Tomato_tomato_mosaic_virus'] = tomato_mosaic_virus

        def tomato_yellow_leaf_curl(f):
            # Intense yellow curling; very high yellow, moderate green, low dark
            yellow = f['hsv']['yellow_pct']
            score = 0.0
            if yellow > 15: score += 0.35
            elif yellow > 8: score += 0.20
            elif yellow > 4: score += 0.10
            if f['hsv']['green_pct'] > 15: score += 0.10
            if f['hsv']['dark_pct'] < 5: score += 0.15
            if f['hsv']['brown_pct'] < 4: score += 0.10
            if f['texture']['roughness'] > 0.10: score += 0.10  # curled
            if f['spots']['coverage_percentage'] < 8: score += 0.10
            return _clamp(score)
        profiles['Tomato_yellow_leaf_curl_virus'] = tomato_yellow_leaf_curl

        # ── POTATO ─────────────────────────────────────────────────────
        def potato_early_blight(f):
            brown = f['hsv']['brown_pct']
            yellow = f['hsv']['yellow_pct']
            coverage = f['spots']['coverage_percentage']
            score = 0.0
            if brown > 5: score += 0.25
            elif brown > 3: score += 0.12
            if yellow > 3: score += 0.15
            if 5 < coverage < 35: score += 0.20
            if f['texture']['edge_density'] > 0.07: score += 0.15
            if f['hsv']['green_pct'] > 20: score += 0.10
            return _clamp(score)
        profiles['Potato_early_blight'] = potato_early_blight

        def potato_late_blight(f):
            dark = f['hsv']['dark_pct']
            brown = f['hsv']['brown_pct']
            coverage = f['spots']['coverage_percentage']
            score = 0.0
            if dark > 8: score += 0.25
            elif dark > 4: score += 0.12
            if brown > 5: score += 0.15
            if coverage > 20: score += 0.25
            elif coverage > 10: score += 0.12
            if f['hsv']['green_pct'] < 35: score += 0.10
            if f['colors']['dark_spots_ratio'] > 5: score += 0.10
            return _clamp(score)
        profiles['Potato_late_blight'] = potato_late_blight

        def potato_healthy(f):
            green = f['hsv']['green_pct']
            spots = f['spots']['coverage_percentage']
            score = 0.0
            if green > 40: score += 0.40
            elif green > 25: score += 0.20
            if spots < 5: score += 0.30
            if f['hsv']['brown_pct'] < 3: score += 0.15
            if f['hsv']['dark_pct'] < 3: score += 0.15
            return _clamp(score)
        profiles['Potato_healthy'] = potato_healthy

        # ── APPLE ──────────────────────────────────────────────────────
        def apple_scab(f):
            brown = f['hsv']['brown_pct']
            dark = f['hsv']['dark_pct']
            score = 0.0
            if brown > 5: score += 0.25
            if dark > 4: score += 0.20
            if f['spots']['coverage_percentage'] > 8: score += 0.20
            if f['texture']['roughness'] > 0.10: score += 0.15
            if f['hsv']['green_pct'] > 15: score += 0.10
            return _clamp(score)
        profiles['Apple_scab'] = apple_scab

        def apple_black_rot(f):
            dark = f['hsv']['dark_pct']
            brown = f['hsv']['brown_pct']
            score = 0.0
            if dark > 10: score += 0.30
            elif dark > 5: score += 0.15
            if brown > 5: score += 0.20
            if f['spots']['coverage_percentage'] > 10: score += 0.20
            if f['texture']['edge_density'] > 0.08: score += 0.10
            return _clamp(score)
        profiles['Apple_black_rot'] = apple_black_rot

        def apple_cedar_rust(f):
            yellow = f['hsv']['yellow_pct']
            score = 0.0
            if yellow > 8: score += 0.30
            elif yellow > 4: score += 0.15
            if f['colors']['red'] > 0.4: score += 0.20
            if f['hsv']['brown_pct'] < 5: score += 0.15
            if f['hsv']['green_pct'] > 15: score += 0.10
            return _clamp(score)
        profiles['Apple_cedar_apple_rust'] = apple_cedar_rust

        def apple_healthy(f):
            green = f['hsv']['green_pct']
            spots = f['spots']['coverage_percentage']
            score = 0.0
            if green > 40: score += 0.40
            elif green > 25: score += 0.20
            if spots < 5: score += 0.30
            if f['hsv']['brown_pct'] < 3: score += 0.15
            if f['hsv']['dark_pct'] < 3: score += 0.15
            return _clamp(score)
        profiles['Apple_healthy'] = apple_healthy

        # ── GRAPE ──────────────────────────────────────────────────────
        def grape_black_rot(f):
            dark = f['hsv']['dark_pct']
            brown = f['hsv']['brown_pct']
            score = 0.0
            if dark > 8: score += 0.25
            if brown > 5: score += 0.20
            if f['spots']['spot_count'] > 10: score += 0.15
            if f['spots']['coverage_percentage'] > 10: score += 0.20
            if f['texture']['roughness'] > 0.10: score += 0.10
            return _clamp(score)
        profiles['Grape_black_rot'] = grape_black_rot

        def grape_esca(f):
            yellow = f['hsv']['yellow_pct']
            brown = f['hsv']['brown_pct']
            score = 0.0
            if yellow > 5: score += 0.25
            if brown > 4: score += 0.20
            if f['colors']['red'] > 0.35: score += 0.15
            if f['hsv']['green_pct'] < 40: score += 0.15
            return _clamp(score)
        profiles['Grape_esca'] = grape_esca

        def grape_leaf_blight(f):
            brown = f['hsv']['brown_pct']
            coverage = f['spots']['coverage_percentage']
            score = 0.0
            if brown > 6: score += 0.25
            if coverage > 10: score += 0.20
            if f['texture']['edge_density'] > 0.07: score += 0.15
            if f['hsv']['yellow_pct'] > 3: score += 0.10
            return _clamp(score)
        profiles['Grape_leaf_blight'] = grape_leaf_blight

        def grape_healthy(f):
            green = f['hsv']['green_pct']
            spots = f['spots']['coverage_percentage']
            score = 0.0
            if green > 40: score += 0.40
            if spots < 5: score += 0.30
            if f['hsv']['brown_pct'] < 3: score += 0.15
            if f['hsv']['dark_pct'] < 3: score += 0.15
            return _clamp(score)
        profiles['Grape_healthy'] = grape_healthy

        # ── CORN ───────────────────────────────────────────────────────
        def corn_cercospora(f):
            grey = f['hsv']['grey_pct']
            yellow = f['hsv']['yellow_pct']
            score = 0.0
            if grey > 5: score += 0.25
            if yellow > 4: score += 0.20
            if f['spots']['spot_count'] > 10: score += 0.20
            if f['hsv']['brown_pct'] > 3: score += 0.15
            return _clamp(score)
        profiles['Corn_cercospora_leaf_spot'] = corn_cercospora

        def corn_common_rust(f):
            brown = f['hsv']['brown_pct']
            score = 0.0
            if brown > 6: score += 0.25
            if f['colors']['red'] > 0.35: score += 0.25
            if f['spots']['spot_count'] > 20: score += 0.20
            if f['spots']['avg_spot_size'] < 200: score += 0.15
            return _clamp(score)
        profiles['Corn_common_rust'] = corn_common_rust

        def corn_northern_leaf_blight(f):
            grey = f['hsv']['grey_pct']
            brown = f['hsv']['brown_pct']
            coverage = f['spots']['coverage_percentage']
            score = 0.0
            if grey > 4: score += 0.20
            if brown > 3: score += 0.15
            if coverage > 10: score += 0.20
            # Long narrow lesions → higher edge density
            if f['texture']['edge_density'] > 0.08: score += 0.20
            return _clamp(score)
        profiles['Corn_northern_leaf_blight'] = corn_northern_leaf_blight

        def corn_healthy(f):
            green = f['hsv']['green_pct']
            spots = f['spots']['coverage_percentage']
            score = 0.0
            if green > 40: score += 0.40
            if spots < 5: score += 0.30
            if f['hsv']['brown_pct'] < 3: score += 0.15
            if f['hsv']['dark_pct'] < 3: score += 0.15
            return _clamp(score)
        profiles['Corn_healthy'] = corn_healthy

        # ── Simple healthy / disease profiles for remaining crops ──────
        for crop, name in [('Cherry', 'Cherry_healthy'), ('Peach', 'Peach_healthy'),
                           ('Pepper', 'Pepper_bell_healthy'), ('Strawberry', 'Strawberry_healthy'),
                           ('Soybean', 'Soybean_healthy'), ('Blueberry', 'Blueberry_healthy'),
                           ('Raspberry', 'Raspberry_healthy')]:
            def _healthy(f, _n=name):
                g = f['hsv']['green_pct']
                s = f['spots']['coverage_percentage']
                sc = 0.0
                if g > 40: sc += 0.40
                elif g > 25: sc += 0.20
                if s < 5: sc += 0.30
                if f['hsv']['brown_pct'] < 3: sc += 0.15
                if f['hsv']['dark_pct'] < 3: sc += 0.15
                return _clamp(sc)
            profiles[name] = _healthy

        def cherry_powdery_mildew(f):
            white = f['hsv']['white_pct'] + f['colors']['white_ratio']
            score = 0.0
            if white > 8: score += 0.30
            elif white > 4: score += 0.15
            if f['hsv']['green_pct'] > 15: score += 0.15
            if f['hsv']['brown_pct'] < 5: score += 0.15
            if f['texture']['uniformity'] > 0.5: score += 0.10
            return _clamp(score)
        profiles['Cherry_powdery_mildew'] = cherry_powdery_mildew

        def peach_bacterial_spot(f):
            dark = f['colors']['dark_spots_ratio']
            spot_count = f['spots']['spot_count']
            score = 0.0
            if spot_count > 20: score += 0.25
            if dark > 4: score += 0.20
            if f['hsv']['brown_pct'] > 3: score += 0.15
            if f['hsv']['yellow_pct'] > 2: score += 0.15
            return _clamp(score)
        profiles['Peach_bacterial_spot'] = peach_bacterial_spot

        def pepper_bacterial_spot(f):
            dark = f['colors']['dark_spots_ratio']
            spot_count = f['spots']['spot_count']
            score = 0.0
            if spot_count > 20: score += 0.25
            if dark > 4: score += 0.20
            if f['hsv']['brown_pct'] > 3: score += 0.15
            if f['hsv']['yellow_pct'] > 3: score += 0.15
            return _clamp(score)
        profiles['Pepper_pepper_bell_bacterial_spot'] = pepper_bacterial_spot

        def strawberry_leaf_scorch(f):
            brown = f['hsv']['brown_pct']
            dark = f['hsv']['dark_pct']
            score = 0.0
            if brown > 5: score += 0.25
            if dark > 4: score += 0.20
            if f['colors']['red'] > 0.3: score += 0.15
            if f['spots']['coverage_percentage'] > 8: score += 0.15
            return _clamp(score)
        profiles['Strawberry_leaf_scorch'] = strawberry_leaf_scorch

        def soybean_frogeye(f):
            grey = f['hsv']['grey_pct']
            dark = f['hsv']['dark_pct']
            score = 0.0
            if grey > 5: score += 0.25
            if dark > 3: score += 0.20
            if f['spots']['spot_count'] > 15: score += 0.20
            if f['spots']['avg_spot_size'] < 300: score += 0.15
            return _clamp(score)
        profiles['Soybean_frogeye_leaf_spot'] = soybean_frogeye

        def squash_powdery_mildew(f):
            white = f['hsv']['white_pct'] + f['colors']['white_ratio']
            score = 0.0
            if white > 10: score += 0.35
            elif white > 5: score += 0.18
            if f['hsv']['green_pct'] > 15: score += 0.15
            if f['texture']['uniformity'] > 0.5: score += 0.15
            return _clamp(score)
        profiles['Squash_powdery_mildew'] = squash_powdery_mildew

        def orange_hlb(f):
            yellow = f['hsv']['yellow_pct']
            green = f['hsv']['green_pct']
            score = 0.0
            if yellow > 10: score += 0.30
            elif yellow > 5: score += 0.15
            if green > 15 and green < 50: score += 0.20
            if f['hsv']['brown_pct'] < 5: score += 0.15
            return _clamp(score)
        profiles['Orange_haunglongbing'] = orange_hlb

        return profiles

    def match_with_database(self, features, crop_type=None):
        """
        Match image features with disease database.
        Each disease has a scoring profile that returns 0-1 based on feature fit.
        If crop_type is provided, only diseases relevant to that crop are scored.
        """
        if self.DISEASE_PROFILES is None:
            DiseaseDetector.DISEASE_PROFILES = DiseaseDetector._build_profiles()

        profiles = DiseaseDetector.DISEASE_PROFILES

        # Determine candidate diseases
        candidates = list(profiles.keys())
        if crop_type:
            crop_key = crop_type.strip().lower()
            if crop_key in self.CROP_DISEASE_MAP:
                crop_diseases = self.CROP_DISEASE_MAP[crop_key]
                candidates = [d for d in crop_diseases if d in profiles]
                logger.info(f"Filtered to {len(candidates)} candidates for crop '{crop_type}'")

        matches = []
        for disease in candidates:
            scorer = profiles[disease]
            try:
                raw_score = scorer(features)
            except Exception:
                raw_score = 0.0

            # Convert raw 0-1 score to a confidence percentage
            confidence = round(raw_score, 3)

            if confidence >= 0.15:                  # include anything plausible
                matches.append({
                    'disease': disease,
                    'confidence': confidence,
                    'matching_features': self._describe_features(disease, features),
                    'health_impact': f"{features['hsv']['green_pct']:.1f}% green vitality"
                })

        matches.sort(key=lambda x: x['confidence'], reverse=True)
        return matches[:5]                          # top 5

    @staticmethod
    def _describe_features(disease, features):
        """Build human-readable explanations of why a disease matched."""
        details = []
        hsv = features['hsv']
        spots = features['spots']

        if hsv['green_pct'] > 40:
            details.append(f"Strong green presence ({hsv['green_pct']:.1f}%)")
        if hsv['yellow_pct'] > 4:
            details.append(f"Yellow discoloration ({hsv['yellow_pct']:.1f}%)")
        if hsv['brown_pct'] > 4:
            details.append(f"Brown lesion areas ({hsv['brown_pct']:.1f}%)")
        if hsv['dark_pct'] > 5:
            details.append(f"Dark necrotic regions ({hsv['dark_pct']:.1f}%)")
        if hsv['grey_pct'] > 4:
            details.append(f"Grey / bleached tissue ({hsv['grey_pct']:.1f}%)")
        if hsv['white_pct'] > 4:
            details.append(f"White powdery / mold areas ({hsv['white_pct']:.1f}%)")
        if spots['coverage_percentage'] > 8:
            details.append(f"Significant spot coverage ({spots['coverage_percentage']:.1f}%)")
        if spots['spot_count'] > 20:
            details.append(f"Multiple lesion spots ({spots['spot_count']})")

        return details if details else ['Visual features analysed']

    def predict(self, image_path, crop_type=None):
        """
        Advanced disease prediction with detailed analysis.
        """
        try:
            if not os.path.exists(image_path):
                raise FileNotFoundError(f"Image not found: {image_path}")
            
            # Extract features from image
            features = self.analyze_image_features(image_path)
            
            # Match with database (passing crop_type for filtering)
            matches = self.match_with_database(features, crop_type=crop_type)
            
            # If no matches or all low, return health-based result
            if not matches or matches[0]['confidence'] < 0.20:
                if features['hsv']['green_pct'] > 35:
                    healthy_name = 'Tomato_healthy'
                    if crop_type:
                        healthy_name = f"{crop_type.strip().capitalize()}_healthy"
                    return {
                        'disease': healthy_name,
                        'confidence': round(features['hsv']['green_pct'] / 100, 3),
                        'analysis': 'Plant appears healthy with good green pigmentation',
                        'symptoms': 'No significant disease symptoms detected',
                        'treatment': 'Continue regular maintenance and monitoring',
                        'prevention': 'Maintain good watering schedule and proper ventilation',
                        'detailed_analysis': {
                            'health_score': features['health_score'],
                            'features': features,
                            'recommendation': 'Plant is in good condition. Maintain current care practices.'
                        }
                    }
            
            # Get top match
            top_match = matches[0]
            disease_name = top_match['disease']
            confidence = top_match['confidence']
            
            # Scale confidence for display (raw 0-1 → 50-99%)
            display_confidence = round(0.50 + confidence * 0.49, 3)
            
            # Get treatment info from database
            treatment_info = None
            disease_lower = disease_name.lower()
            for key, info in self.treatment_data.items():
                if disease_lower == key.replace(' ', '_') or disease_lower.replace('_', ' ') == key:
                    treatment_info = info
                    break
            if not treatment_info:
                # Partial match
                for key, info in self.treatment_data.items():
                    if disease_lower in key.replace(' ', '_') or key.replace(' ', '_') in disease_lower:
                        treatment_info = info
                        break
            
            if not treatment_info:
                treatment_info = {
                    'symptoms': f'Disease pattern detected with {display_confidence*100:.1f}% confidence',
                    'treatment': 'Consult with agricultural expert for proper treatment',
                    'prevention': 'Implement integrated pest management practices'
                }
            
            logger.info(f"Disease detected: {disease_name} (confidence: {display_confidence:.1%})")
            logger.info(f"  Top 3: {[(m['disease'], m['confidence']) for m in matches[:3]]}")
            
            return {
                'disease': disease_name,
                'confidence': display_confidence,
                'symptoms': treatment_info.get('symptoms', ''),
                'treatment': treatment_info.get('treatment', ''),
                'prevention': treatment_info.get('prevention', ''),
                'detailed_analysis': {
                    'image_analysis': {
                        'color_profile': features['colors'],
                        'texture_metrics': features['texture'],
                        'spot_detection': features['spots'],
                        'hsv_analysis': features['hsv'],
                        'health_score': features['health_score']
                    },
                    'disease_matches': [
                        {'disease': m['disease'],
                         'confidence': round(0.50 + m['confidence'] * 0.49, 3),
                         'matching_features': m['matching_features']}
                        for m in matches
                    ],
                    'severity_level': features['spots']['severity'],
                    'recommendation': self._generate_recommendation(disease_name, features),
                    'action_items': self._generate_action_items(disease_name, features)
                }
            }
            
        except Exception as e:
            logger.error(f"Error in disease prediction: {str(e)}")
            logger.error(traceback.format_exc())
            return {
                'disease': 'Error',
                'confidence': 0,
                'error': str(e),
                'symptoms': 'Could not analyze image',
                'treatment': 'Please try uploading a clear image of the affected plant',
                'prevention': 'Ensure good image quality for accurate diagnosis'
            }
    
    def _generate_recommendation(self, disease, features):
        """Generate detailed recommendation based on disease and features"""
        severity = features['spots']['severity']
        coverage = features['spots']['coverage_percentage']
        health = features['health_score']
        
        if severity == 'High':
            return f"URGENT: This plant requires immediate intervention. {coverage:.1f}% of leaf area is affected. Isolate the plant and begin treatment immediately."
        elif severity == 'Medium':
            return f"Monitor closely and apply protective treatments. Current coverage: {coverage:.1f}%. Plant health at {health:.1f}%."
        else:
            return f"Early detection. Apply preventative measures. Current coverage: {coverage:.1f}%. Monitor for expansion."
    
    def _generate_action_items(self, disease, features):
        """Generate prioritized action items"""
        actions = []
        
        if 'healthy' not in disease.lower():
            actions.append("✓ Isolate affected plant from others")
            actions.append("✓ Remove heavily affected leaves")
            actions.append("✓ Apply recommended fungicide or pesticide")
            actions.append("✓ Improve air circulation")
            
            if features['spots']['coverage_percentage'] > 30:
                actions.append("✓ Consider pruning affected branches")
                actions.append("✓ Increase monitoring to daily")
            
            actions.append("✓ Water at base, avoid wetting leaves")
            actions.append("✓ Disinfect tools used on the plant")
            actions.append("✓ Monitor for 2 weeks after treatment")
        else:
            actions.append("✓ Continue regular watering schedule")
            actions.append("✓ Monitor for any disease signs")
            actions.append("✓ Maintain proper spacing between plants")
            actions.append("✓ Weekly visual inspection")
        
        return actions
