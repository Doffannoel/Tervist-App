import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class PaceStatisticsWidget extends StatefulWidget {
  final String activityType; // 'Running', 'Treadmill', 'Cycling', 'Walking'
  final List<Map<String, dynamic>>? paceData; // Data for the pace statistics
  final Color primaryColor;
  final bool showEmptyMessage; // Parameter to control empty state message
  final double totalDistance; // Add totalDistance parameter to control bars

  const PaceStatisticsWidget({
    Key? key,
    required this.activityType,
    this.paceData,
    this.showEmptyMessage = false, // Default to false
    required this.totalDistance, // Required parameter
    this.primaryColor = const Color(0xFF4CAF9F), // Teal green color
  }) : super(key: key);

  @override
  State<PaceStatisticsWidget> createState() => _PaceStatisticsWidgetState();
}

class _PaceStatisticsWidgetState extends State<PaceStatisticsWidget> {
  late List<Map<String, dynamic>> _effectivePaceData;
  bool _hasValidData = false;
  late int _barCount;

  @override
  void initState() {
    super.initState();
    _initializePaceData();
  }

  @override
  void didUpdateWidget(PaceStatisticsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paceData != widget.paceData ||
        oldWidget.totalDistance != widget.totalDistance ||
        oldWidget.showEmptyMessage != widget.showEmptyMessage) {
      _initializePaceData();
    }
  }

  void _initializePaceData() {
    // Calculate bar count based on the total distance (rounded up)
    _barCount = widget.totalDistance.ceil();

    // Ensure at least 1 bar is shown
    _barCount = max(1, _barCount);

    // Check if we have valid input data with non-zero values
    bool hasNonZeroData = widget.paceData != null &&
        widget.paceData!.isNotEmpty &&
        widget.paceData!.any((item) =>
            item['pace'] != null &&
            (item['pace'] is num ? item['pace'] > 0 : true));

    _hasValidData = hasNonZeroData;

    if (hasNonZeroData) {
      // Use provided data but ensure we have appropriate number of items
      _effectivePaceData = _ensureBarCount(widget.paceData!, _barCount);
    } else {
      // Generate default empty data
      _effectivePaceData = _generateDefaultPaceData(_barCount);
    }
  }

  // Make sure we have exactly the requested number of bars
  List<Map<String, dynamic>> _ensureBarCount(
      List<Map<String, dynamic>> data, int count) {
    if (data.length == count) return data;

    if (data.length < count) {
      // We need to add more items
      final result = List<Map<String, dynamic>>.from(data);
      for (int i = data.length + 1; i <= count; i++) {
        // Add new items with sequential km values
        // Convert to double first, then round to avoid type inference issues
        final lastPace = data.last['pace'];
        double scaledPace = 0;

        if (lastPace is int) {
          scaledPace = (lastPace * 0.8);
        } else if (lastPace is double) {
          scaledPace = (lastPace * 0.8);
        } else {
          // Try parsing as numeric if it's a string
          scaledPace = double.tryParse(lastPace.toString()) != null
              ? double.parse(lastPace.toString()) * 0.8
              : 8.0; // Default fallback
        }

        result.add({'km': i, 'pace': max(1, scaledPace.round())});
      }
      return result;
    } else {
      // We have too many items, take only up to the bar count
      // First, make sure data is sorted by km
      data.sort((a, b) => (a['km'] as num).compareTo(b['km'] as num));

      // Just return the first 'count' items
      return data.take(count).toList();
    }
  }

  // Generate default pace data when no data is provided
  List<Map<String, dynamic>> _generateDefaultPaceData(int count) {
    // For the single bar case
    if (count == 1) {
      return [
        {'km': 1, 'pace': 8} // Default to non-zero value
      ];
    }

    // Generate default data for multiple bars
    final List<Map<String, dynamic>> data = [];
    for (int i = 1; i <= count; i++) {
      // Generate a pattern of pace values instead of all zeros
      int paceValue = i == 1 ? 8 : 6 + (i % 3); // Vary between 6-8
      data.add({'km': i, 'pace': paceValue});
    }

    return data;
  }

  // Convert pace time string to seconds for comparison
  int _paceTimeToSeconds(String paceTime) {
    if (!paceTime.contains("'")) {
      // Handle numeric-only pace
      return int.tryParse(paceTime) ?? 0;
    }

    final parts = paceTime.replaceAll('"', '').split("'");
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return minutes * 60 + seconds;
  }

  // Find the index of the maximum pace value
  int _findMaxPaceIndex() {
    if (_effectivePaceData.isEmpty) return 0;

    int maxIndex = 0;

    // Check if we have time format or numeric format
    final firstPace = _effectivePaceData[0]['pace'].toString();
    final isTimeFormat = firstPace.contains("'");

    if (isTimeFormat) {
      // For time format, higher value means slower pace
      // So we find the smallest time value (faster pace)
      int minValue = _paceTimeToSeconds(firstPace);

      for (int i = 1; i < _effectivePaceData.length; i++) {
        final currentValue =
            _paceTimeToSeconds(_effectivePaceData[i]['pace'].toString());
        if (currentValue < minValue && currentValue > 0) {
          // Ignore zero values
          minValue = currentValue;
          maxIndex = i;
        }
      }
    } else {
      // For numeric format, higher value means faster pace
      dynamic maxPace = _effectivePaceData[0]['pace'];

      for (int i = 1; i < _effectivePaceData.length; i++) {
        final currentPace = _effectivePaceData[i]['pace'];
        if (currentPace > maxPace) {
          maxPace = currentPace;
          maxIndex = i;
        }
      }
    }

    return maxIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Always ensure we have pace data
    if (_effectivePaceData.isEmpty) {
      _effectivePaceData = _generateDefaultPaceData(_barCount);
    }

    // Find the index of the maximum pace
    final maxPaceIndex = _findMaxPaceIndex();

    return Card(
      elevation: 0, // Removed shadow by setting elevation to 0
      color: const Color(0xFFFFFFFF), // Set the background to pure white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Label for pace units
            Center(
              child: Text(
                // Determine label based on data format
                _effectivePaceData.isNotEmpty &&
                        _effectivePaceData[0]['pace'].toString().contains("'")
                    ? 'min/km'
                    : 'Km/h',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Show empty state message or pace visualization
            widget.showEmptyMessage
                ? Container(
                    height: 220,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      "Kamu lari terlalu pendek",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 220,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List<Widget>.generate(
                        _effectivePaceData.length,
                        (index) {
                          final item = _effectivePaceData[index];
                          final pace = item['pace'];
                          final isMax = index == maxPaceIndex;

                          // Make sure pace is not zero (default to 1 if it is)
                          final effectivePace = pace == 0 ? 1 : pace;

                          // Calculate height percentage for the bar
                          double heightPercentage;

                          final firstPace =
                              _effectivePaceData[0]['pace'].toString();
                          final isTimeFormat = firstPace.contains("'");

                          if (isTimeFormat) {
                            // For time-based pace (min'sec"), we need different calculation
                            // Higher time means slower pace, but taller bars should be faster pace
                            final allValues = _effectivePaceData
                                .map((item) =>
                                    _paceTimeToSeconds(item['pace'].toString()))
                                .where((value) => value > 0) // Filter out zeros
                                .toList();

                            if (allValues.isEmpty) {
                              heightPercentage = isMax ? 1.0 : 0.5;
                            } else {
                              final maxSeconds = allValues.reduce(max);
                              final minSeconds = allValues.reduce(min);
                              final range = maxSeconds - minSeconds;

                              final currentSeconds =
                                  _paceTimeToSeconds(effectivePace.toString());
                              // Invert relationship so faster pace (lower time) gets taller bar
                              heightPercentage = range > 0
                                  ? 0.2 +
                                      0.3 *
                                          ((maxSeconds - currentSeconds) /
                                              range)
                                  : isMax
                                      ? 1.0
                                      : 0.5;
                            }
                          } else {
                            // For regular numeric pace, higher value means faster pace
                            // Convert all values to numeric to be safe
                            final allValues = _effectivePaceData
                                .map((item) =>
                                    double.tryParse(item['pace'].toString()) ??
                                    1.0) // Use 1.0 as fallback
                                .where((value) => value > 0) // Filter out zeros
                                .toList();

                            if (allValues.isEmpty) {
                              heightPercentage = isMax ? 1.0 : 0.5;
                            } else {
                              final maxPaceValue = allValues.reduce(max);
                              final minPaceValue = allValues.reduce(min);
                              final range = maxPaceValue - minPaceValue;

                              final currentValue =
                                  double.tryParse(effectivePace.toString()) ??
                                      1.0;

                              heightPercentage = range > 0
                                  ? 0.3 +
                                      0.7 *
                                          ((currentValue - minPaceValue) /
                                              range)
                                  : isMax
                                      ? 1.0
                                      : 0.5; // If all values are the same, max gets full height
                            }
                          }

                          // Constrain height percentage to reasonable values
                          heightPercentage =
                              max(0.1, min(1.0, heightPercentage));

                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Pace value
                                  Text(
                                    effectivePace.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Bar with "max" label if it's the max pace
                                  Container(
                                    width: 35,
                                    height: 150 * heightPercentage,
                                    decoration: BoxDecoration(
                                      color: widget.primaryColor,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    alignment: Alignment.center,
                                    child: isMax
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'm',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                'a',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                'x',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

            const SizedBox(height: 8),

            // Kilometer markers - only show if not in empty state
            if (!widget.showEmptyMessage)
              Row(
                children: [
                  Text(
                    'Km',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _effectivePaceData
                          .map((item) => Text(
                                item['km'].toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),

            // Icon and title at bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActivityIcon(widget.activityType),
                const SizedBox(width: 8),
                Text(
                  'Pace',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk membuat icon berdasarkan tipe aktivitas
  Widget _buildActivityIcon(String activityType) {
    IconData iconData;

    switch (activityType.toLowerCase()) {
      case 'running':
        iconData = Icons.directions_run;
        break;
      case 'treadmill':
        iconData = Icons.fitness_center;
        break;
      case 'cycling':
        iconData = Icons.directions_bike;
        break;
      case 'walking':
        iconData = Icons.directions_walk;
        break;
      default:
        iconData = Icons.directions_run;
    }

    return Icon(
      iconData,
      size: 24,
      color: Colors.black87,
    );
  }
}
