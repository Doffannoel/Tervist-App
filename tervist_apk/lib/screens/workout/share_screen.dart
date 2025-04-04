import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
import 'screenshot_helper.dart';

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
  bool isDefaultTemplate = true;
  final GlobalKey _screenshotKey = GlobalKey();
  bool _isSaving = false;

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
                const SizedBox(width: 24),
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
                        child: Image.asset(
                          'assets/images/sharebutton.png',
                          width: 24,
                          height: 24,
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
      child: Column(
        children: [
          // 3D image
          Expanded(
            flex: 2,
            child: widget.activityType == 'Treadmill'
                ? Image.asset('assets/images/treadmill.png')
                : Image.asset('assets/images/running.png'),
          ),
          
          // Stats area
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity type
                  Text(
                    'Tervist | ${widget.activityType}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Distance and user info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.distance.toStringAsFixed(2),
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          'Km',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // User info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${widget.workoutDate.day}/${widget.workoutDate.month}/${widget.workoutDate.year} ${widget.workoutDate.hour}:${widget.workoutDate.minute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Time and Pace
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.formattedDuration,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
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
                      const SizedBox(width: 60),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.formattedPace,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
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
                  
                  const SizedBox(height: 16),
                  
                  // Calories
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange[400],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calories Burned',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[400],
                        ),
                      ),
                      const Spacer(),
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
                        'kcal',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Steps
                  Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: Colors.blue[400],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Steps',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[400],
                        ),
                      ),
                      const Spacer(),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTemplate() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/nature_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Overlay for better text visibility
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/tervist_logo.png',
                  height: 50,
                ),
                
                const SizedBox(height: 16),
                
                // Date
                Text(
                  '${widget.workoutDate.day}/${widget.workoutDate.month}/${widget.workoutDate.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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