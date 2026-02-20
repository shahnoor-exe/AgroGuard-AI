import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({Key? key}) : super(key: key);

  @override
  State<SensorDashboard> createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  late Future<SensorData> _sensorDataFuture;

  @override
  void initState() {
    super.initState();
    _sensorDataFuture = _fetchSensorData();
  }

  /// Fetch sensor data from backend
  Future<SensorData> _fetchSensorData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/sensor'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SensorData.fromJson(jsonData);
      } else {
        throw 'Failed to load sensor data (Status: ${response.statusCode})';
      }
    } catch (e) {
      throw 'Error: ${e.toString()}\n\nMake sure backend is running at http://localhost:5000';
    }
  }

  /// Refresh sensor data
  Future<void> _refreshSensorData() async {
    setState(() {
      _sensorDataFuture = _fetchSensorData();
    });
  }

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
            // Header with Refresh Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensor Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D822D),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time farm sensor readings',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _refreshSensorData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh sensor data',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF2D822D),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sensor Data Display
            FutureBuilder<SensorData>(
              future: _sensorDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF2D822D),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading sensor data...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Error loading sensor data',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red[700],
                              ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshSensorData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final sensorData = snapshot.data!;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSensorCard(
                        context,
                        'Soil Moisture',
                        '${sensorData.soilMoisture}%',
                        Icons.water_drop,
                        Colors.blue,
                        isMobile,
                      ),
                      _buildSensorCard(
                        context,
                        'Temperature',
                        '${sensorData.temperature}°C',
                        Icons.thermostat,
                        Colors.orange,
                        isMobile,
                      ),
                      _buildSensorCard(
                        context,
                        'Humidity',
                        '${sensorData.humidity}%',
                        Icons.cloud,
                        Colors.cyan,
                        isMobile,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual sensor card
  Widget _buildSensorCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) => Container(
      width: isMobile ? double.infinity : (300 - 26) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              IconTheme(
                data: IconThemeData(color: color),
                child: Icon(icon),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
}

/// Sensor Data Model
class SensorData {

  SensorData({
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) => SensorData(
      soilMoisture: (json['soil_moisture'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
    );
  final double soilMoisture;
  final double temperature;
  final double humidity;
}
