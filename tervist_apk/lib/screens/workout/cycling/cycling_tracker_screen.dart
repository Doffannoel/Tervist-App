import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/auth_helper.dart';
import 'package:tervist_apk/screens/workout/cycling/cycling_history.dart';
import 'package:tervist_apk/screens/workout/cycling/cycling_service.dart';
import 'cycling_timestamp.dart';
import 'cycling_summary.dart';
import '../map_service.dart';
import '../workout_countdown.dart';
import '../workout_navbar.dart';
import 'package:flutter/scheduler.dart'; // Import for Ticker
import '../location_permission_handler.dart'; // Import the permission handler
import '../follow_me_button.dart'; // Import the follow me button widget
import '../weather_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// Added import for navigation bar

class CyclingTrackerScreen extends StatefulWidget {
  final Function(String)? onWorkoutTypeChanged;

  const CyclingTrackerScreen({
    super.key,
    this.onWorkoutTypeChanged,
  });

  @override
  State<CyclingTrackerScreen> createState() => _CyclingTrackerScreenState();
}

class _CyclingTrackerScreenState extends State<CyclingTrackerScreen>
    with SingleTickerProviderStateMixin {
  int currentStep = 0; // 0: initial, 1: workout tracking, 2: summary
  bool isWorkoutActive = false;
  bool isPaused = false;
  Timer? _timer;
  Ticker? _ticker; // Ticker for more efficient updates
  final MapController _mapController = MapController();

  // Follow me button state
  bool _isFollowingUser = true; // Enable follow mode by default

  // Cache for UI updates to prevent rebuilds
  bool _needsUpdate = false;

  // User profile data
  String _userName = "User";
  String? _profileImageUrl;
  final bool _isLoggedIn = false;
  final bool _isLoading = true;

  // Location permission handler
  final LocationPermissionHandler _locationPermissionHandler =
      LocationPermissionHandler();
  bool _locationPermissionChecked = false;

  // Workout metrics
  double distance = 0.0; // Start with 0
  Duration duration = const Duration(seconds: 0); // Start with 0
  int calories = 0; // Start with 0
  int steps = 0; // Start with 0
  int stepsPerMinute = 0; // Start with 0
  List<double> performanceData =
      List.generate(5, (index) => 0.0); // Initialize with zeros

  // For route tracking
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  List<Polyline> polylines = [];

  final Color primaryGreen = const Color(0xFF4CB9A0);

  @override
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

    // Fetch user profile
    _loadUserProfile();

    // Check location permission status initially
    _checkLocationPermission();

    // Initialize map data
    _initializeMapData();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Coba ambil dari local storage terlebih dahulu
      String? storedName = await AuthHelper.getUserName();
      String? storedProfilePic = await AuthHelper.getProfilePicture();

      setState(() {
        _userName = storedName ?? "User";
        _profileImageUrl = storedProfilePic;
      });

      // Pastikan Anda sudah menambahkan import http dan dart:convert
      final token = await AuthHelper.getToken();
      if (token == null) return;

      final response = await http.get(
        ApiConfig.profile,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        setState(() {
          _userName = userData['username'] ?? "User";

          if (userData['profile_picture'] != null) {
            final picPath = userData['profile_picture'];
            _profileImageUrl = picPath.startsWith("http")
                ? picPath
                : "${ApiConfig.baseUrl}$picPath";
          }
        });

        // Simpan ke local storage
        await AuthHelper.saveUserName(_userName);
        if (_profileImageUrl != null) {
          await AuthHelper.saveProfilePicture(_profileImageUrl!);
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Check location permission status
  Future<void> _checkLocationPermission() async {
    bool hasPermission =
        await _locationPermissionHandler.isLocationPermissionGranted();
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
    bool hasPermission =
        await _locationPermissionHandler.requestLocationPermission(context);

    if (hasPermission) {
      // Start listening to location updates if permission is granted
      _subscribeToLocationUpdates();
    }

    return hasPermission;
  }

  // Toggle follow mode
  void _toggleFollowMode() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;

      // If enabling follow mode, immediately center the map on current location
      if (_isFollowingUser) {
        LatLng currentLocation = MapService.getCurrentLocation();
        _mapController.move(currentLocation, _mapController.camera.zoom);
      }
    });
  }

  // Method to subscribe to location updates
  void _subscribeToLocationUpdates() {
    MapService.getLiveLocationStream().listen((newLocation) {
      // Update map data with the new location, only if workout is active
      if (isWorkoutActive && !isPaused) {
        _updateMapWithNewLocation();
      }

      // If follow mode is enabled, center the map on the current location
      if (_isFollowingUser) {
        _mapController.move(newLocation, _mapController.camera.zoom);
      }

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

    // If in active tracking mode, center the map on the current location if following is enabled
    if (isWorkoutActive && currentStep == 1 && _isFollowingUser) {
      _mapController.move(
          MapService.getCurrentLocation(), _mapController.camera.zoom);
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
            content: Text(
                'Aplikasi memerlukan izin lokasi untuk melacak aktivitas bersepeda Anda'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (!isWorkoutActive) {
      // Reset route history and start session when GO is pressed
      MapService.startSession();

      setState(() {
        isWorkoutActive = true;
        isPaused = false;
        currentStep = 1; // Move to workout tracking screen

        // Reset performance data
        performanceData = List.generate(5, (index) => 0.0);
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

      // Tell MapService tracking is paused
      MapService.setPaused(true);
    }
  }

  void resumeWorkout() {
    if (isWorkoutActive && isPaused) {
      setState(() {
        isPaused = false;
      });
      _startTimer();

      // Tell MapService tracking is resumed
      MapService.setPaused(false);
    }
  }

  void stopWorkout() async {
    _timer?.cancel();
    MapService.stopSession();

    // Hitung kecepatan rata-rata
    double avgSpeed = distance > 0 ? distance / (duration.inSeconds / 3600) : 0;

    // Contoh sederhana untuk max speed (bisa ditingkatkan)
    double maxSpeed = avgSpeed * 1.2;

    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan login ulang'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      // Gunakan CyclingService untuk menyimpan aktivitas
      bool saved = await CyclingService().saveCyclingActivity(
        date: DateTime.now(),
        durationSeconds: duration.inSeconds,
        distanceKm: distance,
        avgSpeedKmh: avgSpeed,
        maxSpeedKmh: maxSpeed,
        // Opsional: tambahkan elevation gain jika memungkinkan
        elevationGainM: 0, duration: duration,
      );

      if (saved && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aktivitas bersepeda berhasil disimpan'),
            backgroundColor: primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (!saved && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan aktivitas bersepeda'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() {
        isWorkoutActive = false;
        isPaused = false;
        currentStep = 2;
      });
    }
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
        totalDistance += _calculateDistance(routePoints[i - 1], routePoints[i]);
      }
    }

    // For cycling, we don't really count steps but rather pedal strokes
    // Using a cadence of about 80 rpm for average cycling
    final strokesToCount = 85.0 / 60.0; // strokes per second
    final newStepsCount = steps + strokesToCount.round();

    final caloriesPerSecond = 500.0 / 3600.0;
    final newCalories = (newDuration.inSeconds * caloriesPerSecond).round();

    // Update steps (pedal strokes) per minute
    stepsPerMinute = 80; // Common cycling cadence

    // Update performance data for pace graph
    double currentPace = 0;
    if (isWorkoutActive && currentStep == 1 && totalDistance > 0) {
      currentPace = newDuration.inSeconds / 60 / totalDistance;
      // Normalize around the standard 5 min/km pace
      currentPace = math.min(
          currentPace / 5.0, 1.0); // Changed to normalize against 5 min/km

      for (int i = 0; i < performanceData.length - 1; i++) {
        performanceData[i] = performanceData[i + 1];
      }
      performanceData[performanceData.length - 1] = currentPace;
    }

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
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
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
    double standardizedPace = 5.0;
    double paceVariation = (pacePerKm / standardizedPace - 1.0) *
        0.25; // 25% variance based on actual pace
    double displayPace = standardizedPace * (1 + paceVariation);

    // Format pace as minutes and seconds
    int paceWholeMinutes = pacePerKm.floor();
    int paceSeconds = ((pacePerKm - paceWholeMinutes) * 60).round();
    if (paceSeconds >= 60) {
      paceWholeMinutes += 1;
      paceSeconds -= 60;
    }

    return "$paceWholeMinutes'${paceSeconds.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
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
        return CyclingTimestamp(
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
        return CyclingSummary(
          distance: distance,
          formattedDuration: formattedDuration,
          formattedPace: formattedPace,
          calories: calories,
          steps: steps,
          routePoints: routePoints,
          markers: markers,
          polylines: polylines,
          primaryGreen: primaryGreen,
          duration: duration,
          onBackToHome: () {
            setState(() {
              currentStep = 0; // Back to initial screen

              // Reset workout metrics
              distance = 0.0;
              duration = const Duration(seconds: 0);
              calories = 0;
              steps = 0;
              stepsPerMinute = 0;
              performanceData = List.generate(5, (index) => 0.0);
            });
          },
        );
      default:
        return _buildInitialScreen();
    }
  }

  Widget _buildInitialScreen() {
    // Removed Scaffold here as requested
    return Column(
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
                        'Hi, $_userName!',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : const AssetImage(
                                    'assets/images/profilepicture.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey[300],
                      ),
                    ],
                  ),
                ),

                // Distance and weather
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CyclingHistoryScreen(),
                      ),
                    );
                  },
                  splashColor:
                      primaryGreen.withOpacity(0.1), // Add splash effect
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
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
                              '0.00 KM', // Always start with 0.00 in initial screen
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
                ),

                // Workout type selector
                WorkoutNavbar(
                  currentWorkoutType: 'Cycling',
                  onWorkoutTypeChanged: (newType) {
                    // Pass the type change to the parent
                    if (widget.onWorkoutTypeChanged != null) {
                      widget.onWorkoutTypeChanged!(newType);
                    }
                  },
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
                          child: Icon(Icons.question_mark,
                              color: Colors.white, size: 10),
                        ),
                      ],
                    ),
                  ),
                ),

                // Map display with follow me button
                Expanded(
                  child: Stack(
                    children: [
                      Container(
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: MapService
                                  .defaultCenter, // Use default center initially
                              initialZoom: 15,
                              // Add interactiveFlags to prevent bounds error
                              interactionOptions: const InteractionOptions(
                                enableMultiFingerGestureRace: true,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              // Always include at least one valid point in polylines
                              PolylineLayer(
                                polylines: polylines.isEmpty
                                    ? [
                                        Polyline(
                                          points: [
                                            MapService.defaultCenter
                                          ], // Include default center
                                          color: Colors
                                              .transparent, // Make it invisible initially
                                          strokeWidth: 0,
                                        ),
                                      ]
                                    : polylines,
                              ),
                              MarkerLayer(
                                markers: markers.isEmpty
                                    ? [
                                        Marker(
                                          point: MapService.defaultCenter,
                                          width: 60,
                                          height: 60,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.blue.withOpacity(0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.location_on,
                                                color: Colors.blue,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                    : markers,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Follow Me Button
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: FollowMeButton(
                          isFollowing: _isFollowingUser,
                          onPressed: _toggleFollowMode,
                          activeColor: primaryGreen,
                        ),
                      ),
                    ],
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
                    await _locationPermissionHandler
                        .showLocationServicesDisabledDialog(context);
                  }
                  return;
                }

                // If permission granted, proceed with countdown and workout
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WorkoutCountdown(
                        onCountdownComplete: () {
                          Navigator.of(context)
                              .pop(); // Pop the countdown screen
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
      ],
    );
  }
}
