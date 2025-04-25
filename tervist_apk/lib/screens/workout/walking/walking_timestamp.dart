import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../map_service.dart';
import '../follow_me_button.dart'; // Import the follow me button
import 'dart:async';

class walkingTimestamp extends StatefulWidget {
  final double distance;
  final String formattedDuration;
  final String formattedPace;
  final int calories;
  final List<LatLng> routePoints;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final bool isPaused;
  final Color primaryGreen;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const walkingTimestamp({
    super.key,
    required this.distance,
    required this.formattedDuration,
    required this.formattedPace,
    required this.calories,
    required this.routePoints,
    required this.markers,
    required this.polylines,
    required this.isPaused,
    required this.primaryGreen,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  State<walkingTimestamp> createState() => _walkingTimestampState();
}

class _walkingTimestampState extends State<walkingTimestamp> {
  final MapController _mapController = MapController();
  List<LatLng> currentRoutePoints = [];
  List<Marker> currentMarkers = [];
  List<Polyline> currentPolylines = [];
  LatLng? currentLocation;
  bool _isFollowingUser = true; // Start with follow mode enabled
  StreamSubscription? _locationSubscription;

  // Toggle follow mode
  void _toggleFollowMode() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;

      // If enabling follow mode, immediately center on user
      if (_isFollowingUser && currentLocation != null) {
        _mapController.move(currentLocation!, _mapController.camera.zoom);
      }
    });
  }

  String standardizedPaceDisplay(String originalPace) {
    // Parse the original pace format (e.g., "10'30\"")
    List<String> parts = originalPace.split("'");
    if (parts.length != 2) return originalPace;

    String minutesPart = parts[0];
    String secondsPart = parts[1].replaceAll("\"", "");

    try {
      int minutes = int.parse(minutesPart);
      int seconds = int.parse(secondsPart);

      // Convert to total seconds
      int totalSeconds = (minutes * 60) + seconds;

      // Standard walking pace is 11 min/km = 660 seconds
      // Apply a small variation based on the original pace
      double variation =
          (totalSeconds / 660.0 - 1.0) * 0.2; // 20% of the difference
      int standardizedSeconds =
          660 + (variation * 660).round(); // Using 660 seconds for 11 min/km

      // Convert back to min:sec format
      int standardMinutes = standardizedSeconds ~/ 60;
      int standardSecs = standardizedSeconds % 60;

      return "$standardMinutes'${standardSecs.toString().padLeft(2, '0')}\"";
    } catch (e) {
      // If parsing fails, return the original
      return originalPace;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with provided values
    currentRoutePoints = List.from(widget.routePoints);
    currentMarkers = List.from(widget.markers);
    currentPolylines = List.from(widget.polylines);

    // Set default location if routePoints is empty
    if (currentRoutePoints.isEmpty) {
      currentRoutePoints = [MapService.defaultCenter];
    }

    if (currentLocation == null && currentRoutePoints.isNotEmpty) {
      currentLocation = currentRoutePoints.last;
    }

    // Start listening to location updates
    _subscribeToLocationUpdates();
  }

  void _subscribeToLocationUpdates() {
    _locationSubscription =
        MapService.getLiveLocationStream().listen((newLocation) {
      if (!mounted) return; // ⛔️ stop kalau widget sudah dispose

      if (!widget.isPaused) {
        setState(() {
          currentLocation = newLocation;
          final mapData = MapService.getCurrentMapData();
          currentRoutePoints = mapData.routePoints;
          currentMarkers = mapData.markers;
          currentPolylines = mapData.polylines;

          if (_isFollowingUser) {
            _mapController.move(newLocation, _mapController.camera.zoom);
          }
        });
      } else {
        setState(() {
          currentLocation = newLocation;
        });
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel(); // ✅ cancel listener biar gak error
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure we always have a current location
    final displayLocation = currentLocation ?? MapService.defaultCenter;

    // Ensure we always have at least one point in polylines
    final displayPolylines = currentPolylines.isEmpty
        ? [
            Polyline(
                points: [displayLocation],
                color: Colors.transparent,
                strokeWidth: 0)
          ]
        : currentPolylines;

    // Ensure we always have markers
    final displayMarkers = currentMarkers.isEmpty
        ? [
            Marker(
              point: displayLocation,
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
        : currentMarkers;

    return Scaffold(
      body: Stack(
        children: [
          // Map display
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: displayLocation,
              initialZoom: 17, // Zoom in more for walking
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
              // Add custom user location marker
              if (currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation!,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.primaryGreen.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: widget.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Follow Me Button using the custom widget
          Positioned(
            right: 16,
            bottom: 200, // Position above your bottom panel
            child: FollowMeButton(
              isFollowing: _isFollowingUser,
              onPressed: _toggleFollowMode,
              activeColor: widget.primaryGreen,
            ),
          ),

          // Top overlay with basic info
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.formattedDuration,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.distance.toStringAsFixed(2)} km',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom overlay with metrics
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Main metrics row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Distance
                              _buildMetricColumn(
                                  widget.distance.toStringAsFixed(2), "Km"),

                              // Time
                              _buildMetricColumn(
                                  widget.formattedDuration, "Time"),

                              // Pace
                              _buildMetricColumn(widget.formattedPace, "Pace"),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Calories
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${widget.calories}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "kcal",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Controls with image assets
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!widget.isPaused)
                                // Pause button
                                InkWell(
                                  onTap: widget.onPause,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: widget.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                )
                              else
                                // Play and Stop buttons
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: widget.onResume,
                                      child: Image.asset(
                                        'assets/images/buttonplay.png',
                                        width: 60,
                                        height: 60,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    InkWell(
                                      onTap: widget.onStop,
                                      child: Image.asset(
                                        'assets/images/buttonstop.png',
                                        width: 60,
                                        height: 60,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
