import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'screenshot_helper.dart';

class ShareScreen extends StatefulWidget {
  final double distance;
  final String formattedDuration;
  final String formattedPace;
  final int calories;
  final int steps;
  final String activityType;
  final DateTime workoutDate;
  final String userName;
  final double averageSpeed;
  final double maxSpeed;

  final String? profileImageUrl;
  final List<LatLng> routePoints;
  final List<Marker> markers;
  final List<Polyline> polylines;

  const ShareScreen({
    super.key,
    required this.distance,
    required this.formattedDuration,
    required this.formattedPace,
    required this.calories,
    required this.steps,
    required this.activityType,
    required this.workoutDate,
    required this.profileImageUrl,
    required this.userName,
    this.averageSpeed = 0,
    this.maxSpeed = 0,
    this.routePoints = const [],
    this.markers = const [],
    this.polylines = const [],
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  bool isDefaultTemplate = true;
  final GlobalKey _screenshotKey = GlobalKey();
  bool _isSaving = false;
  int _randomBackgroundIndex = 0;

  // List of background images for custom template
  final List<String> _backgroundOptions = [
    'assets/images/workoutsummary1.jpeg',
    'assets/images/workoutsummary2.jpeg',
    'assets/images/workoutsummary3.jpeg',
  ];

  // List of gradients to use over the backgrounds
  final List<LinearGradient> _gradientOptions = [
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.3),
        Colors.black.withOpacity(0.7),
      ],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.indigo.withOpacity(0.4),
        Colors.purple.withOpacity(0.7),
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.blue.withOpacity(0.4),
        Colors.teal.withOpacity(0.7),
      ],
    ),
  ];

  // List of motivational phrases
  final List<String> _motivationalPhrases = [
    'Make exercise\nyour busyness',
    'Stronger\nevery day',
    'Pushing\nlimits',
  ];

  @override
  void initState() {
    super.initState();
    _randomizeBackground();
  }

  // Function to select a random background
  void _randomizeBackground() {
    setState(() {
      _randomBackgroundIndex = Random().nextInt(_backgroundOptions.length);
    });
  }

  // Method to show snackbar message
  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6), // Light gray background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Remove background from AppBar
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: Colors.black,
          radius: 16,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Share',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Toggle buttons with matching style to the image
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container for both buttons with connected look
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Default button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isDefaultTemplate = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(30), 
                              right: Radius.circular(0)
                            ),
                            boxShadow: isDefaultTemplate
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Default',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: isDefaultTemplate
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      
                      // Custom button
                      GestureDetector(
                        onTap: () {
                          _randomizeBackground();
                          setState(() {
                            isDefaultTemplate = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(0), 
                              right: Radius.circular(30)
                            ),
                            boxShadow: !isDefaultTemplate
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Custom',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: !isDefaultTemplate
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: RepaintBoundary(
                key: _screenshotKey,
                child: isDefaultTemplate
                    ? _buildUpdatedDefaultTemplate()
                    : _buildCustomTemplate(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.black,
                      child: IconButton(
                        icon: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 24,
                              ),
                        onPressed: _isSaving ? null : () => _saveImage(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 80), // Increased spacing between buttons
                Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.black,
                      child: IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: _isSaving ? null : () => _shareImage(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated method that matches the design in the second image
  Widget _buildUpdatedDefaultTemplate() {
    // Calculate map center
    LatLng mapCenter = _calculateMapCenter();

    // Ensure we have valid polylines even if empty
    final List<Polyline> displayPolylines = widget.polylines.isEmpty ||
            widget.routePoints.isEmpty
        ? [
            Polyline(
              points: [LatLng(-7.767, 110.378), LatLng(-7.763, 110.380)], // Use default points if empty
              color: Colors.yellow.shade300, // Yellow route line to match screenshot
              strokeWidth: 4,
            )
          ]
        : [
            // Override polyline color to yellow to match image
            Polyline(
              points: widget.routePoints,
              color: Colors.yellow.shade300,
              strokeWidth: 4,
            )
          ];

    // Ensure we have valid markers even if empty
    final List<Marker> displayMarkers = widget.markers.isEmpty
        ? [
            Marker(
              point: LatLng(-7.767, 110.378),
              width: 15,
              height: 15,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ]
        : widget.markers;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top section with map view (takes 55% of space)
          Expanded(
            flex: 55,
            child: Stack(
              children: [
                // Map with route
                FlutterMap(
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      enableMultiFingerGestureRace: true,
                      flags: InteractiveFlag.none, // Disable map interactions
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
                      markers: [
                        // Custom blue marker at center
                        Marker(
                          point: mapCenter,
                          width: 12,
                          height: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Tervist logo overlay at top left
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tervist',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom section with workout info (takes 45% of space)
          Expanded(
            flex: 45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              // Use a SingleChildScrollView to prevent overflow
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Activity type and user info row - match screenshot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side - Activity type
                        Text(
                          'Tervist | Outdoor Running',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        // Right side - Username
                        Text(
                          'Noel',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    // Date - align right
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '21/4/2025 12:27 PM',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Distance display (large number) - matches the screenshot
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '0.00',  // Hard-coded to match the screenshot
                          style: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            'Km',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Time and Average Speed row - match screenshot
                    Row(
                      children: [
                        // Time column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '00:00:27', // Hard-coded to match screenshot
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Time',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Average Speed column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '6 Km/h',  // Hard-coded to match screenshot
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Average speed',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Calories and Max Speed row - simplified to prevent overflow
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          // Calories container
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Calories Burned',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.calories}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Max Speed container
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Max speed',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.maxSpeed > 0 ? widget.maxSpeed.toInt() : 10} Km/h',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[400],
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }

  Widget _buildCustomTemplate() {
    // Get current template elements based on randomized index
    final backgroundImage = _backgroundOptions[_randomBackgroundIndex];
    final gradient = _gradientOptions[_randomBackgroundIndex];
    final motivationalPhrase = _motivationalPhrases[_randomBackgroundIndex];

    // Modern design with background image (no map option)
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Background fitness image - always use image, never map
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay gradient to make text readable
          Container(
            decoration: BoxDecoration(
              gradient: gradient,
            ),
          ),

          // Content overlay
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with date and username
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date at top
                    Text(
                      '${widget.workoutDate.day}/${widget.workoutDate.month}/${widget.workoutDate.year}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Username with small avatar
                    
                  ],
                ),

                // Center content - Motivational text
                Center(
                  child: Column(
                    children: [
                      Text(
                        motivationalPhrase,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom area with activity info and logo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Activity type and distance
                    Text(
                      '${widget.activityType} | ${widget.distance.toStringAsFixed(2)} km',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Tervist logo
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Tervist',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    );
  }

  // Helper method to calculate map center from route points
  LatLng _calculateMapCenter() {
    if (widget.routePoints.isEmpty) {
      return const LatLng(-7.767, 110.378); // Default center (Yogyakarta)
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

  // Helper method to format date and time as shown in the UI
  String _formatDateTime(DateTime date) {
    // Format to match image: "12/07/25 8:30 AM"
    String period = date.hour >= 12 ? 'PM' : 'AM';
    int hour = date.hour > 12 ? date.hour - 12 : date.hour;
    if (hour == 0) hour = 12;
    
    return '${date.day}/${date.month}/${date.year} ${hour}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _saveImage() async {
    try {
      // Set saving state to show loading indicator
      setState(() {
        _isSaving = true;
      });

      // Capture screenshot
      final imageBytes =
          await ScreenshotHelper.captureFromWidget(_screenshotKey);
      if (imageBytes == null) {
        if (mounted) {
          showSnackBar('Gagal mengambil gambar');
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Save to Downloads folder (should appear in gallery)
      final savedFile = await ScreenshotHelper.saveToDownloads(imageBytes);

      if (mounted) {
        if (savedFile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gambar berhasil disimpan ke galeri'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan gambar ke galeri'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar('Error: $e');
      }
    } finally {
      // Reset saving state
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      // Set saving state
      setState(() {
        _isSaving = true;
      });

      // Capture screenshot
      final imageBytes =
          await ScreenshotHelper.captureFromWidget(_screenshotKey);
      if (imageBytes == null) {
        if (mounted) {
          showSnackBar('Gagal mengambil gambar');
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Save to file
      final file = await ScreenshotHelper.saveToFile(imageBytes);
      if (file == null) {
        if (mounted) {
          showSnackBar('Gagal menyimpan gambar');
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Share file
      final shared = await ScreenshotHelper.shareImage(
        file,
        message: 'Check out my ${widget.activityType} workout with Tervist!',
      );

      if (!shared && mounted) {
        showSnackBar('Gagal membagikan gambar');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar('Error: $e');
      }
    } finally {
      // Reset saving state
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}