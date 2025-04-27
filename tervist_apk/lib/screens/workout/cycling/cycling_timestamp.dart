import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../map_service.dart';
import '../follow_me_button.dart';
import 'dart:async';

class CyclingTimestamp extends StatefulWidget {
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

  const CyclingTimestamp({
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
  State<CyclingTimestamp> createState() => _CyclingTimestampState();
}

class _CyclingTimestampState extends State<CyclingTimestamp>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  List<LatLng> currentRoutePoints = [];
  List<Marker> currentMarkers = [];
  List<Polyline> currentPolylines = [];
  LatLng? currentLocation;
  bool _isFollowingUser = true;
  bool _isExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

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

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start listening to location updates
    _subscribeToLocationUpdates();
  }

  late StreamSubscription<LatLng> _locationSubscription;

  void _subscribeToLocationUpdates() {
    _locationSubscription =
        MapService.getLiveLocationStream().listen((newLocation) {
      if (!mounted) return;

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
    _locationSubscription.cancel();
    _animationController.dispose();
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
              initialZoom: 17, // Zoom in more for cycling
              interactionOptions: const InteractionOptions(
                enableMultiFingerGestureRace: true,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.cycling_app',
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

          // Bottom overlay with metrics - this transitions from default view to detailed view
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                });
              },
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small drag indicator at the top
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Content based on expanded state
                    AnimatedCrossFade(
                      firstChild: _buildSimpleView(),
                      secondChild: _buildExpandedView(),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
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

  // Simple view as shown in the left image (Workout page - 2)
  Widget _buildSimpleView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.distance.toStringAsFixed(2),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Km",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.formattedDuration,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Time",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Dark indicator line at bottom
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  // Expanded view as shown in the right image (Workout page - 4)
  Widget _buildExpandedView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distance at top
          Row(
            children: [
              Text(
                widget.distance.toStringAsFixed(2),
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Km",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Time and Pace side by side
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.formattedDuration,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Time",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 64),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.formattedPace,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Pace",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Calories
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.calories}",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Kcal",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Play and Stop buttons - centered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play button
              InkWell(
                onTap: widget.onResume,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Stop button
              InkWell(
                onTap: widget.onStop,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),

          // Black indicator bar at bottom
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
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
