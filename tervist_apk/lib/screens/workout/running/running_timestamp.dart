import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RunningTimestamp extends StatefulWidget {
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

  const RunningTimestamp({
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
  State<RunningTimestamp> createState() => _RunningTimestampState();
}

class _RunningTimestampState extends State<RunningTimestamp> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map display
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.routePoints.isNotEmpty 
                  ? widget.routePoints.first 
                  : const LatLng(-7.767, 110.378),
              initialZoom: 15,
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
              // Add a current location marker
              // const CurrentLocationLayer(),
            ],
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
                            _buildMetricColumn(widget.distance.toStringAsFixed(2), "Km"),
                            
                            // Time
                            _buildMetricColumn(widget.formattedDuration, "Time"),
                            
                            // Pace
                            _buildMetricColumn(widget.formattedPace, "Pace"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Calories
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${widget.calories}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text("kcal"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton(
                              onPressed: widget.isPaused ? widget.onResume : widget.onPause,
                              backgroundColor: widget.primaryGreen,
                              child: Icon(widget.isPaused ? Icons.play_arrow : Icons.pause),
                            ),
                            if (widget.isPaused)
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: FloatingActionButton(
                                  onPressed: widget.onStop,
                                  backgroundColor: Colors.orange,
                                  child: const Icon(Icons.stop),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}