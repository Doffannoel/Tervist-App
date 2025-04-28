import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:tervist_apk/api/running_service.dart';
import 'package:tervist_apk/models/running_history_model.dart';
import 'package:tervist_apk/screens/workout/running/running_summary.dart';

class RunningHistoryScreen extends StatefulWidget {
  const RunningHistoryScreen({super.key});

  @override
  State<RunningHistoryScreen> createState() => _RunningHistoryScreenState();
}

class _RunningHistoryScreenState extends State<RunningHistoryScreen> {
  final Color primaryGreen = const Color(0xFF4CB9A0);
  final Color lightMintGreen = const Color(0xFFF1F7F6);

  final RunningService _runningService = RunningService();

  // State variables
  bool _isLoading = true;
  String _errorMessage = '';
  RunningHistoryModel? _historyData;
  String _userName = "User";
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // First get user profile
      final userProfile = await _runningService.getUserProfile();

      // Then get running history
      final historyData = await _runningService.getRunningHistory();

      setState(() {
        _userName = userProfile['username'] ?? 'User';
        _profileImageUrl = userProfile['profileImageUrl'];
        _historyData = historyData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToRunningSummary(int activityId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch the detailed activity data
      final activityData = await _runningService.getRunningDetail(activityId);

      // Extract data
      final distance = (activityData['distance_km'] ?? 0).toDouble();
      final timeSeconds = activityData['time_seconds'] ?? 0;
      final pace = (activityData['pace'] ?? 0).toDouble();
      final calories = activityData['calories_burned'] ?? 0;
      final steps = activityData['steps'] ?? 0;

      // Format duration
      final duration = Duration(seconds: timeSeconds);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      final seconds = duration.inSeconds % 60;
      final formattedDuration =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      // Format pace (minutes per km)
      final paceMinutes = pace.floor();
      final paceSeconds = ((pace - paceMinutes) * 60).floor();
      final formattedPace =
          "$paceMinutes'${paceSeconds.toString().padLeft(2, '0')}\"";

      // Parse route_data (can be string or list)
      final rawRouteData = activityData['route_data'];
      final routeData = rawRouteData is String
          ? jsonDecode(rawRouteData)
          : (rawRouteData ?? []);

      // Clean routePoints
      final routePoints =
          (routeData as List).map((e) => LatLng(e['lat'], e['lng'])).toList();

      // (Optional) Generate default markers and polyline if needed
      final markers = routePoints.isNotEmpty
          ? [
              Marker(
                point: routePoints.first,
                width: 60,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Marker(
                point: routePoints.last,
                width: 60,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.flag,
                      color: primaryGreen,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ]
          : [];

      final polylines = routePoints.isNotEmpty
          ? [
              Polyline(
                points: routePoints,
                color: primaryGreen,
                strokeWidth: 5,
              )
            ]
          : [];

      setState(() {
        _isLoading = false;
      });

      // Navigate to the summary screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RunningSummary(
            distance: distance,
            formattedDuration: formattedDuration,
            formattedPace: formattedPace,
            calories: calories,
            steps: steps,
            routePoints: routePoints,
            routeData: routeData,
            markers: markers.cast<Marker>(),
            polylines: polylines.cast<Polyline<Object>>(),
            primaryGreen: primaryGreen,
            onBackToHome: () => Navigator.pop(context),
            duration: duration,
            userName: _userName,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load activity details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightMintGreen,
      body: Stack(
        children: [
          SafeArea(
            child: _isLoading && _historyData == null
                ? _buildLoadingView()
                : _errorMessage.isNotEmpty
                    ? _buildErrorView()
                    : _buildContentView(),
          ),
          // Show loading overlay when navigating to detail
          if (_isLoading && _historyData != null) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    if (!_isLoading) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _loadData();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    if (_historyData == null) {
      return Center(child: Text('No data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button and title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              // Back button with different style
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                ),
              ),

              // Title moved to left side
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $_userName !',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Here\'s your running history',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Profile image
              CircleAvatar(
                radius: 20,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : const AssetImage('assets/images/profile.png')
                        as ImageProvider,
                backgroundColor: Colors.grey[300],
              ),
            ],
          ),
        ),

        // Started date
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Started ${DateFormat('MMM dd, yyyy').format(_historyData!.startDate)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),

        // Summary card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary heading
                  Text(
                    'Summary...',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Workouts count
                  Text(
                    '${_historyData!.totalWorkouts} Workouts',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const Divider(height: 24, thickness: 1),

                  // Time
                  Text(
                    'Time',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _historyData!.formatTotalDuration(),
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Distance and Calories in row
                  Row(
                    children: [
                      // Distance
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distance',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _historyData!.totalDistance
                                      .toString()
                                      .replaceAll('.', ','),
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Km',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Calories
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calories',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${_historyData!.totalCalories}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Kcal',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Records heading
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            'Records',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Records list
        Expanded(
          child: _historyData!.records.isEmpty
              ? Center(
                  child: Text(
                    'No running records yet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _historyData!.records.length,
                  itemBuilder: (context, index) {
                    final record = _historyData!.records[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildRecordCard(record),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(RunningRecord record) {
    return InkWell(
      onTap: () => _navigateToRunningSummary(record.id),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Clock icon in a circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/iconhistory.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.access_time,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Distance information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "${record.distance}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' Km',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Date with icon
              Row(
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(record.date),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 16,
                    height: 16,
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
