import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'treadmill_summary.dart';

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
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.all(45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.distance.toStringAsFixed(2)} Km',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildMetricColumn(widget.formattedDuration, 'Time'),
                        const SizedBox(width: 60),
                        _buildMetricColumn(widget.formattedPace, 'Pace'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildMetricColumn('${widget.calories}', 'Kcal'),
                        const SizedBox(width: 110),
                        _buildMetricColumn('${widget.steps}', 'Steps'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildMetricColumn('${widget.stepsPerMinute}', 'SPM'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.isPaused)
                  // Single pause button when running (not paused)
                  InkWell(
                    onTap: widget.onPause,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.primaryGreen,
                      ),
                      child: const Icon(
                        Icons.pause,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  // Both play and stop buttons when paused
                  Row(
                    children: [
                      InkWell(
                        onTap: widget.onResume,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.primaryGreen,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),
                      InkWell(
                        onTap: widget.onStop,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange,
                          ),
                          child: const Icon(
                            Icons.stop,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.montserratAlternates(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserratAlternates(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}