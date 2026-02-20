import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../core/providers/app_providers.dart';

/// Service for exporting data in various formats
class DataExportService {
  static final Logger _logger = Logger();

  /// Export predictions as CSV
  static Future<String> exportAsCSV(List<AdvancedPrediction> predictions) async {
    try {
      _logger.i('Exporting ${predictions.length} predictions as CSV');

      final List<List<dynamic>> rows = [
        [
          'Date',
          'Crop',
          'Disease',
          'Confidence',
          'Severity',
          'Recommendations',
        ],
      ];

      for (final prediction in predictions) {
        rows.add([
          DateFormat('yyyy-MM-dd HH:mm').format(prediction.timestamp),
          prediction.cropType,
          prediction.primaryDisease,
          '${(prediction.primaryConfidence * 100).toStringAsFixed(1)}%',
          prediction.severity,
          prediction.recommendations.join('; '),
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'agroguard_predictions_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csv);
      _logger.i('CSV exported to: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('CSV export failed', error: e);
      rethrow;
    }
  }

  /// Export predictions as JSON
  static Future<String> exportAsJSON(List<AdvancedPrediction> predictions) async {
    try {
      _logger.i('Exporting ${predictions.length} predictions as JSON');

      final jsonData = {
        'export_date': DateTime.now().toIso8601String(),
        'total_predictions': predictions.length,
        'predictions': predictions.map((p) => p.toJson()).toList(),
      };

      final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonData);
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'agroguard_predictions_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(prettyJson);
      _logger.i('JSON exported to: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('JSON export failed', error: e);
      rethrow;
    }
  }

  /// Generate PDF report (requires pdf package setup)
  static Future<String> exportAsPDF(List<AdvancedPrediction> predictions) async {
    try {
      _logger.i('Generating PDF report for ${predictions.length} predictions');

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'agroguard_report_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.txt';
      final file = File('${directory.path}/$fileName');

      final StringBuffer buffer = StringBuffer();
      buffer.writeln('═' * 80);
      buffer.writeln('AgroGuard AI - Disease Detection Report');
      buffer.writeln('═' * 80);
      buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
      buffer.writeln('Total Predictions: ${predictions.length}');
      buffer.writeln('');

      for (int i = 0; i < predictions.length; i++) {
        final p = predictions[i];
        buffer.writeln('─' * 80);
        buffer.writeln('Prediction #${i + 1}');
        buffer.writeln('─' * 80);
        buffer.writeln('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(p.timestamp)}');
        buffer.writeln('Crop: ${p.cropType}');
        buffer.writeln('Primary Disease: ${p.primaryDisease}');
        buffer.writeln('Confidence: ${(p.primaryConfidence * 100).toStringAsFixed(1)}%');
        buffer.writeln('Severity: ${p.severity}');
        buffer.writeln('');
        buffer.writeln('Alternatives:');
        for (final alt in p.alternativeDiseases) {
          buffer.writeln('  • ${alt.disease}: ${(alt.confidence * 100).toStringAsFixed(1)}%');
        }
        buffer.writeln('');
        buffer.writeln('Recommendations:');
        for (final rec in p.recommendations) {
          buffer.writeln('  • $rec');
        }
        buffer.writeln('');
      }

      buffer.writeln('═' * 80);
      buffer.writeln('End of Report');
      buffer.writeln('═' * 80);

      await file.writeAsString(buffer.toString());
      _logger.i('Report exported to: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('Report generation failed', error: e);
      rethrow;
    }
  }

  /// Get all exported files
  static Future<List<File>> getExportedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = Directory(directory.path)
          .listSync()
          .where((f) => f.path.contains('agroguard'))
          .map((f) => File(f.path))
          .toList();
      return files;
    } catch (e) {
      _logger.e('Failed to get exported files', error: e);
      return [];
    }
  }

  /// Delete exported file
  static Future<void> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _logger.i('File deleted: $filePath');
      }
    } catch (e) {
      _logger.e('Failed to delete file', error: e);
      rethrow;
    }
  }
}
