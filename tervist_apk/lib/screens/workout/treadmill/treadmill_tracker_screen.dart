import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'treadmill_timestamp.dart';
import 'treadmill_summary.dart';
import '../workout_countdown.dart';
import 'package:flutter/scheduler.dart';
import '../weather_service.dart';
import '../workout_navbar.dart';


class TreadmillTrackerScreen extends StatefulWidget {
  final Function(String)? onWorkoutTypeChanged;

  const TreadmillTrackerScreen({
    super.key, 
    this.onWorkoutTypeChanged,
  });

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
  double distance = 0.0;
  Duration duration = const Duration(seconds: 0);
  int calories = 0;
  int steps = 0;
  int stepsPerMinute = 0;
  List<double> performanceData = List.generate(7, (index) => math.Random().nextDouble() * 3 + 5);

  final Color primaryGreen = const Color(0xFF4CB9A0);

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
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
      // Keep the bottom navigation bar consistent
      
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
    return Padding(
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
                const WeatherWidget(),
              ],
            ),
          ),
          
          // Workout type selector - Pass the callback from the parent
          WorkoutNavbar(
            currentWorkoutType: 'Treadmill',
            onWorkoutTypeChanged: (newType) {
              // Pass the type change to the parent
              if (widget.onWorkoutTypeChanged != null) {
                widget.onWorkoutTypeChanged!(newType);
              }
            },
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
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.question_mark, color: Colors.white, size: 10),
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
                    child: Text(
                      'GO',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F4F7),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 5.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Where should you put your phone?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Recommended section
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
                child: Text(
                  'Recommended',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              
              // Backpack option
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CB9A0), // Green circle
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Backpack',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              // In your hand option
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 0.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CB9A0), // Green circle
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'In your hand',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Don't section
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 25.0, 30.0, 0.0),
                child: Text(
                  'Don\'t',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              
              // Treadmill option (don't)
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE74C3C), // Red circle
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Treadmill',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Got it button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Show countdown then start workout
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WorkoutCountdown(
                              onCountdownComplete: () {
                                Navigator.of(context).pop();
                                startWorkout();
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.black26,
                      ),
                      child: Text(
                        'Got it',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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