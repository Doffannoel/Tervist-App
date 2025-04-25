import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class TreadmillPaceStatisticsWidget extends StatelessWidget {
  final Color primaryColor;
  final int barCount;

  const TreadmillPaceStatisticsWidget({
    Key? key,
    this.primaryColor = const Color(0xFF4CAF9F), // Default teal green color
    this.barCount = 5, // Default to 5 bars
  }) : super(key: key);

  // Generate random pace data with min'sec" format
  List<Map<String, dynamic>> _generateRandomPaceData() {
    final random = math.Random();
    final List<Map<String, dynamic>> data = [];

    // Generate random pace data
    for (int i = 1; i <= barCount; i++) {
      final paceMinutes = 5 + random.nextInt(3); // Between 5-7 minutes
      final paceSeconds = random.nextInt(60); // 0-59 seconds
      final formattedPace =
          "$paceMinutes'${paceSeconds < 10 ? '0' : ''}$paceSeconds\"";

      data.add({
        'km': i,
        'pace': formattedPace,
        // Store seconds for easier comparison
        'totalSeconds': paceMinutes * 60 + paceSeconds,
      });
    }

    return data;
  }

  // Find the fastest pace (lowest time)
  int _findFastestPaceIndex(List<Map<String, dynamic>> paceData) {
    if (paceData.isEmpty) return 0;

    int fastestIndex = 0;
    int fastestTime = paceData[0]['totalSeconds'] as int;

    for (int i = 1; i < paceData.length; i++) {
      final currentTime = paceData[i]['totalSeconds'] as int;
      if (currentTime < fastestTime) {
        fastestTime = currentTime;
        fastestIndex = i;
      }
    }

    return fastestIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Generate random pace data
    final paceData = _generateRandomPaceData();

    // Find the fastest pace index (min time = max pace)
    final fastestPaceIndex = _findFastestPaceIndex(paceData);

    // Find min and max times for scaling
    final allTimes =
        paceData.map((data) => data['totalSeconds'] as int).toList();
    final maxTime = allTimes.reduce(math.max);
    final minTime = allTimes.reduce(math.min);
    final timeRange = maxTime - minTime;

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
                'min/km',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Pace visualization with bars
            SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List<Widget>.generate(
                  paceData.length,
                  (index) {
                    final item = paceData[index];
                    final pace = item['pace'];
                    final isMax = index == fastestPaceIndex;

                    // Calculate height percentage for the bar (invert relationship)
                    // Faster pace (lower time) gets taller bar
                    final currentTime = item['totalSeconds'] as int;
                    final heightPercentage = timeRange > 0
                        ? 0.3 + 0.7 * ((maxTime - currentTime) / timeRange)
                        : isMax
                            ? 1.0
                            : 0.3;

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
                                color: primaryColor,
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
                    children: paceData
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
                Icon(
                  Icons.directions_run, // Running icon
                  size: 24,
                  color: Colors.black87,
                ),
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
}
