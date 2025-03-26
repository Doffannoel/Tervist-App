import 'package:flutter/material.dart';
import 'dart:async';

class TreadmillTrackerScreen extends StatefulWidget {
  const TreadmillTrackerScreen({super.key});

  @override
  State<TreadmillTrackerScreen> createState() => _TreadmillTrackerScreenState();
}

class _TreadmillTrackerScreenState extends State<TreadmillTrackerScreen> {
  final PageController _pageController = PageController();
  int currentStep = 0; // 0: initial, 1: phone placement, 2: workout tracking
  bool isWorkoutActive = false;
  bool isPaused = false;
  Timer? _timer;
  
  // Workout metrics
  double distance = 0.0;
  Duration duration = Duration.zero;
  int calories = 0;
  int steps = 0;
  int stepsPerMinute = 0;
  List<double> performanceData = [];

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void startWorkout() {
    if (!isWorkoutActive) {
      setState(() {
        isWorkoutActive = true;
        isPaused = false;
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
      duration += const Duration(seconds: 1);
      distance += 8.0 / 3600.0; // km per second
      calories = (duration.inSeconds * (400.0 / 3600.0)).round();
      steps = (duration.inSeconds * (160.0 / 60.0)).round();
      stepsPerMinute = 160;

      double currentPace = distance / (duration.inHours > 0 ? duration.inHours : 1);
      if (performanceData.length < 60) {
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

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentStep == index 
                ? const Color(0xFF2AAF7F)
                : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentStep = index;
                });
              },
              children: [
                _buildInitialScreen(),
                _buildPhonePlacementScreen(),
                _buildWorkoutTrackingScreen(),
              ],
            ),
            if (currentStep != 2) // Don't show indicators on workout screen
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: _buildPageIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialScreen() {
    return Padding(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWorkoutType('Outdoor\nrunning', Icons.directions_run),
              _buildWorkoutType('Walking', Icons.directions_walk),
              _buildWorkoutType('Treadmill', Icons.fitness_center, isSelected: true),
              _buildWorkoutType('Outdoor\ncycling', Icons.directions_bike),
            ],
          ),
          const Spacer(),
          Center(
            child: Image.asset(
              'assets/images/treadmill.png',
              height: 300,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2AAF7F),
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
    );
  }

  Widget _buildWorkoutType(String label, IconData icon, {bool isSelected = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2AAF7F) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2AAF7F) : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPhonePlacementScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Where should you put your phone?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/images/treadmill.png',
              height: 300,
            ),
          ),
          const SizedBox(height: 20),
          _buildPlacementOption('Backpack', true),
          _buildPlacementOption('In your hand', true),
          _buildPlacementOption('Treadmill', false),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                startWorkout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacementOption(String label, bool isRecommended) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            isRecommended ? Icons.check_circle : Icons.cancel,
            color: isRecommended ? const Color(0xFF2AAF7F) : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            isRecommended ? 'Recommended' : 'Don\'t',
            style: TextStyle(
              color: isRecommended ? const Color(0xFF2AAF7F) : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutTrackingScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildMetricsCard(),
          const SizedBox(height: 20),
          _buildControlButtons(),
          const SizedBox(height: 20),
          _buildWorkoutGraph(),
        ],
      ),
    );
  }

  Widget _buildMetricsCard() {
    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(distance.toStringAsFixed(2), 'Km', 'Distance'),
              _buildMetric(formattedDuration, '', 'Time'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(calories.toString(), 'Kcal', 'Calories'),
              _buildMetric(steps.toString(), '', 'Steps'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(stepsPerMinute.toString(), 'SPM', 'Steps/min'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: () {
            if (isPaused) {
              resumeWorkout();
            } else {
              pauseWorkout();
            }
          },
          backgroundColor: const Color(0xFF2AAF7F),
          child: Icon(isPaused ? Icons.play_arrow : Icons.pause),
        ),
        const SizedBox(width: 20),
        FloatingActionButton(
          onPressed: () {
            stopWorkout();
            Navigator.of(context).pop();
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.stop),
        ),
      ],
    );
  }

  Widget _buildWorkoutGraph() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
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
      child: performanceData.isEmpty
          ? const Center(
              child: Text('Start moving to see your performance graph'),
            )
          : CustomPaint(
              size: const Size(double.infinity, 200),
              painter: PerformanceGraphPainter(
                dataPoints: performanceData,
                color: const Color(0xFF2AAF7F),
              ),
            ),
    );
  }
}

class PerformanceGraphPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;

  PerformanceGraphPainter({
    required this.dataPoints,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    if (dataPoints.isEmpty) return;

    final double maxValue = dataPoints.reduce((curr, next) => curr > next ? curr : next);
    final double minValue = dataPoints.reduce((curr, next) => curr < next ? curr : next);
    final double range = maxValue - minValue;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = size.width * i / (dataPoints.length - 1);
      final normalizedY = (dataPoints[i] - minValue) / range;
      final y = size.height * (1 - normalizedY);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw fill
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}