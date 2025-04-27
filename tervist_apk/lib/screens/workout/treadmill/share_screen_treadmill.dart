import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math'; // Added for Random
import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
import '../screenshot_helper.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import for cached network images

class ShareScreen extends StatefulWidget {
  final double distance;
  final String formattedDuration;
  final String formattedPace;
  final int calories;
  final int steps;
  final String activityType; // 'Treadmill' or 'Outdoor Running' or 'Walking'
  final DateTime workoutDate;
  final String userName;
  final String? profileImageUrl; // Add profileImageUrl parameter

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
    this.profileImageUrl, // Make it optional
  }) : super(key: key);

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  bool isDefaultTemplate =
      true; // Updated to use default template as the initial option
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

  // Helper method to create metric columns
  Widget _buildMetricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Helper method to create metrics with icons
  Widget _buildMetricWithIcon(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to format date and time
  String _formatDateTime(DateTime date) {
    // Format to match image: "12/07/25 8:30 AM"
    String period = date.hour >= 12 ? 'PM' : 'AM';
    int hour = date.hour > 12 ? date.hour - 12 : date.hour;
    if (hour == 0) hour = 12;

    return '${date.day}/${date.month}/${date.year} ${hour}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F7F6), // Match background color to latest design
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F7F6), // Match the background color
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
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Template selector with improved design
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

          // Preview area
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

          // Bottom actions with larger buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Save button with improved styling
                Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: _isSaving ? Colors.grey : Colors.black,
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
                const SizedBox(width: 60), // Spacing between buttons
                // Share button with improved styling
                Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: _isSaving ? Colors.grey : Colors.black,
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
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Treadmill image section
          Expanded(
            flex: 14,
            child: Stack(
              children: [
                // Treadmill image - adjusted to display 3D model properly
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: Image.asset(
                      'assets/images/treadmill.png',
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),

                // Tervist logo overlay at top left
                Positioned(
                  top: 16,
                  left: 16,
                  child: Image.asset(
                    'assets/images/logotervist.png',
                    height: 30,
                    fit: BoxFit.contain,
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
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: widget.profileImageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: widget.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.grey,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/profile.png',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/profile.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _formatDateTime(widget.workoutDate),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
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
                      borderRadius: BorderRadius.circular(24),
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
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.orange[400],
                              size: 18,
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
                      borderRadius: BorderRadius.circular(24),
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
                            Icon(
                              Icons.directions_walk,
                              color: Colors.blue[400],
                              size: 18,
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

  // Updated custom template with square aspect ratio and improved layout
  Widget _buildCustomTemplate() {
    // Get current template elements based on randomized index
    final backgroundImage = _backgroundOptions[_randomBackgroundIndex];
    final gradient = _gradientOptions[_randomBackgroundIndex];
    final motivationalPhrase = _motivationalPhrases[_randomBackgroundIndex];

    return AspectRatio(
      aspectRatio: 1.0, // Force a square aspect ratio (1:1)
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Background fitness image
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

            // Tervist logo at top right

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
