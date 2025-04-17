import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'share_screen_treadmill.dart';
import '/api/auth_helper.dart'; // Import for user data
import 'package:cached_network_image/cached_network_image.dart'; // Import for cached network images
import 'package:intl/intl.dart'; // For date formatting

class TreadmillSummary extends StatefulWidget {
  final double distance;
  final String formattedDuration;
  final String formattedPace;
  final int calories;
  final int steps;
  final Color primaryGreen;
  final VoidCallback onBackToHome;
  final String
      userName; // We'll keep this but also load from AuthHelper if needed

  // Constructor
  const TreadmillSummary({
    super.key,
    required this.distance,
    required this.formattedDuration,
    required this.formattedPace,
    required this.calories,
    required this.steps,
    required this.primaryGreen,
    required this.onBackToHome,
    required this.userName,
  });

  // Factory constructor for random data
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
    final formattedDuration =
        '${durationMinutes ~/ 60 > 0 ? durationMinutes ~/ 60 : '00'}:${durationMinutes % 60 < 10 ? '0' : ''}${durationMinutes % 60}:${durationSeconds < 10 ? '0' : ''}$durationSeconds';

    // Calculate random pace (minutes per km)
    final paceSeconds = (durationMinutes * 60 + durationSeconds) ~/ distance;
    final paceMinutes = paceSeconds ~/ 60;
    final paceRemainingSeconds = paceSeconds % 60;
    final formattedPace =
        "$paceMinutes'${paceRemainingSeconds < 10 ? '0' : ''}$paceRemainingSeconds\"";

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
      userName:
          'User', // Default name that will be replaced when data is loaded
    );
  }

  @override
  State<TreadmillSummary> createState() => _TreadmillSummaryState();
}

class _TreadmillSummaryState extends State<TreadmillSummary> {
  String _userName = "";
  String? _profileImageUrl;
  bool _isLoading = true;
  final DateTime _currentDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize with the provided username
      _userName = widget.userName;

      // Try to get from AuthHelper
      if (_userName.isEmpty || _userName == "User") {
        String? storedName = await AuthHelper.getUserName();
        if (storedName != null && storedName.isNotEmpty) {
          setState(() {
            _userName = storedName;
          });
        }
      }

      // Get profile image URL
      String? imageUrl = await AuthHelper.getProfilePicture();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        setState(() {
          _profileImageUrl = imageUrl;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            color: widget.primaryGreen,
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

  @override
  Widget build(BuildContext context) {
    // Generate random chart data for each build
    final random = math.Random();
    final chartBars = <Map<String, dynamic>>[];
    for (int i = 1; i <= 5; i++) {
      final barHeight = 60 + random.nextInt(80); // Random height between 60-140
      final barPaceMinutes =
          10 + random.nextInt(11); // Random minutes between 10-20
      final barPaceSeconds = random.nextInt(60); // Random seconds between 0-59
      chartBars.add({
        'km': i,
        'height': barHeight,
        'pace':
            "$barPaceMinutes'${barPaceSeconds < 10 ? '0' : ''}$barPaceSeconds\""
      });
    }

    // Format the distance with comma as decimal separator
    final distanceFormatted =
        widget.distance.toStringAsFixed(2).replaceAll('.', ',');

    // Format the steps with dot as thousands separator
    final formattedSteps = widget.steps.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    // Format date and time
    String formattedDate = DateFormat('dd/MM/yyyy').format(_currentDateTime);
    String formattedTime = DateFormat('HH:mm').format(_currentDateTime);

    return Scaffold(
      // Keeping the light mint green background
      backgroundColor: const Color(0xFFF1F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F7F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBackToHome,
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
                    distance: widget.distance,
                    formattedDuration: widget.formattedDuration,
                    formattedPace: widget.formattedPace,
                    calories: widget.calories,
                    steps: widget.steps,
                    activityType: 'Treadmill',
                    workoutDate: DateTime.now(),
                    userName: _userName,
                    profileImageUrl: _profileImageUrl,
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

                          // User info with profile image - updated to use cached network image
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _isLoading
                                  ? Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                widget.primaryGreen),
                                      ),
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: _profileImageUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: _profileImageUrl!,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          widget.primaryGreen),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/profile.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Image.asset(
                                                'assets/images/profile.png',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                              const SizedBox(height: 4),
                              _isLoading
                                  ? SizedBox(
                                      width: 50,
                                      height: 10,
                                      child: LinearProgressIndicator(
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                widget.primaryGreen),
                                      ),
                                    )
                                  : Text(
                                      _userName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                              Text(
                                '$formattedDate $formattedTime',
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
                                widget.formattedDuration,
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
                                widget.formattedPace,
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
                                  '${widget.calories}',
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
                            SizedBox(
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
}