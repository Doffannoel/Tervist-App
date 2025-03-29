import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'running_timestamp.dart';
import 'running_summary.dart';
import 'map_service.dart';
import '../workout_countdown.dart';
import '../treadmill/treadmill_tracker_screen.dart';
import 'package:flutter/scheduler.dart'; // Import for Ticker
import 'location_permission_handler.dart'; // Import the permission handler

class RunningTrackerScreen extends StatefulWidget {
  const RunningTrackerScreen({super.key});

  @override
  State<RunningTrackerScreen> createState() => _RunningTrackerScreenState();
}

class _RunningTrackerScreenState extends State<RunningTrackerScreen> with SingleTickerProviderStateMixin {
  int currentStep = 0; // 0: initial, 1: workout tracking, 2: summary
  bool isWorkoutActive = false;
  bool isPaused = false;
  Timer? _timer;
  Ticker? _ticker; // Ticker for more efficient updates
  final MapController _mapController = MapController();
  
  // Cache for UI updates to prevent rebuilds
  bool _needsUpdate = false;
  
  // Location permission handler
  final LocationPermissionHandler _locationPermissionHandler = LocationPermissionHandler();
  bool _locationPermissionChecked = false;
  
  // Workout metrics
  double distance = 0.0; // Start with 0
  Duration duration = const Duration(seconds: 0); // Start with 0
  int calories = 0; // Start with 0
  int steps = 0; // Start with 0
  int stepsPerMinute = 0; // Start with 0
  List<double> performanceData = List.generate(7, (index) => math.Random().nextDouble() * 3 + 5);

  // For route tracking
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  List<Polyline> polylines = [];

  final Color primaryGreen = const Color(0xFF4CB9A0);
  double celsiusTemp = 28.0; // Temperature value

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
    
    // Check location permission status initially
    _checkLocationPermission();
    
    // Initialize map data
    _initializeMapData();
  }

  // Check location permission status
  Future<void> _checkLocationPermission() async {
    bool hasPermission = await _locationPermissionHandler.isLocationPermissionGranted();
    setState(() {
      _locationPermissionChecked = true;
    });
    
    if (hasPermission) {
      // Start listening to location updates if permission is granted
      _subscribeToLocationUpdates();
    }
  }

  // Request location permission
  Future<bool> _requestLocationPermission() async {
    bool hasPermission = await _locationPermissionHandler.requestLocationPermission(context);
    
    if (hasPermission) {
      // Start listening to location updates if permission is granted
      _subscribeToLocationUpdates();
    }
    
    return hasPermission;
  }

  // Method to subscribe to location updates
  void _subscribeToLocationUpdates() {
    MapService.getLiveLocationStream().listen((newLocation) {
      // Update map data with the new location
      _updateMapWithNewLocation();
      
      // Signal that we need an update
      _needsUpdate = true;
    });
  }

  // Method to update map with new location
  void _updateMapWithNewLocation() {
    // Get the current map data including route history
    final mapData = MapService.getCurrentMapData();
    
    // Update state with the new map data
    setState(() {
      routePoints = mapData.routePoints;
      markers = mapData.markers;
      polylines = mapData.polylines;
    });
    
    // If in active tracking mode, center the map on the current location
    if (isWorkoutActive && currentStep == 1 && _mapController != null) {
      _mapController.move(MapService.getCurrentLocation(), _mapController.camera.zoom);
    }
  }

  Future<void> _initializeMapData() async {
    try {
      final mapData = await MapService.getInitialMapData();
      setState(() {
        routePoints = mapData.routePoints;
        markers = mapData.markers;
        polylines = mapData.polylines;
      });
    } catch (e) {
      // Handle error
      print('Error initializing map: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ticker?.dispose();
    
    // Stop location updates when disposing the screen
    MapService.stopLocationUpdates();
    
    super.dispose();
  }

  // Start workout after ensuring location permission
  Future<void> startWorkoutWithPermissionCheck() async {
    bool hasPermission = await _requestLocationPermission();
    
    if (!hasPermission) {
      // Show snackbar if permission is not granted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aplikasi memerlukan izin lokasi untuk melacak aktivitas lari Anda'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    if (!isWorkoutActive) {
      // Reset route history when starting a new workout
      _resetRouteHistory();
      
      setState(() {
        isWorkoutActive = true;
        isPaused = false;
        currentStep = 1; // Move to workout tracking screen
      });
      _startTimer();
    }
  }

  // Method to reset route history
  void _resetRouteHistory() {
    // This will be handled by the MapService when getting a new stream
    _subscribeToLocationUpdates();
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
    // Update duration - one second at a time
    final newDuration = duration + const Duration(seconds: 1);
    
    // Calculate the actual distance from the route points
    final routePoints = MapService.getRouteHistory();
    double totalDistance = 0.0;
    
    if (routePoints.length > 1) {
      // Calculate the total distance along the route
      for (int i = 1; i < routePoints.length; i++) {
        totalDistance += _calculateDistance(routePoints[i-1], routePoints[i]);
      }
    }
    
    // Steps calculation (about 160 steps per minute for running)
    final stepsPerSecond = 160.0 / 60.0;
    final newStepsCount = steps + stepsPerSecond.round();
    
    // Calculate calories (using a simple approximation)
    // Running burns more calories, around 600 kcal per hour
    final caloriesPerSecond = 600.0 / 3600.0;
    final newCalories = (newDuration.inSeconds * caloriesPerSecond).round();
    
    // Update steps per minute
    stepsPerMinute = 160; // Common running cadence
    
    // Apply updates all at once
    duration = newDuration;
    steps = newStepsCount;
    distance = totalDistance; // Use the calculated distance from route points
    calories = newCalories;
  }

  // Helper method to calculate distance between two coordinates (in kilometers)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert latitude and longitude from degrees to radians
    double lat1 = point1.latitude * (math.pi / 180);
    double lon1 = point1.longitude * (math.pi / 180);
    double lat2 = point2.latitude * (math.pi / 180);
    double lon2 = point2.longitude * (math.pi / 180);
    
    // Haversine formula
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = math.sin(dLat/2) * math.sin(dLat/2) +
               math.cos(lat1) * math.cos(lat2) *
               math.sin(dLon/2) * math.sin(dLon/2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    double distance = earthRadius * c;
    
    return distance;
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
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
                                '${celsiusTemp.toStringAsFixed(0)}°C Sunny',
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
                        _buildWorkoutTypeButton('Outdoor\nrunning', true),
                        _buildWorkoutTypeButton('Walking', false),
                        _buildWorkoutTypeButton('Treadmill', false),
                        _buildWorkoutTypeButton('Outdoor\ncycling', false),
                      ],
                    ),
                  ),
                  
                  // Permission info - Now clickable
                  GestureDetector(
                    onTap: _requestLocationPermission,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Text(
                            'Please allow location permission',
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
                  ),
                  
                  // Map display instead of treadmill image
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: routePoints.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: routePoints.first,
                                initialZoom: 15,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                MarkerLayer(markers: markers),
                                PolylineLayer(polylines: polylines),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: primaryGreen),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading map...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
            
          // GO button - Modified to check location permission
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: InkWell(
                onTap: () async {
                  // First check location permission
                  bool hasPermission = await _requestLocationPermission();
                  
                  if (!hasPermission) {
                    // Show dialog if permission is not granted
                    if (context.mounted) {
                      await _locationPermissionHandler.showLocationServicesDisabledDialog(context);
                    }
                    return;
                  }
                  
                  // If permission granted, proceed with countdown and workout
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WorkoutCountdown(
                          onCountdownComplete: () {
                            Navigator.of(context).pop(); // Pop the countdown screen
                            startWorkoutWithPermissionCheck(); // Start the workout when countdown finishes
                          },
                        ),
                      ),
                    );
                  }
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
          
          // Bottom navigation bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home, 'Home', false),
                _buildNavItem(Icons.restaurant_menu, 'Menu', false),
                _buildNavItem(Icons.directions_run, 'Workout', true),
                _buildNavItem(Icons.person, 'Profile', false),
              ],
            ),
          ),
        ],
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
        if (isTreadmill && !isSelected) {
          // Navigate to TreadmillTrackerScreen if treadmill is selected
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TreadmillTrackerScreen()),
          );
        }
        // If already on running screen, no need to navigate
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
}