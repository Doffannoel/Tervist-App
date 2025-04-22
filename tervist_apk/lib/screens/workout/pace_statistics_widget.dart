import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaceStatisticsWidget extends StatefulWidget {
  final String activityType; // 'Running', 'Treadmill', 'Cycling', 'Walking'
  final List<Map<String, dynamic>> paceData; // Data dari screen summary atau timestamp
  final Color primaryColor;

  const PaceStatisticsWidget({
    Key? key,
    required this.activityType,
    required this.paceData,
    this.primaryColor = const Color(0xFF4CAF50), // Default green color
  }) : super(key: key);

  @override
  State<PaceStatisticsWidget> createState() => _PaceStatisticsWidgetState();
}

class _PaceStatisticsWidgetState extends State<PaceStatisticsWidget> {
  @override
  Widget build(BuildContext context) {
    // Check if paceData is empty (kilometer is 0)
    if (widget.paceData.isEmpty) {
      return _buildEmptyStateCard();
    }
    
    // Validasi data pace untuk memastikan tidak kosong
    final List<Map<String, dynamic>> validPaceData = widget.paceData.isEmpty 
        ? [{'km': 1, 'pace': 0}] 
        : widget.paceData;
    
    // Cari pace maksimum untuk skala visualisasi
    final maxPace = validPaceData.map((item) => item['pace'] as num).reduce(
        (value, element) => value > element ? value : element);
    
    // Cari pace maksimum dengan indexnya untuk label "max"
    int maxPaceIndex = 0;
    for (int i = 0; i < validPaceData.length; i++) {
      if (validPaceData[i]['pace'] == maxPace) {
        maxPaceIndex = i;
        break;
      }
    }

    return Card(
      elevation: 4,
      color: const Color(0xFFFFFFFF), // Set the background to pure white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with activity type
           
            const SizedBox(height: 16),
            
            // Km/h label
            Center(
              child: Text(
                'Km/h',
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
                  validPaceData.length,
                  (index) {
                    final item = validPaceData[index];
                    final pace = item['pace'] as num;
                    final isMax = index == maxPaceIndex;
                    
                    // Calculate height percentage for the bar
                    final heightPercentage = maxPace > 0 ? (pace / maxPace) * 100 : 0;
                    
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
                              height: 150 * (heightPercentage / 100),
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
                    children: validPaceData.map((item) => Text(
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

  // Card to display when there's no data (kilometer is 0)
  Widget _buildEmptyStateCard() {
    return Card(
      elevation: 4,
      color: const Color(0xFFFFFFFF), // Set the background to pure white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state icon
              Icon(
                _getEmptyStateIcon(widget.activityType),
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              // Empty state message
              Text(
                "You haven't run yet",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                "Start your activity to see your pace statistics",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method untuk mendapatkan icon untuk tampilan empty state
  IconData _getEmptyStateIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'treadmill':
        return Icons.fitness_center;
      case 'cycling':
        return Icons.directions_bike;
      case 'walking':
        return Icons.directions_walk;
      default:
        return Icons.directions_run;
    }
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