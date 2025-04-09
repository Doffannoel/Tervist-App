import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../follow_me_button.dart';
import '../share_screen.dart';

class walkingSummary extends StatefulWidget {
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

  const walkingSummary({
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
  });

  @override
  State<walkingSummary> createState() => _walkingSummaryState();
}

class _walkingSummaryState extends State<walkingSummary> {
  final MapController _mapController = MapController();
  final List<double> paceData = [0.5, 0.7, 0.4, 0.6, 0.5]; // Fixed pace data for summary
  bool _isFollowingUser = true; // Default state for the follow button

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

  // Helper method to build bar with label for pace chart
  Widget _buildBarWithLabel(String timeLabel, String kmLabel, double height) {
    return Column(
      children: [
        // Time label at top
        Text(
          timeLabel,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        // Bar
        Container(
          width: 20,
          height: height * 0.7, // Scale height
          decoration: BoxDecoration(
            color: widget.primaryGreen,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 4),
        // Km label at bottom
        Text(
          kmLabel,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure we have valid polylines even if empty
    final List<Polyline> displayPolylines = widget.polylines.isEmpty || widget.routePoints.isEmpty ? 
      [
        Polyline(
          points: [const LatLng(-7.767, 110.378)], // Use default point if empty
          color: Colors.transparent,
          strokeWidth: 0,
        )
      ] : 
      widget.polylines;
      
    // Ensure we have valid markers even if empty
    final List<Marker> displayMarkers = widget.markers.isEmpty ? 
      [
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
      ] : 
      widget.markers;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBackToHome,
        ),
        title: const Text(
          'Outdoor walking',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          // Share button
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
              ),
              child: Icon(
                Icons.share,
                color: Colors.black87,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShareScreen(
                    distance: widget.distance,
                    formattedDuration: widget.formattedDuration,
                    formattedPace: widget.formattedPace,
                    calories: widget.calories,
                    steps: widget.steps,
                    activityType: 'Outdoor Walking',
                    workoutDate: DateTime.now(),
                    userName: 'Yesaya',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map container
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
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.walking_app',
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
              
              // Tervist | Outdoor Walking text
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Tervist | Outdoor Walking',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              // Primary workout stats card
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 2,
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
                              Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/profile.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                'Yesaya',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
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
              
              // Two-column layout for Calories and Steps
              Row(
                children: [
                  // Calories card
                  Expanded(
                    child: Card(
                      elevation: 2,
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
                                Icon(
                                  Icons.directions_walk,
                                  color: widget.primaryGreen,
                                  size: 20,
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
                                color: widget.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Performance chart with updated Pace indicator
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart with labels
                      SizedBox(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBarWithLabel("20'54\"", "1", 100),
                            _buildBarWithLabel("19'32\"", "2", 90),
                            _buildBarWithLabel("22'41\"", "3", 60),
                            _buildBarWithLabel("18'12\"", "4", 130),
                            _buildBarWithLabel("21'03\"", "5", 110),
                          ],
                        ),
                      ),
                      
                      // Pace indicator at bottom right
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.directions_walk,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Pace text
                            Text(
                              'Pace',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Share Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShareScreen(
                          distance: widget.distance,
                          formattedDuration: widget.formattedDuration,
                          formattedPace: widget.formattedPace,
                          calories: widget.calories,
                          steps: widget.steps,
                          activityType: 'Outdoor Walking',
                          workoutDate: DateTime.now(),
                          userName: 'Yesaya',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}