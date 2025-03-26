import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'treadmill_timestamp.dart';
import 'treadmill_summary.dart';
import '../running/running_tracker_screen.dart';

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
  double distance = 4.89; // Initial value from Figma
  Duration duration = const Duration(hours: 1, minutes: 18, seconds: 2); // Initial value from Figma
  int calories = 286; // Initial value from Figma
  int steps = 3560; // Initial value from Figma
  int stepsPerMinute = 78; // Initial value from Figma
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hi, Yesaya!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Distance display
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          '4.89',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Km',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                
                // weather display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.amber[800], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${celsiusTemp.toStringAsFixed(1)}°C',
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
            const SizedBox(height: 20),
            // Workout type selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWorkoutType('Outdoor\nrunning', Icons.directions_run),
                _buildWorkoutType('Walking', Icons.directions_walk),
                _buildWorkoutType('Treadmill', Icons.fitness_center, isSelected: true),
                _buildWorkoutType('Outdoor\ncycling', Icons.directions_bike),
              ],
            ),
            // Progress indicator
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Treadmill image
            GestureDetector(
              onTap: () {
                _showPhonePlacementDialog(context);
              },
              child: Center(
                child: Image.asset(
                  'assets/images/treadmill.png',
                  height: 250,
                ),
              ),
            ),
            const Spacer(),
            // GO button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: startWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'GO',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(0),
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
                    const Text(
                      'Where should you put your phone?',
                      style: TextStyle(
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
                  child: const Text(
                    'Recommended',
                    style: TextStyle(
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
                      const Text(
                        'Treadmill',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Text(
                        "Don't",
                        style: TextStyle(
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Got it'),
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
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            'Recommended',
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0, selectedIndex),
            _buildNavItem(Icons.menu, 'Menu', 1, selectedIndex),
            _buildNavItem(Icons.directions_run, 'Workout', 2, selectedIndex),
            _buildNavItem(Icons.person, 'Profile', 3, selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int selectedIndex) {
    final bool isSelected = index == selectedIndex;
    final color = isSelected ? primaryGreen : Colors.grey;

    return InkWell(
      onTap: () {
        // Handle navigation tab tap
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            width: 30,
            decoration: BoxDecoration(
              color: isSelected ? primaryGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutType(String label, IconData icon, {bool isSelected = false}) {
  bool isRunning = label.contains('running');
  bool isTreadmill = label.contains('Treadmill');
  
  return InkWell(
    onTap: () {
      if (isRunning && !isSelected) {
        // Navigasi ke RunningTrackerScreen jika tombol running ditekan
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RunningTrackerScreen()),
        );
      } else if (!isTreadmill && !isSelected) {
        // Handle tipe workout lainnya di sini
        // Misalnya tunjukkan snackbar "Coming soon"
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label coming soon!')),
        );
      }
    },
    child: Column(
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
          style: TextStyle(
            color: isSelected ? primaryGreen : Colors.black,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
}