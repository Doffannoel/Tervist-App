import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../follow_me_button.dart';
import '../share_screen.dart';
import '/api/auth_helper.dart'; // Import for user data
import 'package:intl/intl.dart'; // Import for date formatting
import '../pace_statistics_widget.dart'; // Import widget pace statistics
import 'package:cached_network_image/cached_network_image.dart'; 

class RunningSummary extends StatefulWidget {
  final double distance;
  final String formattedDuration;
  final String formattedPace;
  final int calories;
  final int steps;
  final List<LatLng> routePoints;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final Color primaryGreen;
  final VoidCallback onBackToHome;
  final Duration duration;
  final String userName; // Add username parameter

  const RunningSummary({
    super.key,
    required this.distance,
    required this.formattedDuration,
    required this.formattedPace,
    required this.calories,
    required this.steps,
    required this.routePoints,
    required this.markers,
    required this.polylines,
    required this.primaryGreen,
    required this.onBackToHome,
    required this.duration,
    this.userName = "User", // Default to "User" if not provided
  });

  @override
  State<RunningSummary> createState() => _RunningSummaryState();
}

class _RunningSummaryState extends State<RunningSummary> {
  final MapController _mapController = MapController();
  bool _isFollowingUser = true; // Default state for the follow button
  String _userName = "User"; // Default username
  final DateTime _currentDateTime = DateTime.now(); // Current date and time
  bool _isLoading = true;
  String? _profileImageUrl; // Add profile image URL

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data if needed
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // If username is provided in widget, use it
      if (widget.userName.isNotEmpty && widget.userName != "User") {
        setState(() {
          _userName = widget.userName;
        });
      } else {
        // Otherwise try to get it from AuthHelper
        String? storedName = await AuthHelper.getUserName();
        if (storedName != null && storedName.isNotEmpty) {
          setState(() {
            _userName = storedName;
          });
        }
      }
      // Get profile image URL from AuthHelper
      String? imageUrl = await AuthHelper.getProfilePicture();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        setState(() {
          _profileImageUrl = imageUrl;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  LatLng _calculateMapCenter() {
    if (widget.routePoints.isEmpty) {
      return const LatLng(-7.767, 110.378); // Default center
    }

    double latSum = 0;
    double lngSum = 0;

    for (var point in widget.routePoints) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }

    return LatLng(
      latSum / widget.routePoints.length,
      lngSum / widget.routePoints.length,
    );
  }

  // Toggle follow mode - In summary view this centers on the route
  void _toggleFollowMode() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;

      // If enabling follow mode, center the map on the route
      if (_isFollowingUser) {
        _mapController.move(_calculateMapCenter(), _mapController.camera.zoom);
      }
    });
  }

  // Generate random pace data for use with PaceStatisticsWidget
  List<Map<String, dynamic>> _generateRandomPaceData() {
    if (widget.distance <= 0) {
      return []; // Empty list for zero distance
    }
    
    // Base pace for running activity (km/h)
    double basePace = 10.0;
    
    // Determine number of kilometers to display (up to 7 max)
    int totalKm = widget.distance < 1 ? 1 : widget.distance.floor();
    totalKm = math.min(totalKm, 7); // Max 7 km for visualization
    
    // Random generator
    final random = math.Random();
    
    List<Map<String, dynamic>> paceData = [];
    
    // Generate random pace data for each kilometer
    for (int i = 1; i <= totalKm; i++) {
      // Random variation of ±30% from base pace
      double randomVariation = 0.7 + (0.6 * random.nextDouble());
      double adjustedPace = basePace * randomVariation;
      
      paceData.add({
        'km': i,
        'pace': adjustedPace.round(),
      });
    }
    
    return paceData;
  }

  @override
  Widget build(BuildContext context) {
    // Format date and time
    String formattedDate = DateFormat('dd/MM/yyyy').format(_currentDateTime);
    String formattedTime = DateFormat('HH:mm').format(_currentDateTime);

    // Generate random pace data for the PaceStatisticsWidget
    final List<Map<String, dynamic>> paceData = _generateRandomPaceData();

    // Ensure we have valid polylines even if empty
    final List<Polyline> displayPolylines =
        widget.polylines.isEmpty || widget.routePoints.isEmpty
            ? [
                Polyline(
                  points: [
                    const LatLng(-7.767, 110.378)
                  ], // Use default point if empty
                  color: Colors.transparent,
                  strokeWidth: 0,
                )
              ]
            : widget.polylines;

    // Ensure we have valid markers even if empty
    final List<Marker> displayMarkers = widget.markers.isEmpty
        ? [
            Marker(
              point: const LatLng(-7.767, 110.378),
              width: 80,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
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
            )
          ]
        : widget.markers;

    return Scaffold(
      // Keep the original light mint green background
      backgroundColor: const Color(0xFFF1F7F6),
      // Removing AppBar to use custom buttons like in cycling_summary
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spacer for the top buttons
                  const SizedBox(height: 60),

                  // Map container instead of treadmill image
                  Container(
                    width: double.infinity,
                    height: 500,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Stack(
                        children: [
                          // Map with completed route
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _calculateMapCenter(),
                              initialZoom: 14,
                              interactionOptions: const InteractionOptions(
                                enableMultiFingerGestureRace: true,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.running_app',
                              ),
                              PolylineLayer(
                                polylines: displayPolylines,
                              ),
                              MarkerLayer(
                                markers: displayMarkers,
                              ),
                            ],
                          ),

                          // Follow me button
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FollowMeButton(
                              isFollowing: _isFollowingUser,
                              onPressed: _toggleFollowMode,
                              activeColor: widget.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tervist | Outdoor Running text
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Tervist | Outdoor Running',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  // Primary workout stats card - changed to pure white background
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Distance and user info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Distance with larger font
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    widget.distance.toStringAsFixed(2),
                                    style: GoogleFonts.poppins(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Km',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // User info with profile image
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _isLoading
                                      ? Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              widget.primaryGreen,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: _profileImageUrl != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: CachedNetworkImage(
                                                    imageUrl: _profileImageUrl!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        widget.primaryGreen,
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/profile.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/images/profile.png',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                  const SizedBox(height: 4),
                                  _isLoading
                                      ? SizedBox(
                                          width: 50,
                                          height: 10,
                                          child: LinearProgressIndicator(
                                            backgroundColor: Colors.grey[200],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    widget.primaryGreen),
                                          ),
                                        )
                                      : Text(
                                          _userName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                  Text(
                                    '$formattedDate $formattedTime',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Time and Pace
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Time column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.formattedDuration,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Time',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                              // Pace column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.formattedPace,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Pace',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Two-column layout for Calories and Steps - changed to pure white background
                  Row(
                    children: [
                      // Calories card
                      Expanded(
                        child: Card(
                          elevation: 2,
                          color: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(right: 8, bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Calories title with icon
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      color: Colors.orange[400],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    // Using Flexible to prevent overflow
                                    Flexible(
                                      child: Text(
                                        'Calories Burned',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Calories value
                                Row(
                                  children: [
                                    Text(
                                      '${widget.calories}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[400],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Kcal',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Steps card
                      Expanded(
                        child: Card(
                          elevation: 2,
                          color: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Steps title with icon
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/stepicon.png',
                                      color: widget.primaryGreen,
                                      width: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    // Using Flexible to prevent overflow
                                    Flexible(
                                      child: Text(
                                        'Steps',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Steps value
                                Text(
                                  '${widget.steps}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Pace statistics chart - now using randomly generated pace data
                  Card(
                    elevation: 2,
                    color: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 24.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PaceStatisticsWidget(
                        activityType: 'Running',
                        paceData: paceData,
                        primaryColor: widget.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom back and share buttons at the top - added from cycling summary
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                InkWell(
                  onTap: widget.onBackToHome,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),

                // Share button - using the style from cycling summary
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShareScreen(
                          distance: widget.distance,
                          formattedDuration: widget.formattedDuration,
                          formattedPace: widget.formattedPace,
                          calories: widget.calories,
                          steps: widget.steps,
                          activityType: 'Outdoor Running',
                          workoutDate: _currentDateTime,
                          userName: _userName,
                          routePoints: widget.routePoints,
                          polylines: widget.polylines,
                          markers: widget.markers,
                          profileImageUrl: _profileImageUrl
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/sharebutton.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}