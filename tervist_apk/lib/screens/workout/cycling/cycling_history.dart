import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:tervist_apk/screens/workout/cycling/cycling_history_service.dart';
import 'package:tervist_apk/models/cycling_history_model.dart';
import 'package:tervist_apk/screens/workout/cycling/cycling_summary.dart';
import 'package:tervist_apk/screens/workout/map_service.dart';

class CyclingHistoryScreen extends StatefulWidget {
  const CyclingHistoryScreen({super.key});

  @override
  State<CyclingHistoryScreen> createState() => _CyclingHistoryScreenState();
}

class _CyclingHistoryScreenState extends State<CyclingHistoryScreen> {
  final Color primaryGreen = const Color(0xFF4CB9A0);
  final Color lightMintGreen = const Color(0xFFF1F7F6);

  final CyclingHistoryService _cyclingService = CyclingHistoryService();

  // State variables
  bool _isLoading = true;
  String _errorMessage = '';
  CyclingHistoryModel? _historyData;
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
      final userProfile = await _cyclingService.getUserProfile();

      // Then get cycling history
      final historyData = await _cyclingService.getCyclingHistory();

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

  Future<void> _navigateToCyclingSummary(CyclingRecord record) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil data langsung dari record yang sudah ada
      final distance = record.distance;
      final timeSeconds = record.timeSeconds;
      final avgSpeed = record.avgSpeed;
      final maxSpeed = record.maxSpeed;
      final calories = record.calories;
      List<dynamic> routeData = record.routeData;

      // Log route data information for debugging
      print('📊 RouteData type: ${routeData.runtimeType}');
      print('📊 RouteData is List, length: ${routeData.length}');

      // If routeData is empty, try to fetch detailed activity data
      if (routeData.isEmpty) {
        try {
          print('🔍 RouteData is empty, fetching detailed activity data...');
          final detailedData =
              await _cyclingService.getCyclingActivityDetail(record.id);
          print(
              '🔍 Detailed data received: ${detailedData.containsKey('route_data')}');

          if (detailedData.containsKey('route_data')) {
            var fetchedRouteData = detailedData['route_data'];
            if (fetchedRouteData is String) {
              routeData = json.decode(fetchedRouteData);
            } else if (fetchedRouteData is List) {
              routeData = fetchedRouteData;
            }
            print('🔍 Fetched route data length: ${routeData.length}');
          }
        } catch (e) {
          print('❌ Failed to fetch detailed activity data: $e');
        }
      }

      // Format durasi
      final duration = Duration(seconds: timeSeconds);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      final seconds = duration.inSeconds % 60;
      final formattedDuration =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      // Format pace (speed in km/h)
      final formattedPace = '${avgSpeed.toStringAsFixed(1)} km/h';

      // If route data is still empty after fetching, create fallback route data
      if (routeData.isEmpty) {
        print(
            '⚠️ Still no route data, creating fallback route data near user location...');
        // Get user's current location as a fallback
        final currentLocation = await MapService.getCurrentLocationAsync();
        if (currentLocation != null) {
          // Create a small route around the current location
          routeData = [
            {
              "latitude": currentLocation.latitude,
              "longitude": currentLocation.longitude
            },
            {
              "latitude": currentLocation.latitude + 0.001,
              "longitude": currentLocation.longitude + 0.001
            },
            {
              "latitude": currentLocation.latitude + 0.001,
              "longitude": currentLocation.longitude - 0.001
            },
          ];
          print(
              '🔍 Created fallback route data with ${routeData.length} points');
        }
      }

      // Process route points
      List<LatLng> routePoints = [];
      if (routeData.isNotEmpty) {
        try {
          routePoints = routeData
              .map<LatLng>((point) {
                if (point is Map) {
                  final double? lat =
                      (point['lat'] ?? point['latitude'])?.toDouble();
                  final double? lng =
                      (point['lng'] ?? point['longitude'])?.toDouble();

                  if (lat != null && lng != null) {
                    return LatLng(lat, lng);
                  }
                }
                throw Exception('Invalid route point data');
              })
              .where((point) => point != null)
              .cast<LatLng>()
              .toList();

          print('🧭 Processed route points count: ${routePoints.length}');
          if (routePoints.isNotEmpty) {
            print(
                '🧭 First point: ${routePoints.first.latitude}, ${routePoints.first.longitude}');
            print(
                '🧭 Last point: ${routePoints.last.latitude}, ${routePoints.last.longitude}');
          }
        } catch (e) {
          print('❌ Error processing route data: $e');
        }
      }

      // Create a polyline from route points
      List<Polyline> polylines = [];
      if (routePoints.isNotEmpty) {
        polylines = [
          Polyline(
            points: routePoints,
            color: primaryGreen,
            strokeWidth: 4.0,
          ),
        ];
        print('🟢 Created polyline with ${routePoints.length} points');
      } else {
        print('⚠️ No route points available to create polylines');
      }

      // Create markers for start and end
      List<Marker> markers = [];
      if (routePoints.isNotEmpty) {
        // Start marker
        markers.add(
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
        );

        // End marker
        markers.add(
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
        );
        print('🟢 Created start and end markers');
      } else {
        print('⚠️ No route points available to create markers');
      }

      setState(() {
        _isLoading = false;
      });

      // Navigasi ke halaman summary with polylines and markers
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CyclingSummary(
            distance: distance,
            formattedDuration: formattedDuration,
            formattedPace: formattedPace,
            calories: calories,
            steps: maxSpeed.toInt(), // Gunakan maxSpeed sebagai "steps"
            routePoints: routePoints, // Kirim route data yang valid
            markers: markers, // Pass the created markers
            polylines: polylines, // Pass the created polylines
            primaryGreen: primaryGreen,
            duration: duration,
            onBackToHome: () => Navigator.pop(context),
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
      return Center(
          child: Text('No data available', style: GoogleFonts.poppins()));
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
                    'Here\'s your cycling history',
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

                  // Distance and Average Speed in row
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

                      // Average Speed
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Avg Speed',
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
                                  _historyData!.avgSpeed.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'km/h',
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

                  // Calories
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Calories',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_historyData!.totalCalories} Kcal',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                    'No cycling records yet',
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

  Widget _buildRecordCard(CyclingRecord record) {
    return InkWell(
      onTap: () => _navigateToCyclingSummary(record),
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
              // Cycling icon in a circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/cycling_icon.png', // You'll need to add this asset
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.directions_bike,
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
                          record.distance.toStringAsFixed(2),
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
