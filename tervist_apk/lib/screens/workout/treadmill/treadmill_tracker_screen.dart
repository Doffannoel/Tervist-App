import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'treadmill_timestamp.dart';
import 'treadmill_summary.dart';
import '../workout_countdown.dart';
import 'package:flutter/scheduler.dart'; // Import for Ticker
import '../running/running_tracker_screen.dart'; 
import '/widgets/navigation_bar.dart'; // Import the navigation bar widget

class TreadmillTrackerScreen extends StatefulWidget {
  const TreadmillTrackerScreen({super.key});

  @override
  State<TreadmillTrackerScreen> createState() => _TreadmillTrackerScreenState();
}

class _TreadmillTrackerScreenState extends State<TreadmillTrackerScreen> with SingleTickerProviderStateMixin {
  int currentStep = 0; // 0: initial, 1: workout tracking, 2: summary
  bool isWorkoutActive = false;
  bool isPaused = false;
  Timer? _timer;
  Ticker? _ticker; // Ticker for more efficient updates
  
  // Cache for UI updates to prevent rebuilds
  bool _needsUpdate = false;
  
  // Workout metrics
  double distance = 0.0; // Start with 0
  Duration duration = const Duration(seconds: 0); // Start with 0
  int calories = 0; // Start with 0
  int steps = 0; // Start with 0
  int stepsPerMinute = 0; // Start with 0
  List<double> performanceData = List.generate(7, (index) => math.Random().nextDouble() * 3 + 5);

  final Color primaryGreen = const Color(0xFF4CB9A0);
  double celsiusTemp = 30.0; // Temperature value

  @override
  void initState() {
    super.initState();
    // Create a ticker for more efficient UI updates
    _ticker = createTicker((elapsed) {
      if (_needsUpdate) {
        _needsUpdate = false;
        setState(() {});
      }
    });
    _ticker?.start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ticker?.dispose();
    super.dispose();
  }

  void startWorkout() {
    if (!isWorkoutActive) {
      setState(() {
        isWorkoutActive = true;
        isPaused = false;
        currentStep = 1; // Move to workout tracking screen
      });
      _startTimer();
    }
  }

  void pauseWorkout() {
    if (isWorkoutActive && !isPaused) {
      setState(() {
        isPaused = true;
      });
      _timer?.cancel();
    }
  }

  void resumeWorkout() {
    if (isWorkoutActive && isPaused) {
      setState(() {
        isPaused = false;
      });
      _startTimer();
    }
  }

  void stopWorkout() {
    _timer?.cancel();
    setState(() {
      isWorkoutActive = false;
      isPaused = false;
      currentStep = 2; // Move to summary screen
    });
  }

  void _startTimer() {
    _timer?.cancel();
    
    // Use an isolate-like approach by spawning a single computation future
    Future.microtask(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (isPaused) return;
        
        // Update values but don't trigger setState yet
        await _computeUpdatedMetrics();
        
        // Signal the ticker that we need an update
        _needsUpdate = true;
      });
    });
  }

  // Compute new metrics off the main thread
  Future<void> _computeUpdatedMetrics() async {
    // Update duration - now 1 second at a time
    final newDuration = duration + const Duration(seconds: 1);
    
    // Update steps - exactly 1 step per second
    final newStepsCount = steps + 1;
    
    // Calculate distance based on steps (1300 steps = 1 km)
    final newDistance = newStepsCount / 1300;
    
    // Calculate calories (using a simple approximation, adjusted for 1-second intervals)
    final caloriesPerSecond = 400.0 / 3600.0; // calories burned per second
    final newCalories = (newDuration.inSeconds * caloriesPerSecond).round();
    
    // Update steps per minute - 60 steps per minute (1 per second)
    stepsPerMinute = 60;
    
    // Apply updates all at once
    duration = newDuration;
    steps = newStepsCount;
    distance = newDistance;
    calories = newCalories;
  }
  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get formattedPace {
    // Calculate pace in minutes per km (Pace = Total Time / Distance)
    // Handle division by zero case
    if (distance <= 0) {
      return "0'00\""; // Default when no distance
    }
    
    // Convert total duration to minutes and divide by distance
    double paceMinutes = duration.inMinutes + (duration.inSeconds % 60) / 60;
    double pacePerKm = paceMinutes / distance;
    
    // Format pace as minutes and seconds
    int paceWholeMinutes = pacePerKm.floor();
    int paceSeconds = ((pacePerKm - paceWholeMinutes) * 60).round();
    
    return "$paceWholeMinutes'${paceSeconds.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildInitialScreen();
      case 1:
        return TreadmillTimestamp(
          distance: distance,
          formattedDuration: formattedDuration,
          formattedPace: formattedPace,
          calories: calories,
          steps: steps,
          stepsPerMinute: stepsPerMinute,
          isPaused: isPaused,
          primaryGreen: primaryGreen,
          onPause: pauseWorkout,
          onResume: resumeWorkout,
          onStop: stopWorkout,
        );
      case 2:
        return TreadmillSummary(
          distance: distance,
          formattedDuration: formattedDuration,
          formattedPace: formattedPace,
          calories: calories,
          steps: steps,
          primaryGreen: primaryGreen,
          onBackToHome: () {
            setState(() {
              currentStep = 0; // Back to initial screen
              
              // Reset workout metrics
              distance = 0.0;
              duration = const Duration(seconds: 0);
              calories = 0;
              steps = 0;
              stepsPerMinute = 0;
            });
          },
        );
      default:
        return _buildInitialScreen();
    }
  }

  Widget _buildInitialScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar with profile image
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, Yesaya!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: const AssetImage('assets/images/profile.png'),
                    backgroundColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
            
            // Distance and weather
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Distance section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Distance label with icon
                      Row(
                        children: [
                          Text(
                            'Distance >',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      // Distance value
                      Text(
                        '${distance.toStringAsFixed(2)} KM',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  
                  // Weather information
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${celsiusTemp.toStringAsFixed(0)}°C Cloudy',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Workout type selector
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWorkoutTypeButton('Outdoor\nrunning', false),
                  _buildWorkoutTypeButton('Walking', false),
                  _buildWorkoutTypeButton('Treadmill', true),
                  _buildWorkoutTypeButton('Outdoor\ncycling', false),
                ],
              ),
            ),
            
            // Phone placement info
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
              child: Row(
                children: [
                  Text(
                    'Where should you put your phone?',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.question_mark, color: Colors.white, size: 10),
                  ),
                ],
              ),
            ),
            
            // Treadmill image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/treadmill.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // GO button
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: InkWell(
                  onTap: () {
                    _showBottomSheetPhonePosition(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/buttongo.png',
                        width: 42,
                        height: 42,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavigationBar(
        currentIndex: 2, // Workout tab is selected
        onTap: (index) {
          // Handle navigation
          // Navigation logic would go here
        },
      ),
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

  Widget _buildWorkoutTypeButton(String label, bool isSelected) {
  bool isRunning = label.contains('running');
  bool isTreadmill = label.contains('Treadmill');
  
  return InkWell(
    onTap: () {
      if (isRunning && !isSelected) {
        // Navigate to RunningTrackerScreen if running is selected
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RunningTrackerScreen()),
        );
      }
      // If already on treadmill screen, no need to navigate
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 2,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildRecommendationItem(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            color == Colors.green ? 'Recommended' : "Don't",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheetPhonePosition(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 240, 240, 240),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          // Added margin to the entire container
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet content remains the same
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/buttonbackblack.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Where should you put your \nphone?',
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Increased padding from 10 to 20 for more space
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildRecommendationItem('Backpack', Colors.green),
                    SizedBox(height: 10),
                    _buildRecommendationItem('In your hand', Colors.green),
                    SizedBox(height: 20),
                    Text(
                      "Don't",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildRecommendationItem('Treadmill', Colors.red),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                // Increased padding for the button area
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Modified to show the countdown screen before starting workout
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WorkoutCountdown(
                            onCountdownComplete: () {
                              Navigator.of(context).pop(); // Pop the countdown screen
                              startWorkout(); // Start the workout when countdown finishes
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Got it',
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}