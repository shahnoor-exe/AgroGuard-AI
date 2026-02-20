import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Advanced API Service with retry logic, error handling, and timeouts
class ApiService {
  static const String baseUrl = 'http://localhost:5000';
  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  final Logger _logger = Logger();
  final http.Client _client = http.Client();

  /// Predict disease from image with retry and error handling
  Future<Map<String, dynamic>> predictDisease(
    List<int> imageBytes,
    String fileName, {
    void Function(double)? onProgress,
  }) async {
    int attempts = 0;
    late Exception lastException;

    while (attempts < maxRetries) {
      try {
        attempts++;
        _logger.i('Prediction attempt $attempts/$maxRetries');

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/predict'),
        );

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: fileName,
          ),
        );

        final streamedResponse = await request.send().timeout(timeout);
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _logger.i('Prediction successful: ${data['disease']}');
          return data;
        } else if (response.statusCode == 400) {
          throw ApiException('Invalid image format', 400);
        } else if (response.statusCode == 500) {
          throw ApiException('Server error', 500);
        }
      } on TimeoutException catch (e) {
        lastException = ApiException('Request timeout', -1);
        _logger.e('Timeout on attempt $attempts: $e');
        if (attempts < maxRetries) await Future.delayed(Duration(seconds: 2 * attempts));
      } catch (e, stackTrace) {
        lastException = e is Exception ? e : Exception(e.toString());
        _logger.e('Error on attempt $attempts', error: e, stackTrace: stackTrace);
        if (attempts < maxRetries) await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }

    throw lastException ?? ApiException('Failed to predict after $maxRetries attempts', -1);
  }

  /// Get sensor data with error handling
  Future<Map<String, dynamic>> getSensorData() async {
    try {
      _logger.i('Fetching sensor data...');
      
      final response = await _client
          .get(Uri.parse('$baseUrl/sensor'))
          .timeout(timeout)
          .onError((error, stackTrace) {
        _logger.e('Sensor fetch error', error: error, stackTrace: stackTrace);
        throw ApiException('Failed to connect to sensor endpoint', -1);
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('Sensor data received: $data');
        return data;
      } else {
        throw ApiException('Sensor endpoint error: ${response.statusCode}', response.statusCode);
      }
    } on TimeoutException {
      throw ApiException('Sensor request timeout', -1);
    }
  }

  /// Get weather data
  Future<Map<String, dynamic>> getWeatherData(double latitude, double longitude) async {
    try {
      _logger.i('Fetching weather for $latitude, $longitude');
      
      final response = await _client
          .get(Uri.parse(
            'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code&timezone=auto',
          ))
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Weather API error', response.statusCode);
      }
    } catch (e) {
      _logger.e('Weather fetch failed', error: e);
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom API Exception
class ApiException implements Exception {

  ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  bool get isNetworkError => statusCode == -1;
  bool get isServerError => statusCode >= 500;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isTimeout => message.contains('timeout');
}
