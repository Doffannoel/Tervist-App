import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

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
  });

  @override
  State<RunningSummary> createState() => _RunningSummaryState();
}

class _RunningSummaryState extends State<RunningSummary> {
  final MapController _mapController = MapController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map with completed route
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _calculateMapCenter(),
              initialZoom: 14,
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
                polylines: widget.polylines,
              ),
              MarkerLayer(
                markers: widget.markers,
              ),
            ],
          ),
          
          // Header overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: widget.onBackToHome,
                    ),
                    const Text(
                      'Outdoor Running',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {
                            // Share functionality
                          },
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: 16,
                          child: const Icon(Icons.person, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom metrics card
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Distance display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.distance.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Time and Pace
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            children: [
                              Text(
                                widget.formattedDuration,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.grey[400],
                          ),
                          Column(
                            children: [
                              Text(
                                widget.formattedPace,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Pace',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Calories and Steps
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      size: 16,
                                      color: Colors.orange[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Calories Burned',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[400],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${widget.calories}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'kcal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_walk,
                                      size: 16,
                                      color: widget.primaryGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Steps',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.steps}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Pace Graph
                    Container(
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                5,
                                (index) {
                                  final double height = 30 + (math.Random().nextDouble() * 60);
                                  return Container(
                                    width: 20,
                                    height: height,
                                    decoration: BoxDecoration(
                                      color: widget.primaryGreen.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.directions_run,
                                size: 14,
                                color: widget.primaryGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Pace',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Share Button
                    ElevatedButton.icon(
                      onPressed: () {
                        // Share workout functionality
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
}