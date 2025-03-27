import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'treadmill_timestamp.dart';
import 'treadmill_summary.dart';

class TreadmillTrackerScreen extends StatefulWidget {
  const TreadmillTrackerScreen({super.key});

  @override
  State<TreadmillTrackerScreen> createState() => _TreadmillTrackerScreenState();
}

class _TreadmillTrackerScreenState extends State<TreadmillTrackerScreen> {
  int currentStep = 0; // 0: initial, 1: workout tracking, 2: summary
  bool isWorkoutActive = false;
  bool isPaused = false;
  Timer? _timer;

  // Workout metrics
  double distance = 4.89; // Initial value
  Duration duration = const Duration(hours: 1, minutes: 18, seconds: 2); // Initial value
  int calories = 286; // Initial value
  int steps = 3560; // Initial value
  int stepsPerMinute = 78; // Initial value
  List<double> performanceData = List.generate(7, (index) => math.Random().nextDouble() * 3 + 5);

  final Color primaryGreen = const Color(0xFF2AAF7F);
  double celsiusTemp = 27.5; // Temperature value

  @override
  void dispose() {
    _timer?.cancel();
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        _updateWorkoutMetrics();
      }
    });
  }

  void _updateWorkoutMetrics() {
    setState(() {
      // Update duration
      duration += const Duration(seconds: 1);

      // Simulate distance increase (approximately 8 km/h pace)
      distance += 8.0 / 3600.0; // km per second

      // Simulate calorie burn (approximately 400 kcal per hour)
      calories = (duration.inSeconds * (400.0 / 3600.0)).round();

      // Simulate steps (approximately 160 steps per minute)
      steps = (duration.inSeconds * (160.0 / 60.0)).round();
      stepsPerMinute = 160;

      // Add performance data point (pace in km/h)
      double currentPace = distance / (duration.inHours > 0 ? duration.inHours : 1);
      if (performanceData.length < 60) { // Keep last 60 data points
        performanceData.add(currentPace);
      } else {
        performanceData.removeAt(0);
        performanceData.add(currentPace);
      }
    });
  }

  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get formattedPace {
    // Calculate pace in minutes per km
    double paceMinutes = duration.inMinutes / distance;
    int paceWholeMinutes = paceMinutes.floor();
    int paceSeconds = ((paceMinutes - paceWholeMinutes) * 60).round();
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
            });
          },
        );
      default:
        return _buildInitialScreen();
    }
  }

  Widget _buildInitialScreen() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Hi, Yesaya!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person),
              radius: 20,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Distance section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Distance label with icon
                    InkWell(
                      onTap: () {
                        // Navigate to distance detail page
                      },
                      child: Row(
                        children: [
                          Text(
                            'Distance >',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Distance value
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Text(
                        '${distance.toStringAsFixed(2)} KM',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.amber[600]),
                    Text(
                      '${celsiusTemp.toStringAsFixed(1)}°C Sunny',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu Container - Workout Types (Treadmill is selected)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWorkoutTypeButton('Outdoor\nrunning', Icons.directions_run),
                _buildWorkoutTypeButton('Walking', Icons.directions_walk),
                _buildWorkoutTypeButton('Treadmill', Icons.fitness_center, isSelected: true),
                _buildWorkoutTypeButton('Outdoor\ncycling', Icons.directions_bike),
              ],
            ),
          ),
          // Where should you put your phone? - TextButton
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: TextButton(
              onPressed: () {
                _showPhonePlacementDialog(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              child: Row(
                children: [
                  Text(
                    'Where should you put your phone?',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          // Treadmill Image Container
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/treadmill.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // GO Button - Circular button
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: InkWell(
                onTap: () {
                  _showPhonePlacementDialog(context);
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'GO',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      extendBody: true, // Important for floating navigation bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFloatingNavItem(Icons.home, 'Home', 0),
            _buildFloatingNavItem(Icons.restaurant_menu, 'Menu', 1),
            _buildFloatingNavItem(Icons.directions_run, 'Workout', 2, isActive: true),
            _buildFloatingNavItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  void _showPhonePlacementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Where should you put your phone?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/treadmill.png',
                  height: 150,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Recommended',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPhonePlacementOption('Backpack', Icons.backpack),
                const SizedBox(height: 8),
                _buildPhonePlacementOption('In your hand', Icons.back_hand),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Treadmill',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        "Don't",
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      startWorkout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Got it',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhonePlacementOption(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          const Spacer(),
          Text(
            'Recommended',
            style: GoogleFonts.poppins(
              color: primaryGreen,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavItem(IconData icon, String label, int index, {bool isActive = false}) {
    return InkWell(
      onTap: () {
        // Navigate to corresponding page
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? primaryGreen : Colors.black,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isActive ? primaryGreen : Colors.black,
              fontSize: 12,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutTypeButton(String label, IconData icon, {bool isSelected = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: isSelected ? primaryGreen : Colors.black,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}