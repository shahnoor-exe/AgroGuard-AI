import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/app_providers.dart';
import '../core/services/localization_service.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final language = context.read<SettingsProvider>().language;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Consumer<PredictionProvider>(
          builder: (context, predictions, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  LocalizationService.translate('analytics', language),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D822D),
                  ),
                ),
                const SizedBox(height: 24),

                if (predictions.predictions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No data yet. Upload images to see analytics.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  Column(
                    spacing: 24,
                    children: [
                      // Disease frequency chart
                      _buildDiseaseFrequencyChart(context, predictions, isMobile),
                      
                      // Confidence distribution
                      _buildConfidenceDistribution(context, predictions, isMobile),
                      
                      // Statistics grid
                      _buildStatisticsGrid(context, predictions, isMobile, language),
                    ],
                  ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildDiseaseFrequencyChart(
    BuildContext context,
    PredictionProvider predictions,
    bool isMobile,
  ) {
    final diseases = <String, int>{};
    for (final p in predictions.predictions) {
      diseases[p.primaryDisease] = (diseases[p.primaryDisease] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disease Frequency',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 200 : 300),
          BarChart(
            BarChartData(
              maxY: (diseases.values.isEmpty ? 1 : diseases.values.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
              barGroups: diseases.entries.asMap().entries.map((entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.value.toDouble(),
                      color: const Color(0xFF2D822D).withOpacity(0.7 + (entry.key / diseases.length) * 0.3),
                      width: isMobile ? 20 : 40,
                    ),
                  ],
                )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceDistribution(
    BuildContext context,
    PredictionProvider predictions,
    bool isMobile,
  ) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confidence Score Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 200 : 300),
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: predictions.predictions
                      .where((p) => p.primaryConfidence >= 0.9)
                      .length
                      .toDouble(),
                  color: Colors.green,
                  title: '90%+',
                ),
                PieChartSectionData(
                  value: predictions.predictions
                      .where((p) => p.primaryConfidence >= 0.75 && p.primaryConfidence < 0.9)
                      .length
                      .toDouble(),
                  color: Colors.orange,
                  title: '75-90%',
                ),
                PieChartSectionData(
                  value: predictions.predictions
                      .where((p) => p.primaryConfidence < 0.75)
                      .length
                      .toDouble(),
                  color: Colors.red,
                  title: '<75%',
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildStatisticsGrid(
    BuildContext context,
    PredictionProvider predictions,
    bool isMobile,
    String language,
  ) {
    final stats = {
      'Total Predictions': predictions.predictions.length.toString(),
      'Critical Cases': predictions.getCriticalPredictions().length.toString(),
      'Avg Confidence':
          (predictions.predictions.isEmpty
              ? 0
              : predictions.predictions
                  .map((p) => p.primaryConfidence)
                  .reduce((a, b) => a + b) /
                  predictions.predictions.length)
          .toStringAsFixed(2),
      'Last Updated': predictions.predictions.isEmpty
          ? 'N/A'
          : _formatTime(predictions.predictions.first.timestamp),
    };

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.entries
          .map(
            (e) => Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green[50]!,
                      Colors.green[100]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
