import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class PaceStatisticsWidget extends StatefulWidget {
  final String activityType; // 'Running', 'Treadmill', 'Cycling', 'Walking'
  final List<Map<String, dynamic>>? paceData; // Optional now as we can generate random or fixed data
  final Color primaryColor;
  final bool useRandomData; // Flag to use random data
  final int barCount; // Number of bars to display

  const PaceStatisticsWidget({
    Key? key,
    required this.activityType,
    this.paceData,
    this.useRandomData = false,
    this.barCount = 5, // Default to 5 bars
    this.primaryColor = const Color(0xFF4CAF9F), // Teal green color
  }) : super(key: key);

  @override
  State<PaceStatisticsWidget> createState() => _PaceStatisticsWidgetState();
}

class _PaceStatisticsWidgetState extends State<PaceStatisticsWidget> {
  late List<Map<String, dynamic>> _effectivePaceData;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializePaceData();
  }

  @override
  void didUpdateWidget(PaceStatisticsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paceData != widget.paceData || 
        oldWidget.useRandomData != widget.useRandomData ||
        oldWidget.barCount != widget.barCount) {
      _initializePaceData();
    }
  }

  void _initializePaceData() {
    if (widget.useRandomData) {
      _effectivePaceData = _generateRandomPaceData(widget.barCount);
    } else if (widget.paceData != null && widget.paceData!.isNotEmpty) {
      // Use provided data but ensure we have exactly barCount items
      _effectivePaceData = _ensureBarCount(widget.paceData!, widget.barCount);
    } else {
      // Generate default data
      _effectivePaceData = _generateDefaultPaceData(widget.barCount);
    }
  }

  // Make sure we have exactly the requested number of bars
  List<Map<String, dynamic>> _ensureBarCount(List<Map<String, dynamic>> data, int count) {
    if (data.length == count) return data;
    
    if (data.length < count) {
      // We need to add more items
      final result = List<Map<String, dynamic>>.from(data);
      for (int i = data.length + 1; i <= count; i++) {
        // Add new items with sequential km values
        if (widget.useRandomData) {
          result.add({
            'km': i,
            'pace': _generateRandomPaceTime(13, 20)
          });
        } else {
          // Add a default numeric pace value (could be customized)
          result.add({
            'km': i,
            'pace': 0
          });
        }
      }
      return result;
    } else {
      // We have too many items, truncate
      return data.sublist(0, count);
    }
  }

  // Generate random pace time in format of minutes'seconds"
  String _generateRandomPaceTime(int minMinutes, int maxMinutes) {
    final minutes = minMinutes + _random.nextInt(maxMinutes - minMinutes + 1);
    final seconds = _random.nextInt(60);
    // Use padLeft instead of padStart for Dart
    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }

  // Generate random pace data for specified number of kilometers with time format
  List<Map<String, dynamic>> _generateRandomPaceData(int count) {
    final data = <Map<String, dynamic>>[];
    
    // Values similar to the image provided
    if (count == 1) {
      data.add({'km': 1, 'pace': '9'});
    } else if (count >= 5) {
      // Generate 5 values similar to earlier example
      data.add({'km': 1, 'pace': _generateRandomPaceTime(14, 15)});
      data.add({'km': 2, 'pace': _generateRandomPaceTime(14, 15)});
      data.add({'km': 3, 'pace': _generateRandomPaceTime(13, 14)});
      data.add({'km': 4, 'pace': _generateRandomPaceTime(17, 19)});
      data.add({'km': 5, 'pace': _generateRandomPaceTime(19, 21)});
      
      // Add more if needed
      for (int i = 6; i <= count; i++) {
        data.add({'km': i, 'pace': _generateRandomPaceTime(13, 21)});
      }
    } else {
      // Generate 2-4 random values
      for (int i = 1; i <= count; i++) {
        data.add({'km': i, 'pace': _generateRandomPaceTime(13, 21)});
      }
    }
    
    return data;
  }

  // Generate default pace data when no data is provided and random is not enabled
  List<Map<String, dynamic>> _generateDefaultPaceData(int count) {
    // For the single bar case like in the screenshot
    if (count == 1) {
      return [{'km': 1, 'pace': 9}];
    }
    
    // Generate default fixed data for multiple bars
    final List<Map<String, dynamic>> data = [];
    for (int i = 1; i <= count; i++) {
      data.add({'km': i, 'pace': 0});
    }
    
    // Add a "max" value to make it more interesting
    if (data.isNotEmpty) {
      final maxIndex = _random.nextInt(data.length);
      data[maxIndex]['pace'] = 9; // Set one bar to have a value
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
    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);
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
        final currentValue = _paceTimeToSeconds(_effectivePaceData[i]['pace'].toString());
        if (currentValue < minValue) {
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
    // Always show 5 bars, even if paceData is empty
    if (_effectivePaceData.isEmpty) {
      _effectivePaceData = _generateDefaultPaceData(widget.barCount);
    }
    
    // Find the index of the maximum pace
    final maxPaceIndex = _findMaxPaceIndex();
    
    return Card(
      elevation: 4,
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
            
            // Pace visualization
            SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List<Widget>.generate(
                  _effectivePaceData.length,
                  (index) {
                    final item = _effectivePaceData[index];
                    final pace = item['pace'];
                    final isMax = index == maxPaceIndex;
                    
                    // Calculate height percentage for the bar
                    double heightPercentage;
                    
                    final firstPace = _effectivePaceData[0]['pace'].toString();
                    final isTimeFormat = firstPace.contains("'");
                    
                    if (isTimeFormat) {
                      // For time-based pace (min'sec"), we need different calculation
                      // Higher time means slower pace, but taller bars should be faster pace
                      final allValues = _effectivePaceData
                          .map((item) => _paceTimeToSeconds(item['pace'].toString()))
                          .toList();
                          
                      final maxSeconds = allValues.reduce(max);
                      final minSeconds = allValues.reduce(min);
                      final range = maxSeconds - minSeconds;
                      
                      final currentSeconds = _paceTimeToSeconds(pace.toString());
                      // Invert relationship so faster pace (lower time) gets taller bar
                      heightPercentage = range > 0 
                          ? 0.3 + 0.7 * ((maxSeconds - currentSeconds) / range)
                          : 1.0;
                    } else {
                      // For regular numeric pace, higher value means faster pace
                      // Convert all values to numeric to be safe
                      final allValues = _effectivePaceData
                          .map((item) => double.tryParse(item['pace'].toString()) ?? 0.0)
                          .toList();
                          
                      final maxPaceValue = allValues.reduce(max);
                      final minPaceValue = allValues.reduce(min);
                      final range = maxPaceValue - minPaceValue;
                      
                      final currentValue = double.tryParse(pace.toString()) ?? 0.0;
                      
                      heightPercentage = range > 0 
                          ? 0.3 + 0.7 * ((currentValue - minPaceValue) / range)
                          : isMax ? 1.0 : 0.3; // If all values are the same, max gets full height
                    }
                    
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Pace value
                            Text(
                              pace.toString(),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
            
            // Kilometer markers
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
                    children: _effectivePaceData.map((item) => Text(
                      item['km'].toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )).toList(),
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