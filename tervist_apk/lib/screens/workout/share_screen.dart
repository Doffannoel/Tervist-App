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
  final String? profileImageUrl;
  final double averageSpeed;
  final double maxSpeed;
  final List<LatLng> routePoints;
  final List<Marker> markers;
  final List<Polyline> polylines;

  const ShareScreen({
    Key? key,
    required this.distance,
    required this.formattedDuration,
    required this.formattedPace,
    required this.calories,
    required this.steps,
    required this.activityType,
    required this.workoutDate,
    required this.userName,
    this.profileImageUrl,
    this.averageSpeed = 0,
    this.maxSpeed = 0,
    this.routePoints = const [],
    this.markers = const [],
    this.polylines = const [],
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F7F6), // Changed background color to F1F7F6
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF1F7F6), // Match the background color
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
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDefaultTemplate = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDefaultTemplate
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
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
                  GestureDetector(
                    onTap: () {
                      _randomizeBackground();
                      setState(() {
                        isDefaultTemplate = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: !isDefaultTemplate
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: RepaintBoundary(
                  key: _screenshotKey,
                  child: isDefaultTemplate
                      ? _buildDefaultTemplate()
                      : _buildCustomTemplate(),
                ),
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
                const SizedBox(width: 60),
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

  Widget _buildDefaultTemplate() {
    // Calculate map center
    LatLng mapCenter = _calculateMapCenter();

    // Ensure we have valid polylines even if empty
    final List<Polyline> displayPolylines = widget.polylines.isEmpty ||
            widget.routePoints.isEmpty
        ? [
            Polyline(
              points: [LatLng(-7.767, 110.378)], // Use default point if empty
              color: Colors.green,
              strokeWidth: 4,
            )
          ]
        : widget.polylines;

    // Ensure we have valid markers even if empty
    final List<Marker> displayMarkers = widget.markers.isEmpty
        ? [
            Marker(
              point: LatLng(-7.767, 110.378),
              width: 15,
              height: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ]
        : widget.markers;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map section with route (now larger)
          Expanded(
            flex: 14, // Increased from 12 to 14 to make map even larger
            child: Stack(
              children: [
                // Map
                FlutterMap(
                  options: MapOptions(
                    initialCenter: mapCenter,
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

                // Tervist logo overlay at top left - CHANGED TO USE IMAGE ASSET
                Positioned(
                  top: 16,
                  left: 16,
                  child: Image.asset(
                    'assets/images/logotervist.png',
                    height: 24,
                  ),
                ),
              ],
            ),
          ),

          // Bottom card with workout details
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24), // Increased rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top row with activity type and profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Activity type
                      Text(
                        'Tervist | ${widget.activityType}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                      // Profile image with username and time below - right aligned
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: widget.profileImageUrl != null
                                ? NetworkImage(widget.profileImageUrl!)
                                    as ImageProvider
                                : const AssetImage('assets/images/profile.png'),
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDateTime(widget.workoutDate),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Distance with Km unit
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${widget.distance.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Km',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Dividing line
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),

                  // Time and Pace row
                  const SizedBox(height: 16),
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Time',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      // Pace column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.formattedPace,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pace',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
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

          // Additional cards for Calories and Steps
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                // Calories container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          24), // Increased rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/fireicon.png',
                              height: 18,
                              width: 18,
                              color: Colors.orange[400],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Calories Burned',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${widget.calories}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[400],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Kcal',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Steps container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          24), // Increased rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/stepicon.png',
                              height: 18,
                              width: 18,
                              color: Colors.blue[400],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Steps',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.steps}',
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
    );
  }

  Widget _buildCustomTemplate() {
    // Get current template elements based on randomized index
    final backgroundImage = _backgroundOptions[_randomBackgroundIndex];
    final gradient = _gradientOptions[_randomBackgroundIndex];
    final motivationalPhrase = _motivationalPhrases[_randomBackgroundIndex];

    // Modern design with background image and square aspect ratio
    return AspectRatio(
      aspectRatio: 1.0, // Force a square aspect ratio (1:1)
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Background fitness image with square aspect ratio
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

            // Tervist logo at top right - CHANGED TO USE IMAGE ASSET
            Positioned(
              top: 15,
              right: 15,
              child: Image.asset(
                'assets/images/logotervist.png',
                height: 20,
              ),
            ),

            // Main content column - centered
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Date - positioned at the vertically centered area
                    Text(
                      '${widget.workoutDate.day}/${widget.workoutDate.month}/${widget.workoutDate.year}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Motivational text
                    Text(
                      motivationalPhrase,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Activity info
                    Text(
                      '${widget.activityType} | Distance ${widget.distance.toStringAsFixed(2)} Km',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  // Calculate an approximate average speed based on distance and time
  int _calculateAverageSpeed() {
    // Extract hours, minutes, seconds from formatted duration
    List<String> timeParts = widget.formattedDuration.split(':');
    double hours = 0;

    if (timeParts.length == 3) {
      hours = double.parse(timeParts[0]) +
          (double.parse(timeParts[1]) / 60) +
          (double.parse(timeParts[2]) / 3600);
    }

    // Avoid division by zero
    if (hours == 0) return 0;

    // Calculate speed in km/h
    double speed = widget.distance / hours;
    return speed.round();
  }

  // Placeholder for max speed calculation
  int _calculateMaxSpeed() {
    // Return provided max speed or calculate from average
    return widget.maxSpeed > 0
        ? widget.maxSpeed.toInt()
        : _calculateAverageSpeed() + 4;
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengambil gambar')),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Save to Downloads folder (should appear in gallery)
      final savedFile = await ScreenshotHelper.saveToDownloads(imageBytes);

      if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengambil gambar')),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Save to file
      final file = await ScreenshotHelper.saveToFile(imageBytes);
      if (file == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan gambar')),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Share file
      final shared = await ScreenshotHelper.shareImage(file,
          message: 'Check out my ${widget.activityType} workout with Tervist!');

      if (!shared && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membagikan gambar')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
