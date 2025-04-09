import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
import '../screenshot_helper.dart';

class ShareScreen extends StatefulWidget {
  final double distance;
  final String formattedDuration;
  final String formattedPace;
  final int calories;
  final int steps;
  final String activityType; // 'Treadmill' or 'Outdoor Running' or 'Walking'
  final DateTime workoutDate;
  final String userName;

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
  }) : super(key: key);

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  bool isDefaultTemplate = false; // Set the default to Custom template
  final GlobalKey _screenshotKey = GlobalKey();
  bool _isSaving = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Share',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Removed the share button from app bar to match design in Image 1
        ],
      ),
      body: Column(
        children: [
          // Template selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Default template button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDefaultTemplate = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDefaultTemplate ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDefaultTemplate ? Colors.grey[300]! : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      'Default',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: isDefaultTemplate ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Custom template button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDefaultTemplate = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: !isDefaultTemplate ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: !isDefaultTemplate ? Colors.grey[300]! : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      'Custom',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: !isDefaultTemplate ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Preview area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: RepaintBoundary(
                key: _screenshotKey,
                child: isDefaultTemplate 
                    ? _buildDefaultTemplate() 
                    : _buildCustomTemplate(),
              ),
            ),
          ),
          
          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Save button
                GestureDetector(
                  onTap: _isSaving ? null : () => _saveImage(),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isSaving ? Colors.grey : Colors.black,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: _isSaving
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.download,
                                color: Colors.white,
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 60), // Increased spacing between buttons
                // Share button
                GestureDetector(
                  onTap: _isSaving ? null : () => _shareImage(),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isSaving ? Colors.grey : Colors.black,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D Workout Image
            Image.asset(
              widget.activityType == 'Treadmill'
                  ? 'assets/images/treadmill.png'
                  : 'assets/images/running.png',
              height: 200,
              width: 200,
            ),
            
            const SizedBox(height: 20),
            
            // Workout Summary Card
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity and user info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.activityType,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      // Placeholder for user profile - you may want to replace with actual user avatar
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[600], size: 20),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Distance
                  Center(
                    child: Text(
                      '${widget.distance.toStringAsFixed(2)} Km',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Time and Pace Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricColumn('Time', widget.formattedDuration),
                      _buildMetricColumn('Pace', widget.formattedPace),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Divider
                  Divider(color: Colors.grey.shade300),
                  
                  const SizedBox(height: 16),
                  
                  // Calories and Steps Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricWithIcon(
                        Icons.local_fire_department, 
                        'Calories', 
                        '${widget.calories} kcal',
                        Colors.orange,
                      ),
                      _buildMetricWithIcon(
                        Icons.directions_walk, 
                        'Steps', 
                        '${widget.steps}',
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to match Image 1 design
  Widget _buildCustomTemplate() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/workoutsummary1.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tervist icon at top
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tervist',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Date
                Text(
                  '${widget.workoutDate.day}/${widget.workoutDate.month}/${widget.workoutDate.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Motivational text
                Text(
                  'Make exercise',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                Text(
                  'your busyness',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Exercise info
                Text(
                  '${widget.activityType} | ${widget.distance.toStringAsFixed(2)} Km',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      final imageBytes = await ScreenshotHelper.captureFromWidget(_screenshotKey);
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
            SnackBar(
              content: Text('Gambar berhasil disimpan ke ${savedFile.path}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
      final imageBytes = await ScreenshotHelper.captureFromWidget(_screenshotKey);
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
      final shared = await ScreenshotHelper.shareImage(
        file, 
        message: 'Check out my ${widget.activityType} workout with Tervist!'
      );
      
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