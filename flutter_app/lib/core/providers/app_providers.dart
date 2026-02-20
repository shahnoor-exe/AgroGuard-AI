import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Advanced prediction model with multiple diseases
class AdvancedPrediction {

  AdvancedPrediction({
    required this.primaryDisease,
    required this.primaryConfidence,
    required this.alternativeDiseases,
    required this.recommendations,
    required this.severity,
    required this.timestamp,
    required this.cropType,
    this.additionalData = const {},
  });
  final String primaryDisease;
  final double primaryConfidence;
  final List<DiseasePrediction> alternativeDiseases;
  final List<String> recommendations;
  final String severity; // LOW, MEDIUM, HIGH, CRITICAL
  final DateTime timestamp;
  final String cropType;
  final Map<String, dynamic> additionalData;

  /// Determine severity based on confidence
  static String calculateSeverity(double confidence) {
    if (confidence >= 0.9) return 'CRITICAL';
    if (confidence >= 0.75) return 'HIGH';
    if (confidence >= 0.6) return 'MEDIUM';
    return 'LOW';
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() => {
    'primary_disease': primaryDisease,
    'confidence': primaryConfidence,
    'severity': severity,
    'crop': cropType,
    'alternatives': alternativeDiseases.map((d) => d.toJson()).toList(),
    'recommendations': recommendations,
    'timestamp': timestamp.toIso8601String(),
    'data': additionalData,
  };
}

/// Alternative disease prediction
class DiseasePrediction {

  DiseasePrediction({required this.disease, required this.confidence});
  final String disease;
  final double confidence;

  Map<String, dynamic> toJson() => {
    'disease': disease,
    'confidence': confidence,
  };
}

/// Provider for managing prediction state
class PredictionProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  
  final List<AdvancedPrediction> _predictions = [];
  bool _isLoading = false;
  String? _error;
  AdvancedPrediction? _currentPrediction;

  List<AdvancedPrediction> get predictions => _predictions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AdvancedPrediction? get currentPrediction => _currentPrediction;

  /// Add new prediction
  void addPrediction(AdvancedPrediction prediction) {
    _predictions.insert(0, prediction);
    _currentPrediction = prediction;
    _error = null;
    _logger.i('Prediction added: ${prediction.primaryDisease}');
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error
  void setError(String error) {
    _error = error;
    _isLoading = false;
    _logger.e('Error: $error');
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get predictions by crop
  List<AdvancedPrediction> getPredictionsByCrop(String crop) => _predictions.where((p) => p.cropType.toLowerCase() == crop.toLowerCase()).toList();

  /// Get critical predictions
  List<AdvancedPrediction> getCriticalPredictions() => _predictions.where((p) => p.severity == 'CRITICAL' || p.severity == 'HIGH').toList();

  /// Clear all predictions
  void clearPredictions() {
    _predictions.clear();
    _currentPrediction = null;
    notifyListeners();
  }
}

/// Provider for sensor data
class SensorProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  
  Map<String, dynamic> _sensorData = {};
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdate;
  final List<Map<String, dynamic>> _history = [];

  Map<String, dynamic> get sensorData => _sensorData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;
  List<Map<String, dynamic>> get history => _history;

  void setSensorData(Map<String, dynamic> data) {
    _sensorData = data;
    _lastUpdate = DateTime.now();
    _history.insert(0, {...data, 'timestamp': _lastUpdate});
    if (_history.length > 100) _history.removeLast();
    _error = null;
    _logger.i('Sensor data updated');
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    _isLoading = false;
    _logger.e('Sensor error: $error');
    notifyListeners();
  }

  double? getSoilMoisture() => _sensorData['soil_moisture']?.toDouble();
  double? getTemperature() => _sensorData['temperature']?.toDouble();
  double? getHumidity() => _sensorData['humidity']?.toDouble();
}

/// Provider for app theme and settings
class SettingsProvider extends ChangeNotifier {
  bool _darkMode = false;
  String _language = 'en';
  bool _notificationsEnabled = true;

  bool get darkMode => _darkMode;
  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
}
