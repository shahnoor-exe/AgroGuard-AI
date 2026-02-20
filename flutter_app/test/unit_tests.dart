import 'package:agroguard_ai/core/providers/app_providers.dart';
import 'package:agroguard_ai/core/services/api_service.dart';
import 'package:agroguard_ai/core/services/localization_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdvancedPrediction Tests', () {
    test('Calculate severity correctly', () {
      expect(AdvancedPrediction.calculateSeverity(0.95), 'CRITICAL');
      expect(AdvancedPrediction.calculateSeverity(0.85), 'HIGH');
      expect(AdvancedPrediction.calculateSeverity(0.70), 'MEDIUM');
      expect(AdvancedPrediction.calculateSeverity(0.50), 'LOW');
    });

    test('Convert prediction to JSON', () {
      final prediction = AdvancedPrediction(
        primaryDisease: 'Early Blight',
        primaryConfidence: 0.92,
        alternativeDiseases: [
          DiseasePrediction(disease: 'Late Blight', confidence: 0.05),
        ],
        recommendations: ['Apply fungicide', 'Improve air circulation'],
        severity: 'HIGH',
        timestamp: DateTime.now(),
        cropType: 'Tomato',
      );

      final json = prediction.toJson();
      expect(json['primary_disease'], 'Early Blight');
      expect(json['confidence'], 0.92);
      expect(json['severity'], 'HIGH');
      expect(json['crop'], 'Tomato');
      expect(json['recommendations'].length, 2);
    });
  });

  group('PredictionProvider Tests', () {
    test('Add prediction updates state', () {
      final provider = PredictionProvider();
      final prediction = AdvancedPrediction(
        primaryDisease: 'Early Blight',
        primaryConfidence: 0.92,
        alternativeDiseases: [],
        recommendations: ['Test'],
        severity: 'HIGH',
        timestamp: DateTime.now(),
        cropType: 'Tomato',
      );

      provider.addPrediction(prediction);

      expect(provider.predictions.length, 1);
      expect(provider.currentPrediction, prediction);
      expect(provider.error, null);
    });

    test('Get predictions by crop', () {
      final provider = PredictionProvider();
      final tomatoPrediction = AdvancedPrediction(
        primaryDisease: 'Early Blight',
        primaryConfidence: 0.92,
        alternativeDiseases: [],
        recommendations: [],
        severity: 'HIGH',
        timestamp: DateTime.now(),
        cropType: 'Tomato',
      );

      final potatoPrediction = AdvancedPrediction(
        primaryDisease: 'Late Blight',
        primaryConfidence: 0.85,
        alternativeDiseases: [],
        recommendations: [],
        severity: 'HIGH',
        timestamp: DateTime.now(),
        cropType: 'Potato',
      );

      provider.addPrediction(tomatoPrediction);
      provider.addPrediction(potatoPrediction);

      final tomatoResults = provider.getPredictionsByCrop('Tomato');
      expect(tomatoResults.length, 1);
      expect(tomatoResults.first.cropType, 'Tomato');
    });

    test('Get critical predictions', () {
      final provider = PredictionProvider();
      final criticalPrediction = AdvancedPrediction(
        primaryDisease: 'Critical Disease',
        primaryConfidence: 0.95,
        alternativeDiseases: [],
        recommendations: [],
        severity: 'CRITICAL',
        timestamp: DateTime.now(),
        cropType: 'Tomato',
      );

      final lowPrediction = AdvancedPrediction(
        primaryDisease: 'Low Risk',
        primaryConfidence: 0.55,
        alternativeDiseases: [],
        recommendations: [],
        severity: 'LOW',
        timestamp: DateTime.now(),
        cropType: 'Tomato',
      );

      provider.addPrediction(criticalPrediction);
      provider.addPrediction(lowPrediction);

      final critical = provider.getCriticalPredictions();
      expect(critical.length, 1);
      expect(critical.first.severity, 'CRITICAL');
    });

    test('Clear predictions', () {
      final provider = PredictionProvider();
      final prediction = AdvancedPrediction(
        primaryDisease: 'Test',
        primaryConfidence: 0.8,
        alternativeDiseases: [],
        recommendations: [],
        severity: 'MEDIUM',
        timestamp: DateTime.now(),
        cropType: 'Tomato',
      );

      provider.addPrediction(prediction);
      expect(provider.predictions.length, 1);

      provider.clearPredictions();
      expect(provider.predictions.length, 0);
      expect(provider.currentPrediction, null);
    });
  });

  group('SensorProvider Tests', () {
    test('Set sensor data updates state', () {
      final provider = SensorProvider();
      final sensorData = {
        'soil_moisture': 45.5,
        'temperature': 28.3,
        'humidity': 72.1,
      };

      provider.setSensorData(sensorData);

      expect(provider.getSoilMoisture(), 45.5);
      expect(provider.getTemperature(), 28.3);
      expect(provider.getHumidity(), 72.1);
      expect(provider.lastUpdate, isNotNull);
    });

    test('Sensor history tracks updates', () {
      final provider = SensorProvider();
      
      for (int i = 0; i < 5; i++) {
        provider.setSensorData({
          'soil_moisture': 40.0 + i,
          'temperature': 25.0 + i,
          'humidity': 70.0 + i,
        });
      }

      expect(provider.history.length, 5);
      expect(provider.history.first['soil_moisture'], 44.0); // Last added
    });
  });

  group('SettingsProvider Tests', () {
    test('Toggle dark mode', () {
      final provider = SettingsProvider();
      
      expect(provider.darkMode, false);
      provider.setDarkMode(true);
      expect(provider.darkMode, true);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('Change language', () {
      final provider = SettingsProvider();
      
      expect(provider.language, 'en');
      provider.setLanguage('es');
      expect(provider.language, 'es');
    });

    test('Toggle notifications', () {
      final provider = SettingsProvider();
      
      expect(provider.notificationsEnabled, true);
      provider.setNotifications(false);
      expect(provider.notificationsEnabled, false);
    });
  });

  group('LocalizationService Tests', () {
    test('Translate English', () {
      final translated = LocalizationService.translate('app_title', 'en');
      expect(translated, 'AgroGuard AI');
    });

    test('Translate Spanish', () {
      final translated = LocalizationService.translate('app_title', 'es');
      expect(translated, 'AgroGuard AI');
    });

    test('Translate Hindi', () {
      final translated = LocalizationService.translate('app_title', 'hi');
      expect(translated, 'AgroGuard AI');
    });

    test('Get supported languages', () {
      final langs = LocalizationService.getSupportedLanguages();
      expect(langs, contains('en'));
      expect(langs, contains('es'));
      expect(langs, contains('hi'));
    });

    test('Fallback to English for missing translation', () {
      final translated = LocalizationService.translate('nonexistent_key', 'es');
      expect(translated, 'nonexistent_key'); // Returns key if not found
    });
  });

  group('ApiException Tests', () {
    test('Network error detection', () {
      final exception = ApiException('Connection failed', -1);
      expect(exception.isNetworkError, true);
      expect(exception.isServerError, false);
      expect(exception.isClientError, false);
    });

    test('Server error detection', () {
      final exception = ApiException('Server error', 500);
      expect(exception.isServerError, true);
      expect(exception.isNetworkError, false);
    });

    test('Client error detection', () {
      final exception = ApiException('Bad request', 400);
      expect(exception.isClientError, true);
    });

    test('Timeout detection', () {
      final exception = ApiException('Request timeout', -1);
      expect(exception.isTimeout, true);
    });
  });
}
