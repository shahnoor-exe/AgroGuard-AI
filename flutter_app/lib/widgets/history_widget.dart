import 'package:flutter/material.dart';

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({Key? key}) : super(key: key);

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  // Placeholder data for future Firebase integration
  final List<HistoryEntry> _historyEntries = [
    HistoryEntry(
      id: '1',
      cropType: 'Tomato',
      disease: 'Early Blight',
      confidence: 0.92,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      imageUrl: null,
      recommendations: 'Apply fungicide treatment. Increase air circulation.',
    ),
    HistoryEntry(
      id: '2',
      cropType: 'Potato',
      disease: 'Late Blight',
      confidence: 0.87,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: null,
      recommendations: 'Remove infected leaves. Use copper-based fungicide.',
    ),
    HistoryEntry(
      id: '3',
      cropType: 'Corn',
      disease: 'Healthy',
      confidence: 0.98,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      imageUrl: null,
      recommendations: 'No action needed. Continue regular maintenance.',
    ),
    HistoryEntry(
      id: '4',
      cropType: 'Wheat',
      disease: 'Powdery Mildew',
      confidence: 0.85,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      imageUrl: null,
      recommendations: 'Apply sulfur-based fungicide. Avoid overhead irrigation.',
    ),
    HistoryEntry(
      id: '5',
      cropType: 'Rice',
      disease: 'Brown Spot',
      confidence: 0.79,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      imageUrl: null,
      recommendations: 'Improve drainage. Apply zinc and manganese.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Prediction History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D822D),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Past crop disease predictions and recommendations',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 20),

            // History List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historyEntries.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[200],
                height: 16,
              ),
              itemBuilder: (context, index) => _buildHistoryCard(
                  context,
                  _historyEntries[index],
                  isMobile,
                ),
            ),

            // Firebase Integration Notice
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Firebase integration coming soon - persist your predictions in the cloud',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[700],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual history card
  Widget _buildHistoryCard(
    BuildContext context,
    HistoryEntry entry,
    bool isMobile,
  ) {
    // Color based on disease status
    final isHealthy = entry.disease.toLowerCase() == 'healthy';
    final statusColor = isHealthy ? Colors.green : Colors.orange;
    const diseaseColor = Color(0xFF2D822D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showHistoryDetails(context, entry);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Crop and Disease
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.cropType,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.disease,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: diseaseColor),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(entry.confidence * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Timestamp
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(entry.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recommendation preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Recommendation',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.recommendations,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[700],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // View Details Link
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'View Details',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF2D822D),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show full details in a dialog
  void _showHistoryDetails(BuildContext context, HistoryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.cropType),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Disease:', entry.disease),
              _buildDetailRow('Confidence:', '${(entry.confidence * 100).toStringAsFixed(1)}%'),
              _buildDetailRow('Date & Time:', _formatTime(entry.timestamp)),
              const SizedBox(height: 16),
              Text(
                'Recommendations:',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.recommendations,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

  /// Format timestamp
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// History Entry Model
class HistoryEntry {

  HistoryEntry({
    required this.id,
    required this.cropType,
    required this.disease,
    required this.confidence,
    required this.timestamp,
    required this.imageUrl,
    required this.recommendations,
  });
  final String id;
  final String cropType;
  final String disease;
  final double confidence;
  final DateTime timestamp;
  final String? imageUrl;
  final String recommendations;
}
