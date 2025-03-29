import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TreadmillTimestamp extends StatefulWidget {
  final double distance;
  final String formattedDuration;
  final String formattedPace;
  final int calories;
  final int steps;
  final int stepsPerMinute;
  final bool isPaused;
  final Color primaryGreen;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const TreadmillTimestamp({
    super.key,
    required this.distance,
    required this.formattedDuration,
    required this.formattedPace,
    required this.calories,
    required this.steps,
    required this.stepsPerMinute,
    required this.isPaused,
    required this.primaryGreen,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  State<TreadmillTimestamp> createState() => _TreadmillTimestampState();
}

class _TreadmillTimestampState extends State<TreadmillTimestamp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Main content in the middle of the screen
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Distance at the top inside container - centered
                        Text(
                          '${widget.distance.toStringAsFixed(2)} Km',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Time and Pace - wide spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMetricColumnCentered(widget.formattedDuration, 'Time'),
                            _buildMetricColumnCentered(widget.formattedPace, 'Pace'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Calories and Steps
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMetricColumnCentered('${widget.calories}', 'Kcal'),
                            _buildMetricColumnCentered('${widget.steps}', 'Steps'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Steps per minute - left aligned but with centered metrics
                        Row(
                          children: [
                            _buildMetricColumnCentered('${widget.stepsPerMinute}', 'SPM'),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Control buttons at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!widget.isPaused)
                      // Pause button
                      InkWell(
                        onTap: widget.onPause,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: widget.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      )
                    else
                      // Play and Stop buttons
                      Row(
                        children: [
                          InkWell(
                            onTap: widget.onResume,
                            child: Image.asset(
                              'assets/images/buttonplay.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: widget.onStop,
                            child: Image.asset(
                              'assets/images/buttonstop.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            
            // Bottom indicator
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Bottom navigation bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, 'Home', false),
                  _buildNavItem(Icons.restaurant_menu, 'Menu', false),
                  _buildNavItem(Icons.directions_run, 'Workout', true),
                  _buildNavItem(Icons.person, 'Profile', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumnCentered(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.black54,
          size: 24,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}