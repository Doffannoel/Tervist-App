import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'running_timestamp.dart';
import 'running_summary.dart';
import 'map_service.dart';
import '../treadmill/treadmill_tracker_screen.dart';

class RunningTrackerScreen extends StatefulWidget {
  const RunningTrackerScreen({super.key});

  @override
  State<RunningTrackerScreen> createState() => _RunningTrackerScreenState();
}

class _RunningTrackerScreenState extends State<RunningTrackerScreen> {
  int currentStep = 0; // 0: initial, 1: workout tracking, 2: summary
  bool isWorkoutActive = false;
  bool isPaused = false;
  Timer? _timer;
  final MapController _mapController = MapController();

  // Workout metrics
  double distance = 4.89; // Initial value
  Duration duration = const Duration(hours: 1, minutes: 18, seconds: 2);
  int calories = 286;
  int steps = 3560;
  int stepsPerMinute = 78;
  
  // For route tracking
  late List<LatLng> routePoints;
  late List<Marker> markers;
  late List<Polyline> polylines;

  final Color primaryGreen = const Color(0xFF2AAF7F);
  double celsiusTemp = 27.5; // Temperature value

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  Future<void> _initializeMapData() async {
    final mapData = await MapService.getInitialMapData();
    setState(() {
      routePoints = mapData.routePoints;
      markers = mapData.markers;
      polylines = mapData.polylines;
    });
  }

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
        return RunningTimestamp(
          distance: distance,
          formattedDuration: formattedDuration,
          formattedPace: formattedPace,
          calories: calories,
          routePoints: routePoints,
          markers: markers,
          polylines: polylines,
          isPaused: isPaused,
          primaryGreen: primaryGreen,
          onPause: pauseWorkout,
          onResume: resumeWorkout,
          onStop: stopWorkout,
        );
      case 2:
        return RunningSummary(
          distance: distance,
          formattedDuration: formattedDuration,
          formattedPace: formattedPace,
          calories: calories,
          steps: steps,
          routePoints: routePoints,
          markers: markers,
          polylines: polylines,
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
      body: Stack(
        children: [
          // Flutter Map as the background
          if (routePoints != null && markers != null && polylines != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: routePoints.isNotEmpty ? routePoints.first : const LatLng(-7.767, 110.378),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  // enableScrollWheel: true,
                  enableMultiFingerGestureRace: true,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.running_app',
                ),
                PolylineLayer(
                  polylines: polylines,
                ),
                MarkerLayer(
                  markers: markers,
                ),
                // Location layer
                // const CurrentLocationLayer(),
              ],
            )
          else
            Container(color: Colors.grey[200]), // Placeholder while loading
          
          // Overlay with workout UI
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hi, admin!',
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
                    
                    // Weather display
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
                    _buildWorkoutType('Outdoor\nrunning', Icons.directions_run, isSelected: true),
                    _buildWorkoutType('Walking', Icons.directions_walk),
                    _buildWorkoutType('Treadmill', Icons.fitness_center),
                    _buildWorkoutType('Outdoor\ncycling', Icons.directions_bike),
                  ],
                ),
                const Spacer(),
                // GO button
                Center(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: FloatingActionButton(
                      onPressed: startWorkout,
                      backgroundColor: primaryGreen,
                      child: const Text(
                        'GO',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 70), // Space for bottom navigation
              ],
            ),
          ),
          // Bottom navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigationBar(2), // 2 is for Workout tab
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
        if (isTreadmill && !isSelected) {
          // Navigasi ke TreadmillTrackerScreen jika tombol treadmill ditekan
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TreadmillTrackerScreen()),
          );
        } else if (!isRunning && !isSelected) {
          // Handle tipe workout lainnya di sini
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