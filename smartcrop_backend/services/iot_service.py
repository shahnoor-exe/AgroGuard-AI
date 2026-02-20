"""
IoT Sensor Simulator Service
Generates realistic IoT sensor data with comprehensive analytics and demo scenarios
"""

import random
import logging
from datetime import datetime, timedelta
from collections import deque
import math

logger = logging.getLogger(__name__)


class IOTSimulator:
    """Simulates IoT sensor data with advanced analytics and scenario management"""
    
    # Demo scenarios with realistic parameters
    SCENARIOS = {
        'healthy_crop': {
            'name': 'Healthy Wheat Crop',
            'crop': 'Wheat',
            'stage': 'Vegetative Growth',
            'nitrogen': (120, 150),
            'phosphorus': (50, 70),
            'potassium': (80, 120),
            'temperature': (20, 25),
            'humidity': (60, 75),
            'ph': (6.5, 7.2),
            'rainfall': (5, 15),
            'soil_moisture': (55, 70),
            'light_intensity': (800, 1000),
        },
        'drought_stress': {
            'name': 'Drought Stressed Corn',
            'crop': 'Corn',
            'stage': 'Flowering',
            'nitrogen': (60, 80),
            'phosphorus': (30, 45),
            'potassium': (40, 60),
            'temperature': (32, 38),
            'humidity': (25, 40),
            'ph': (6.0, 6.8),
            'rainfall': (0, 2),
            'soil_moisture': (15, 25),
            'light_intensity': (1000, 1200),
        },
        'nutrient_deficiency': {
            'name': 'Nitrogen Deficient Rice',
            'crop': 'Rice',
            'stage': 'Heading',
            'nitrogen': (20, 40),
            'phosphorus': (42, 55),
            'potassium': (70, 90),
            'temperature': (25, 28),
            'humidity': (70, 85),
            'ph': (6.2, 6.8),
            'rainfall': (20, 40),
            'soil_moisture': (60, 75),
            'light_intensity': (700, 850),
        },
        'disease_risk': {
            'name': 'High Disease Risk Potato',
            'crop': 'Potato',
            'stage': 'Tuber Formation',
            'nitrogen': (100, 130),
            'phosphorus': (55, 75),
            'potassium': (100, 140),
            'temperature': (15, 18),
            'humidity': (82, 95),
            'ph': (6.8, 7.2),
            'rainfall': (40, 60),
            'soil_moisture': (72, 85),
            'light_intensity': (500, 650),
        },
        'salt_accumulation': {
            'name': 'Salt Affected Cotton',
            'crop': 'Cotton',
            'stage': 'Boll Development',
            'nitrogen': (80, 100),
            'phosphorus': (35, 50),
            'potassium': (90, 110),
            'temperature': (28, 32),
            'humidity': (50, 65),
            'ph': (7.5, 8.2),
            'rainfall': (0, 5),
            'soil_moisture': (40, 55),
            'light_intensity': (950, 1100),
        },
    }
    
    def __init__(self, scenario='healthy_crop'):
        """Initialize IoT simulator with selected scenario"""
        self.scenario = scenario if scenario in self.SCENARIOS else 'healthy_crop'
        self.history = deque(maxlen=100)  # Keep last 100 readings
        self.hourly_history = deque(maxlen=24)  # Keep last 24 hours
        self.daily_history = deque(maxlen=30)  # Keep last 30 days
        self.current_data = self._generate_sensor_data()
        logger.info(f"IoT Simulator initialized with scenario: {self.scenario}")
    
    def set_scenario(self, scenario_name):
        """Switch to different demo scenario"""
        if scenario_name in self.SCENARIOS:
            self.scenario = scenario_name
            self.current_data = self._generate_sensor_data()
            logger.info(f"Scenario switched to: {scenario_name}")
            return True
        return False
    
    def get_scenarios(self):
        """Get list of available scenarios"""
        return {
            name: {
                'display_name': info['name'],
                'crop': info['crop'],
                'stage': info['stage']
            }
            for name, info in self.SCENARIOS.items()
        }
    
    def _generate_sensor_data(self):
        """Generate realistic sensor data based on current scenario"""
        scenario_params = self.SCENARIOS[self.scenario]
        
        def get_value(param):
            min_val, max_val = scenario_params[param]
            # Add realistic variation
            base = random.uniform(min_val, max_val)
            # Add time-based patterns (sine wave for daily cycle)
            hour = datetime.now().hour
            daily_variation = 0.05 * math.sin(hour * math.pi / 12)
            return base * (1 + daily_variation)
        
        return {
            'scenario': self.scenario,
            'crop': scenario_params['crop'],
            'stage': scenario_params['stage'],
            'nitrogen': round(get_value('nitrogen'), 2),
            'phosphorus': round(get_value('phosphorus'), 2),
            'potassium': round(get_value('potassium'), 2),
            'temperature': round(get_value('temperature'), 2),
            'humidity': round(get_value('humidity'), 2),
            'ph': round(get_value('ph'), 2),
            'rainfall': round(get_value('rainfall'), 2),
            'soil_moisture': round(get_value('soil_moisture'), 2),
            'light_intensity': round(get_value('light_intensity'), 0),
            'timestamp': datetime.now().isoformat()
        }
    
    def get_current_data(self):
        """Get current sensor readings with analytics"""
        try:
            self.current_data = self._generate_sensor_data()
            self.history.append(self.current_data.copy())
            
            # Add hourly and daily summaries
            if len(self.hourly_history) < 24:
                self.hourly_history.append(self.current_data.copy())
            
            if len(self.daily_history) < 30:
                self.daily_history.append(self.current_data.copy())
            
            logger.info("Sensor data updated")
            return self.current_data
            
        except Exception as e:
            logger.error(f"Error generating sensor data: {str(e)}")
            raise
    
    def get_analytics(self):
        """Get comprehensive analytics and insights"""
        try:
            # Ensure history is populated
            if not self.history:
                self.get_current_data()
            
            # Calculate statistics
            metrics = {
                'nitrogen': [],
                'phosphorus': [],
                'potassium': [],
                'temperature': [],
                'humidity': [],
                'ph': [],
                'rainfall': [],
                'soil_moisture': [],
                'light_intensity': [],
            }
            
            for entry in self.history:
                for key in metrics.keys():
                    metrics[key].append(entry[key])
            
            analytics = {
                'crop': self.current_data.get('crop'),
                'stage': self.current_data.get('stage'),
                'scenario': self.scenario,
                'health_score': self._calculate_health_score(),
                'trend': self._calculate_trend(),
                'metrics_summary': {},
                'alerts': self.get_alerts(),
                'recommendations': self._generate_recommendations(),
            }
            
            # Calculate statistics for each metric
            for metric, values in metrics.items():
                if values:
                    analytics['metrics_summary'][metric] = {
                        'current': values[-1],
                        'average': round(sum(values) / len(values), 2),
                        'min': round(min(values), 2),
                        'max': round(max(values), 2),
                        'trend': self._metric_trend(metric, values),
                    }
            
            logger.info("Analytics calculated successfully")
            return analytics
            
        except Exception as e:
            logger.error(f"Error calculating analytics: {str(e)}")
            raise
    
    def _calculate_health_score(self):
        """Calculate overall crop health score (0-100)"""
        try:
            if not self.history:
                return 50
            
            current = self.history[-1]
            score = 100
            
            # Nitrogen check (ideal: 100-150)
            n = current['nitrogen']
            if n < 50:
                score -= 20
            elif n < 80:
                score -= 10
            elif n > 200:
                score -= 5
            
            # Moisture check (ideal: 55-70)
            m = current['soil_moisture']
            if m < 30:
                score -= 15
            elif m < 50:
                score -= 8
            elif m > 85:
                score -= 10
            
            # Temperature check (ideal: 20-28)
            t = current['temperature']
            if t < 15 or t > 35:
                score -= 10
            elif t < 18 or t > 30:
                score -= 5
            
            # Humidity check (ideal: 60-75)
            h = current['humidity']
            if h > 90:  # Disease risk
                score -= 10
            elif h < 40:  # Stress
                score -= 8
            
            # pH check (ideal: 6.5-7.2)
            p = current['ph']
            if p < 5.5 or p > 8.0:
                score -= 15
            elif p < 6.0 or p > 7.5:
                score -= 8
            
            return max(0, min(100, score))
            
        except Exception as e:
            logger.error(f"Error calculating health score: {str(e)}")
            return 50
    
    def _calculate_trend(self):
        """Calculate overall trend: 'improving', 'stable', or 'declining'"""
        try:
            if len(self.history) < 5:
                return 'stable'
            
            recent = [self.history[-1], self.history[-2], self.history[-3]]
            older = [self.history[-5], self.history[-6]]
            
            recent_health = sum(self._calculate_health_score_for_entry(e) for e in recent) / 3
            older_health = sum(self._calculate_health_score_for_entry(e) for e in older) / 2
            
            diff = recent_health - older_health
            if diff > 5:
                return 'improving'
            elif diff < -5:
                return 'declining'
            else:
                return 'stable'
            
        except Exception as e:
            logger.error(f"Error calculating trend: {str(e)}")
            return 'stable'
    
    def _calculate_health_score_for_entry(self, entry):
        """Helper to calculate health score for a specific entry"""
        score = 100
        
        n = entry.get('nitrogen', 100)
        if n < 50: score -= 20
        elif n < 80: score -= 10
        elif n > 200: score -= 5
        
        m = entry.get('soil_moisture', 60)
        if m < 30: score -= 15
        elif m < 50: score -= 8
        elif m > 85: score -= 10
        
        t = entry.get('temperature', 25)
        if t < 15 or t > 35: score -= 10
        elif t < 18 or t > 30: score -= 5
        
        h = entry.get('humidity', 70)
        if h > 90: score -= 10
        elif h < 40: score -= 8
        
        p = entry.get('ph', 6.8)
        if p < 5.5 or p > 8.0: score -= 15
        elif p < 6.0 or p > 7.5: score -= 8
        
        return max(0, min(100, score))
    
    def _metric_trend(self, metric, values):
        """Calculate trend for a specific metric"""
        if len(values) < 3:
            return 'stable'
        
        recent_avg = sum(values[-3:]) / 3
        older_avg = sum(values[-6:-3]) / 3 if len(values) >= 6 else recent_avg
        
        diff = recent_avg - older_avg
        threshold = max(abs(recent_avg), abs(older_avg)) * 0.02
        
        if abs(diff) < threshold:
            return 'stable'
        return 'increasing' if diff > 0 else 'decreasing'
    
    def _generate_recommendations(self):
        """Generate actionable recommendations based on current conditions"""
        try:
            recommendations = []
            current = self.history[-1] if self.history else {}
            
            # Nitrogen recommendation
            n = current.get('nitrogen', 100)
            if n < 50:
                recommendations.append({
                    'type': 'nutrient',
                    'severity': 'critical',
                    'message': f'Critical nitrogen deficiency ({n} mg/kg). Apply nitrogen fertilizer immediately.',
                    'action': 'Increase nitrogen fertilizer application',
                    'icon': '🧬'
                })
            elif n < 80:
                recommendations.append({
                    'type': 'nutrient',
                    'severity': 'warning',
                    'message': f'Low nitrogen levels ({n} mg/kg). Consider nitrogen supplementation.',
                    'action': 'Plan nitrogen fertilizer application',
                    'icon': '🧬'
                })
            
            # Moisture recommendation
            m = current.get('soil_moisture', 60)
            if m < 30:
                recommendations.append({
                    'type': 'irrigation',
                    'severity': 'critical',
                    'message': f'Severe drought stress ({m}% moisture). Irrigate immediately.',
                    'action': 'Activate irrigation system urgently',
                    'icon': '💧'
                })
            elif m < 50:
                recommendations.append({
                    'type': 'irrigation',
                    'severity': 'warning',
                    'message': f'Soil moisture low ({m}%). Plan irrigation soon.',
                    'action': 'Schedule irrigation in next 1-2 days',
                    'icon': '💧'
                })
            elif m > 85:
                recommendations.append({
                    'type': 'irrigation',
                    'severity': 'warning',
                    'message': f'High soil moisture ({m}%). Risk of waterlogging.',
                    'action': 'Ensure proper drainage, reduce irrigation',
                    'icon': '💧'
                })
            
            # Temperature recommendation
            t = current.get('temperature', 25)
            if t < 15 or t > 35:
                recommendations.append({
                    'type': 'climate',
                    'severity': 'warning',
                    'message': f'Temperature outside optimal range ({t}°C).',
                    'action': 'Monitor temperature, consider protective measures',
                    'icon': '🌡️'
                })
            
            # Disease risk (high humidity + warm temp)
            h = current.get('humidity', 70)
            if h > 85 and t > 24:
                recommendations.append({
                    'type': 'disease',
                    'severity': 'warning',
                    'message': f'High disease risk (humidity {h}%, temp {t}°C). Monitor for fungal infections.',
                    'action': 'Increase fungicide application, improve ventilation',
                    'icon': '🦠'
                })
            
            # pH recommendation
            p = current.get('ph', 6.8)
            if p < 5.5:
                recommendations.append({
                    'type': 'soil',
                    'severity': 'critical',
                    'message': f'Soil too acidic (pH {p}). Apply lime to raise pH.',
                    'action': 'Apply agricultural lime',
                    'icon': '⚗️'
                })
            elif p > 8.0:
                recommendations.append({
                    'type': 'soil',
                    'severity': 'critical',
                    'message': f'Soil too alkaline (pH {p}). Apply sulfur to lower pH.',
                    'action': 'Apply elemental sulfur',
                    'icon': '⚗️'
                })
            
            # Light recommendation
            l = current.get('light_intensity', 800)
            if l < 300:
                recommendations.append({
                    'type': 'light',
                    'severity': 'warning',
                    'message': f'Low light intensity ({l} lux). May affect photosynthesis.',
                    'action': 'Prune shading plants or improve ventilation',
                    'icon': '☀️'
                })
            
            if not recommendations:
                recommendations.append({
                    'type': 'general',
                    'severity': 'info',
                    'message': 'All conditions optimal. Continue monitoring.',
                    'action': 'Maintain current practices',
                    'icon': '✅'
                })
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Error generating recommendations: {str(e)}")
            return []
    
    def get_history(self, limit=10):
        """Get sensor data history with metadata"""
        try:
            history_list = list(self.history)[-limit:]
            logger.info(f"Retrieves {len(history_list)} sensor readings from history")
            return history_list
            
        except Exception as e:
            logger.error(f"Error retrieving sensor history: {str(e)}")
            raise
    
    def get_hourly_summary(self):
        """Get hourly summary of last 24 hours"""
        try:
            if not self.hourly_history:
                return []
            
            summaries = []
            for entry in self.hourly_history:
                summaries.append({
                    'timestamp': entry['timestamp'],
                    'temperature': entry['temperature'],
                    'humidity': entry['humidity'],
                    'soil_moisture': entry['soil_moisture'],
                    'health_score': self._calculate_health_score_for_entry(entry),
                })
            
            return summaries
            
        except Exception as e:
            logger.error(f"Error generating hourly summary: {str(e)}")
            return []
    
    def get_daily_summary(self):
        """Get daily summary of last 30 days"""
        try:
            if not self.daily_history:
                return []
            
            summaries = []
            for entry in self.daily_history:
                summaries.append({
                    'timestamp': entry['timestamp'],
                    'temperature': entry['temperature'],
                    'humidity': entry['humidity'],
                    'soil_moisture': entry['soil_moisture'],
                    'nitrogen': entry['nitrogen'],
                    'health_score': self._calculate_health_score_for_entry(entry),
                })
            
            return summaries
            
        except Exception as e:
            logger.error(f"Error generating daily summary: {str(e)}")
            return []
    
    def get_average_data(self):
        """Get average of sensor data from history"""
        try:
            if not self.history:
                return self.get_current_data()
            
            num_readings = len(self.history)
            
            avg_data = {
                'nitrogen': round(sum(d['nitrogen'] for d in self.history) / num_readings, 2),
                'phosphorus': round(sum(d['phosphorus'] for d in self.history) / num_readings, 2),
                'potassium': round(sum(d['potassium'] for d in self.history) / num_readings, 2),
                'temperature': round(sum(d['temperature'] for d in self.history) / num_readings, 2),
                'humidity': round(sum(d['humidity'] for d in self.history) / num_readings, 2),
                'ph': round(sum(d['ph'] for d in self.history) / num_readings, 2),
                'rainfall': round(sum(d['rainfall'] for d in self.history) / num_readings, 2),
                'soil_moisture': round(sum(d['soil_moisture'] for d in self.history) / num_readings, 2),
                'light_intensity': round(sum(d['light_intensity'] for d in self.history) / num_readings, 0),
            }
            
            return avg_data
            
        except Exception as e:
            logger.error(f"Error calculating averages: {str(e)}")
            raise
    
    def get_alerts(self):
        """Get sensor alerts based on thresholds with severity levels"""
        try:
            alerts = []
            data = self.current_data
            
            # Define thresholds with optimal ranges
            thresholds = {
                'nitrogen': {'min': 50, 'optimal_min': 100, 'optimal_max': 150, 'max': 200},
                'phosphorus': {'min': 10, 'optimal_min': 45, 'optimal_max': 70, 'max': 100},
                'potassium': {'min': 20, 'optimal_min': 80, 'optimal_max': 120, 'max': 200},
                'temperature': {'min': 10, 'optimal_min': 20, 'optimal_max': 28, 'max': 35},
                'humidity': {'min': 30, 'optimal_min': 60, 'optimal_max': 80, 'max': 90},
                'ph': {'min': 5.5, 'optimal_min': 6.5, 'optimal_max': 7.2, 'max': 8.5},
                'rainfall': {'min': 0, 'optimal_min': 5, 'optimal_max': 50, 'max': 300},
                'soil_moisture': {'min': 30, 'optimal_min': 55, 'optimal_max': 70, 'max': 85}
            }
            
            for sensor, threshold in thresholds.items():
                value = data.get(sensor, 0)
                
                # Critical alerts
                if value < threshold['min'] or value > threshold['max']:
                    alerts.append({
                        'sensor': sensor,
                        'status': 'critical',
                        'value': value,
                        'optimal_range': f"{threshold['optimal_min']}-{threshold['optimal_max']}",
                        'message': f'CRITICAL: {sensor} at {value} (optimal: {threshold["optimal_min"]}-{threshold["optimal_max"]})',
                        'icon': '🔴'
                    })
                # Warning alerts
                elif value < threshold['optimal_min'] or value > threshold['optimal_max']:
                    alerts.append({
                        'sensor': sensor,
                        'status': 'warning',
                        'value': value,
                        'optimal_range': f"{threshold['optimal_min']}-{threshold['optimal_max']}",
                        'message': f'WARNING: {sensor} at {value} (optimal: {threshold["optimal_min"]}-{threshold["optimal_max"]})',
                        'icon': '🟡'
                    })
            
            logger.info(f"Generated {len(alerts)} sensor alerts")
            return alerts
            
        except Exception as e:
            logger.error(f"Error generating alerts: {str(e)}")
            raise
