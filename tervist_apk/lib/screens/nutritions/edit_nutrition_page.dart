import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Import the warning widget
// Make sure to adjust the import path based on your project structure
import 'warning_widget.dart';

class EditNutritionPage extends StatefulWidget {
  final String title;
  final int value;
  final int dailyTarget;
  final int consumedValue;
  final ValueChanged<int> onSave;

  const EditNutritionPage({
    super.key,
    required this.title,
    required this.value,
    required this.dailyTarget,
    required this.consumedValue,
    required this.onSave,
  });

  @override
  State<EditNutritionPage> createState() => _EditNutritionPageState();
}

class _EditNutritionPageState extends State<EditNutritionPage> {
  late TextEditingController _controller;
  late int _currentValue;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = TextEditingController(text: _currentValue.toString());

    // Add listener to detect changes
    _controller.addListener(() {
      if (_controller.text != widget.value.toString() && !_isEditing) {
        setState(() {
          _isEditing = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDone() {
    final enteredValue = int.tryParse(_controller.text);
    if (enteredValue != null) {
      widget.onSave(enteredValue);
      Navigator.pop(context);
    }
  }

  void _handleRevert() {
    setState(() {
      _controller.text = widget.value.toString();
      _isEditing = false;
    });
  }

  // Method to handle back navigation with warning
  Future<bool> _onWillPop() async {
    if (_isEditing) {
      // Show warning dialog if there are unsaved changes
      _showWarningDialog();
      return false; // Prevent default back behavior
    }
    return true; // Allow back if no unsaved changes
  }

  // Method to handle back button press
  void _handleBackPress() {
    if (_isEditing) {
      // Show warning dialog if there are unsaved changes
      _showWarningDialog();
    } else {
      Navigator.pop(context);
    }
  }

  // Method to show the warning dialog using the WarningWidget
  void _showWarningDialog() {
    context.showWarningDialog(
      onLeave: () {
        // Handle leaving without saving
        Navigator.of(context).pop(); // Close the dialog
        Navigator.of(context).pop(); // Go back to previous screen
      },
      onBack: () {
        // Go back to continue editing
        Navigator.of(context).pop(); // Close the dialog only
      },
      warningTitle: 'Warning!',
      warningMessage: 'You haven\'t saved your nutrition changes yet! Are you sure you want to leave? Any unsaved data will be lost.',
    );
  }

  Color _getProgressColor() {
    switch (widget.title) {
      case 'Calories':
        return const Color(0xFF000000);
      case 'Protein':
        return const Color(0xFFE57373);
      case 'Carbs':
        return const Color(0xFFFFB74D);
      case 'Fats':
        return const Color(0xFF64B5F6);
      default:
        return Colors.grey;
    }
  }

  String _getIconAsset() {
    switch (widget.title) {
      case 'Calories':
        return 'assets/images/calories_streak.png';
      case 'Protein':
        return 'assets/images/protein.png';
      case 'Carbs':
        return 'assets/images/carb.png';
      case 'Fats':
        return 'assets/images/fat.png';
      default:
        return 'assets/images/calories_streak.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the Scaffold with WillPopScope to handle system back button
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F7F6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: _handleBackPress, // Use our custom handler
          ),
          centerTitle: true,
          title: Text(
            'Create meal',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Edit ${widget.title}',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F7F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE7E7E7), width: 1),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: widget.consumedValue / widget.dailyTarget,
                                strokeWidth: 5,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _getProgressColor()),
                              ),
                            ),
                            Center(
                              child: Image.asset(
                                _getIconAsset(),
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_controller.text}${widget.title == 'Protein' || widget.title == 'Carbs' || widget.title == 'Fats' ? 'g' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Out of ${widget.dailyTarget - widget.consumedValue} left today',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black),
                  ),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        if (!_isEditing) {
                          _isEditing = true;
                        }
                        _currentValue = int.tryParse(value) ?? 0;
                      });
                    },
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                      labelText: widget.title,
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 180),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleRevert,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              side: const BorderSide(color: Colors.black),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Revert',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleDone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Done',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
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
        ),
      ),
    );
  }
}