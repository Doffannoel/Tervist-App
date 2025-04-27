import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/main.dart';
import 'package:tervist_apk/screens/login/signup_screen.dart';
import 'running_timestamp.dart';
import 'running_summary.dart';
import 'running_history.dart'; // Import the RunningHistoryScreen
import '../map_service.dart';
import '../workout_countdown.dart';
import '../workout_navbar.dart';
import 'package:flutter/scheduler.dart'; // Import for Ticker
import '../location_permission_handler.dart'; // Import the permission handler
import '../follow_me_button.dart'; // Import the follow me button widget
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../weather_service.dart';
import '/api/running_service.dart';

import 'package:tervist_apk/api/auth_helper.dart';

class RunningTrackerScreen extends StatefulWidget {
  final Function(String)? onWorkoutTypeChanged;

  const RunningTrackerScreen({
    super.key,
    this.onWorkoutTypeChanged,
  });

  @override
  State<RunningTrackerScreen> createState() => _RunningTrackerScreenState();
}

class _RunningTrackerScreenState extends State<RunningTrackerScreen>
    with SingleTickerProviderStateMixin {
  int currentStep = 0; // 0: initial, 1: workout tracking, 2: summary
  bool isWorkoutActive = false;
  bool isPaused = false;
  Timer? _timer;
  Ticker? _ticker; // Ticker for more efficient updates
  MapController? _mapController;

  // Follow me button state
  bool _isFollowingUser = true; // Enable follow mode by default

  // Cache for UI updates to prevent rebuilds
  bool _needsUpdate = false;

  // Location permission handler
  final LocationPermissionHandler _locationPermissionHandler =
      LocationPermissionHandler();
  bool _locationPermissionChecked = false;

  // User profile info
  String _userName = "User"; // Default value until loaded
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _profileImageUrl;

  // Workout metrics
  double distance = 0.0; // Start with 0
  Duration duration = const Duration(seconds: 0); // Start with 0
  int calories = 0; // Start with 0
  int steps = 0; // Start with 0
  int stepsPerMinute = 0; // Start with 0
  List<double> performanceData =
      List.generate(5, (index) => 0.0); // Initialize with zeros

  double _calculateCalories({
    required double weightKg,
    required double durationSeconds,
    double met = 7.0, // Updated MET value for running (from 5.0)
  }) {
    if (durationSeconds <= 0 || weightKg <= 0) return 1;

    double durationMinutes = durationSeconds / 60.0;

    // Rumus MET standard: (MET × Berat × 3.5) / 200 × waktu (menit)
    double calories = ((met * weightKg * 3.5) / 200) * durationMinutes;

    return calories.roundToDouble();
  }

  // For route tracking
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  List<Polyline> polylines = [];

  final Color primaryGreen = const Color(0xFF4CB9A0); // Temperature value

  final RunningService _runningService = RunningService();

  void main() {
    // Catch Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      print('Flutter error caught: ${details.exception}');
      print('Stack trace: ${details.stack}');
    };

    // Catch Dart errors
    runZonedGuarded(() {
      runApp(MyApp());
    }, (Object error, StackTrace stack) {
      print('Dart error caught: $error');
      print('Stack trace: $stack');
    });
  }

  void stopWorkout() async {
    try {
      _timer?.cancel();
      MapService.stopSession();

      double paceMinutes = 0;
      if (distance > 0) {
        paceMinutes = duration.inSeconds / 60 / distance;
      }

      bool isAuthenticated = await AuthHelper.isLoggedIn();

      if (!isAuthenticated) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication error - please log in again'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final fullRoutePoints = MapService.getRouteHistory();

      print('🗺 Total Route Points: ${fullRoutePoints.length}');

      // Ubah ke format JSON
      final routeJson = jsonEncode(fullRoutePoints
          .map((point) => {
                'lat': point.latitude.toDouble(),
                'lng': point.longitude.toDouble(),
              })
          .toList());

      if (fullRoutePoints.length < 2) {
        print('⚠ Rute terlalu pendek, tidak disimpan.');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rute terlalu pendek, coba gerak lebih jauh.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      print('💾 Saving running activity:');
      print('- Distance: $distance km');
      print('- Duration: ${duration.inSeconds} seconds');
      print('- Pace: $paceMinutes min/km');
      print('- Calories: $calories');
      print('- Steps: $steps');
      print('- Route Points: ${routeJson.length}');
      print('📦 Route JSON: $routeJson');

      final saved = await _runningService.saveRunningActivity(
        distanceKm: distance,
        timeSeconds: duration.inSeconds,
        pace: paceMinutes,
        caloriesBurned: calories,
        steps: steps,
        date: DateTime.now(),
        routeData: routeJson,
      );

      if (saved && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aktivitas lari berhasil disimpan'),
            backgroundColor: primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('🚨 Error saving activity: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan aktivitas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isWorkoutActive = false;
        isPaused = false;
        currentStep = 2;
      });

      MapService.stopLocationUpdates();
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // ⬅ Tambahin ini
    _checkAuthentication();
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

    // Load user profile
    _loadUserProfile();
  }

  Future<void> _checkAuthentication() async {
    try {
      final token =
          await AuthHelper.getToken(); // ambil token dari SharedPreferences

      if (token == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthPage()),
          );
        }
        return;
      }

      // panggil endpoint /auth/profile/ buat verifikasi token valid
      try {
        final response = await http.get(
          ApiConfig.profile,
          headers: {
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10)); // Add timeout

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          if (mounted) {
            setState(() {
              _userName = userData['username']; // tampilkan nama beneran
              _isLoggedIn = true; // Set login state to true
            });
          }
        } else {
          print('Authentication failed with status: ${response.statusCode}');
          await AuthHelper.clearAuthData();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthPage()),
          );
        }
      } catch (e) {
        print('API request error: $e');
        // Don't redirect on network errors, just log them
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection error: $e'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Authentication error: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while checking authentication'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  double _userWeight = 60.0; // Default berat kalau backend belum kirim

// Load user profile data including username dan berat badan
  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      bool isLoggedIn = await AuthHelper.isLoggedIn();

      if (!isLoggedIn) {
        if (!mounted) return;
        setState(() {
          _isLoggedIn = false;
          _userName = "Guest";
        });
        return;
      }

      // 1. Coba ambil dari local (cache)
      String? storedName = await AuthHelper.getUserName();
      String? storedProfile = await AuthHelper.getProfilePicture();

      if (!mounted) return;
      setState(() {
        _userName = storedName ?? "User";
        _profileImageUrl = storedProfile;
        _isLoggedIn = true;
      });

      // 2. Tetap fetch dari API buat update terbaru
      final token = await AuthHelper.getToken();
      final response = await http.get(
        ApiConfig.profile,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        if (!mounted) return;
        setState(() {
          _userName = userData['username'] ?? "User";

          if (userData['weight'] != null) {
            _userWeight =
                double.tryParse(userData['weight'].toString()) ?? 60.0;
          }

          if (userData['profile_picture'] != null) {
            final picPath = userData['profile_picture'];
            // Gabungin kalau cuma path
            if (picPath.startsWith("http")) {
              _profileImageUrl = picPath;
            } else {
              _profileImageUrl = "${ApiConfig.baseUrl}$picPath";
            }

            AuthHelper.saveProfilePicture(_profileImageUrl!);
          }
        });

        await AuthHelper.saveUserName(_userName);
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Check location permission status
  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      _locationPermissionChecked = true;
      _subscribeToLocationUpdates();
    } else {
      print('❌ Lokasi belum diizinkan oleh user');
      // Bisa tampilkan dialog atau toast kalau mau
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
        LatLng? currentLocation = MapService.getCurrentLocation();
        _mapController?.move(
            currentLocation, _mapController?.camera.zoom ?? 15.0);
      }
    });
  }

  // Method to subscribe to location updates
  void _subscribeToLocationUpdates() {
    MapService.getLiveLocationStream().listen((newLocation) {
      print("🌍 New Location: $newLocation");
      print("🏃 Workout Active: $isWorkoutActive");
      print("🏃 Not Paused: ${!isPaused}");
      if (isWorkoutActive && !isPaused) {
        // Cek apakah titik terakhir sudah cukup jauh sebelum dianggap sebagai "gerak"
        if (routePoints.isEmpty ||
            _calculateDistance(routePoints.last, newLocation) > 0.003) {
          _updateMapWithNewLocation();
        }
      }

      if (_isFollowingUser) {
        _mapController?.move(newLocation, _mapController?.camera.zoom ?? 15.0);
      }

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
    print("Tracking Route Points: ${routePoints.length}");

    // If in active tracking mode, center the map on the current location if following is enabled
    if (isWorkoutActive && currentStep == 1 && _isFollowingUser) {
      _mapController?.move(
          MapService.getCurrentLocation(), _mapController!.camera.zoom);
    }
  }

  Future<void> _initializeMapData() async {
    try {
      final mapData = await MapService.getInitialMapData();
      if (mounted) {
        setState(() {
          routePoints = mapData.routePoints;
          markers = mapData.markers;
          polylines = mapData.polylines;
        });
      }
    } catch (e, stack) {
      print('Error initializing map: $e');
      print('Stack trace: $stack');
      // Continue without map data
      if (mounted) {
        setState(() {
          // Set default empty values
          routePoints = [];
          markers = [];
          polylines = [];
        });
      }
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
    // First check authentication
    bool isLoggedIn = await AuthHelper.isLoggedIn();
    if (!isLoggedIn) {
      // Show login required message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to track your running activity'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    bool hasPermission = await _requestLocationPermission();

    if (!hasPermission) {
      // Show snackbar if permission is not granted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Aplikasi memerlukan izin lokasi untuk melacak aktivitas lari Anda'),
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
      for (int i = 1; i < routePoints.length; i++) {
        totalDistance += _calculateDistance(routePoints[i - 1], routePoints[i]);
      }
    }

    // Steps calculation (about 180 steps per minute for running at 6 min/km pace)
    final stepsPerSecond = 180.0 / 60.0; // Updated from 160.0 / 60.0
    final newStepsCount = steps + stepsPerSecond.round();

    // Calories calculation for running at 6 min/km pace (approx 700 calories per hour)
    final caloriesPerSecond = 700.0 / 3600.0; // Updated from 600.0 / 3600.0
    final newCalories = (newDuration.inSeconds * caloriesPerSecond).round();

    // Update performance data for pace graph
    double currentPace = 0;
    if (isWorkoutActive && currentStep == 1 && totalDistance > 0) {
      currentPace = newDuration.inSeconds / 60 / totalDistance;
      // Normalize around the standard 6 min/km pace
      currentPace = math.min(currentPace / 6.0, 1.0);

      for (int i = 0; i < performanceData.length - 1; i++) {
        performanceData[i] = performanceData[i + 1];
      }
      performanceData[performanceData.length - 1] = currentPace;
    }

    // ⛑ Pastikan widget masih mounted sebelum update state
    if (!mounted) return;

    setState(() {
      duration = newDuration;
      steps = newStepsCount;
      distance = totalDistance;
      stepsPerMinute = 180; // Updated from 160
      double userWeight = _userWeight;
      calories = _calculateCalories(
        weightKg: userWeight,
        durationSeconds: newDuration.inSeconds.toDouble(),
      ).toInt();
    });
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

    // Apply standardized pace adjustment based on activity type
    // For running, we standardize to 6 min/km when calculating displayed pace
    double standardizedPace = 6.0;

    // Apply variation based on actual pace - keep some real-world variance
    // This creates a more realistic pace that fluctuates around the standard
    double paceVariation = (pacePerKm / standardizedPace - 1.0) *
        0.3; // 30% variance based on actual pace
    double displayPace = standardizedPace * (1 + paceVariation);

    // Format pace as minutes and seconds
    int paceWholeMinutes = displayPace.floor();
    int paceSeconds = ((displayPace - paceWholeMinutes) * 60).round();

    // Ensure seconds don't exceed 59
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
          userName: _userName, // Pass the actual username
        );
      default:
        return _buildInitialScreen();
    }
  }

  Widget _buildInitialScreen() {
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
                      _isLoading
                          ? CircularProgressIndicator(color: primaryGreen)
                          : Text(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Distance section - Made tappable to navigate to history
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RunningHistoryScreen(),
                            ),
                          );
                        },
                        splashColor:
                            primaryGreen.withOpacity(0.1), // Add splash effect
                        borderRadius:
                            BorderRadius.circular(8), // Round the splash effect
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Column(
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
                        ),
                      ),

                      // Weather information
                      const WeatherWidget(),
                    ],
                  ),
                ),

                // Workout type selector
                WorkoutNavbar(
                  currentWorkoutType: 'Running',
                  onWorkoutTypeChanged: (newType) {
                    // Pass the type change to the parent
                    if (widget.onWorkoutTypeChanged != null) {
                      widget.onWorkoutTypeChanged!(newType);
                    }
                  },
                ),

                // Authentication status
                _isLoggedIn
                    ? Container() // Hide if logged in
                    : InkWell(
                        onTap: () {
                          // TODO: Navigate to login screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please log in to track your workouts'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 16, color: Colors.red.shade800),
                              const SizedBox(width: 8),
                              Text(
                                'Authentication required',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.question_mark,
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

        // GO button - Modified to check login and location permission
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: InkWell(
              onTap: () async {
                // First check if user is logged in
                bool isLoggedIn = await AuthHelper.isLoggedIn();
                if (!isLoggedIn) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please log in to track your running activity'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                  return;
                }

                // Then check location permission
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
