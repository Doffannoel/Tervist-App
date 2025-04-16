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

  // Constructor yang menggunakan parameter yang sama seperti di kode asli
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

  // Factory constructor untuk membuat instance dengan data acak
  // Ini memungkinkan penggunaan TreadmillSummary dengan cara yang sama
  factory TreadmillSummary.random({
    required Color primaryGreen,
    required VoidCallback onBackToHome,
  }) {
    final random = math.Random();
    
    // Generate random distance between 2.0 and 8.0 km
    final distance = (200 + random.nextInt(600)) / 100;
    
    // Generate random duration between 30 minutes and 90 minutes
    final durationMinutes = 30 + random.nextInt(60);
    final durationSeconds = random.nextInt(60);
    final formattedDuration = '${durationMinutes ~/ 60 > 0 ? durationMinutes ~/ 60 : '00'}:${durationMinutes % 60 < 10 ? '0' : ''}${durationMinutes % 60}:${durationSeconds < 10 ? '0' : ''}$durationSeconds';
    
    // Calculate random pace (minutes per km)
    final paceSeconds = (durationMinutes * 60 + durationSeconds) ~/ distance;
    final paceMinutes = paceSeconds ~/ 60;
    final paceRemainingSeconds = paceSeconds % 60;
    final formattedPace = "$paceMinutes'${paceRemainingSeconds < 10 ? '0' : ''}$paceRemainingSeconds\"";
    
    // Random calories between 150 and 500
    final calories = 150 + random.nextInt(350);
    
    // Random steps between 3000 and 10000
    final steps = 3000 + random.nextInt(7000);
    
    return TreadmillSummary(
      distance: distance,
      formattedDuration: formattedDuration,
      formattedPace: formattedPace,
      calories: calories,
      steps: steps,
      primaryGreen: primaryGreen,
      onBackToHome: onBackToHome,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate random chart data for each build
    final random = math.Random();
    final chartBars = <Map<String, dynamic>>[];
    for (int i = 1; i <= 5; i++) {
      final barHeight = 60 + random.nextInt(80); // Random height between 60-140
      final barPaceMinutes = 10 + random.nextInt(11); // Random minutes between 10-20
      final barPaceSeconds = random.nextInt(60); // Random seconds between 0-59
      chartBars.add({
        'km': i,
        'height': barHeight,
        'pace': "$barPaceMinutes'${barPaceSeconds < 10 ? '0' : ''}$barPaceSeconds\""
      });
    }

    // Format the distance with comma as decimal separator
    final distanceFormatted = distance.toStringAsFixed(2).replaceAll('.', ',');
    
    // Format the steps with dot as thousands separator
    final formattedSteps = steps.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.'
    );
    
    // Get current date and time
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month < 10 ? '0' : ''}${now.month}/${now.year.toString().substring(2)} ${now.hour}:${now.minute < 10 ? '0' : ''}${now.minute} ${now.hour >= 12 ? 'PM' : 'AM'}';

    return Scaffold(
      // Keeping the light mint green background
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
              
              // Primary workout stats card - set to pure white (#FFFFFF)
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 2,
                color: const Color(0xFFFFFFFF),
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
                                distanceFormatted,
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
                                formattedDate,
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
                                formattedDuration,
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
                                formattedPace,
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
                  // Calories card - set to pure white (#FFFFFF)
                  Expanded(
                    child: Card(
                      elevation: 2,
                      color: const Color(0xFFFFFFFF),
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
                                  '$calories',
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
                  
                  // Steps card - set to pure white (#FFFFFF)
                  Expanded(
                    child: Card(
                      elevation: 2,
                      color: const Color(0xFFFFFFFF),
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
                              formattedSteps,
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
              
              // Performance chart - set to pure white (#FFFFFF)
              Card(
                elevation: 2,
                color: const Color(0xFFFFFFFF),
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
                          children: List.generate(
                            chartBars.length,
                            (index) => _buildBarWithLabel(
                              chartBars[index]['pace'],
                              chartBars[index]['km'].toString(),
                              chartBars[index]['height'].toDouble(),
                            ),
                          ),
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
                              child: const Icon(
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