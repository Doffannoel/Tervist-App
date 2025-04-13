import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'share_screen_treadmill.dart';

class TreadmillSummary extends StatelessWidget {
  final double distance;
  final String formattedDuration;
  final String formattedPace;
  final int calories;
  final int steps;
  final Color primaryGreen;
  final VoidCallback onBackToHome;

  const TreadmillSummary({
    super.key,
    required this.distance,
    required this.formattedDuration,
    required this.formattedPace,
    required this.calories,
    required this.steps,
    required this.primaryGreen,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Updated background color to F1F7F6
      backgroundColor: const Color(0xFFF1F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F7F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBackToHome,
        ),
        actions: [
          // Share button
          IconButton(
            icon: Image.asset(
              'assets/images/sharebutton.png',
              width: 60,
              height: 60,

            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShareScreen(
                    distance: distance,
                    formattedDuration: formattedDuration,
                    formattedPace: formattedPace,
                    calories: calories,
                    steps: steps,
                    activityType: 'Treadmill',
                    workoutDate: DateTime.now(),
                    userName: 'Yesaya',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add treadmill image before the text
              Container(
                width: double.infinity,
                height: 500,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Image.asset(
                  'assets/images/treadmill.png',
                  fit: BoxFit.contain,
                ),
              ),
              
              // Tervist | Treadmill text
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Tervist | Treadmill',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              // Primary workout stats card
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Distance and user info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Distance with larger font
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "4,89",
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Km',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // User info with profile image
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/profile.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                'Yesaya',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '12/02/25 8:32 AM',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Time and Pace
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "01:18:02",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Time',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          
                          // Pace column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "15'58\"",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Pace',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Two-column layout for Calories and Steps
              Row(
                children: [
                  // Calories card
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(right: 8, bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Calories title with icon - FIXED OVERFLOW
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange[400],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                // Using Flexible to prevent overflow
                                Flexible(
                                  child: Text(
                                    'Calories Burned',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Calories value
                            Row(
                              children: [
                                Text(
                                  '286',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[400],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Kcal',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Steps card
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(left: 8, bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Steps title with icon - FIXED POTENTIAL OVERFLOW
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_walk,
                                  color: Colors.blue[400],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                // Using Flexible to prevent overflow
                                Flexible(
                                  child: Text(
                                    'Steps',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Steps value
                            Text(
                              '5.234',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Performance chart with updated Pace indicator
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart with labels
                      SizedBox(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBarWithLabel("14'24\"", "1", 100),
                            _buildBarWithLabel("14'12\"", "2", 90),
                            _buildBarWithLabel("13'21\"", "3", 60),
                            _buildBarWithLabel("16'02\"", "4", 130),
                            _buildBarWithLabel("20'22\"", "5", 110),
                          ],
                        ),
                      ),
                      
                      // Pace indicator at bottom right - UPDATED to match image
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Running icon
                            Container(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.directions_run,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Pace text - making it bolder and larger to match the image
                            Text(
                              'Pace',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build bar with label
  Widget _buildBarWithLabel(String timeLabel, String kmLabel, double height) {
    return Column(
      children: [
        // Time label at top
        Text(
          timeLabel,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        // Bar
        Container(
          width: 20,
          height: height * 0.7, // Scale height
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 4),
        // Km label at bottom
        Text(
          kmLabel,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}