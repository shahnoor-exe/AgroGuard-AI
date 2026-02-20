import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/app_providers.dart';
import '../core/services/localization_service.dart';

/// Advanced search and filter widget
class SearchAndFilterWidget extends StatefulWidget {
  const SearchAndFilterWidget({Key? key}) : super(key: key);

  @override
  State<SearchAndFilterWidget> createState() => _SearchAndFilterWidgetState();
}

class _SearchAndFilterWidgetState extends State<SearchAndFilterWidget> {
  late TextEditingController _searchController;
  String _selectedCrop = 'All';
  String _selectedSeverity = 'All';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdvancedPrediction> _filterPredictions(List<AdvancedPrediction> predictions) {
    List<AdvancedPrediction> filtered = predictions;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.primaryDisease.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              p.cropType.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              p.recommendations.any((r) => r.toLowerCase().contains(_searchController.text.toLowerCase())))
          .toList();
    }

    // Crop filter
    if (_selectedCrop != 'All') {
      filtered = filtered.where((p) => p.cropType == _selectedCrop).toList();
    }

    // Severity filter
    if (_selectedSeverity != 'All') {
      filtered = filtered.where((p) => p.severity == _selectedSeverity).toList();
    }

    // Date range filter
    if (_dateRange != null) {
      filtered = filtered
          .where((p) =>
              p.timestamp.isAfter(_dateRange!.start) &&
              p.timestamp.isBefore(_dateRange!.end.add(const Duration(days: 1))))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final language = context.read<SettingsProvider>().language;

    return Consumer<PredictionProvider>(
      builder: (context, predictions, _) {
        final crops = {
          'All',
          ...predictions.predictions.map((p) => p.cropType).toSet(),
        };

        final filteredPredictions = _filterPredictions(predictions.predictions);

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
                  LocalizationService.translate('search', language),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D822D),
                  ),
                ),
                const SizedBox(height: 20),

                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by disease, crop, or recommendation...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // Filters
                if (!isMobile)
                  Row(
                    spacing: 16,
                    children: [
                      _buildFilterDropdown(
                        'Crop',
                        _selectedCrop,
                        crops.toList(),
                        (value) => setState(() => _selectedCrop = value),
                      ),
                      _buildFilterDropdown(
                        'Severity',
                        _selectedSeverity,
                        ['All', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
                        (value) => setState(() => _selectedSeverity = value),
                      ),
                      Expanded(
                        child: _buildDateRangeFilter(),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _selectedCrop = 'All';
                          _selectedSeverity = 'All';
                          _dateRange = null;
                          _searchController.clear();
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  )
                else
                  Column(
                    spacing: 12,
                    children: [
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: _buildFilterDropdown(
                              'Crop',
                              _selectedCrop,
                              crops.toList(),
                              (value) => setState(() => _selectedCrop = value),
                              small: true,
                            ),
                          ),
                          Expanded(
                            child: _buildFilterDropdown(
                              'Severity',
                              _selectedSeverity,
                              ['All', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
                              (value) => setState(() => _selectedSeverity = value),
                              small: true,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: _buildDateRangeFilter(),
                          ),
                          ElevatedButton(
                            onPressed: () => setState(() {
                              _selectedCrop = 'All';
                              _selectedSeverity = 'All';
                              _dateRange = null;
                              _searchController.clear();
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Results summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Found ${filteredPredictions.length} of ${predictions.predictions.length} predictions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (filteredPredictions.isNotEmpty)
                        Chip(
                          label: Text('${filteredPredictions.length}'),
                          backgroundColor: Colors.blue[700],
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged, {
    bool small = false,
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!small)
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        if (!small) const SizedBox(height: 4),
        DropdownButton<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (val) => onChanged(val ?? value),
          isExpanded: small,
          underline: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
      ],
    );

  Widget _buildDateRangeFilter() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: _dateRange,
            );
            if (picked != null) {
              setState(() => _dateRange = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_dateRange == null
                    ? 'Select date range'
                    : '${_dateRange!.start.toLocal().toString().split(' ')[0]} - ${_dateRange!.end.toLocal().toString().split(' ')[0]}'),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
}
