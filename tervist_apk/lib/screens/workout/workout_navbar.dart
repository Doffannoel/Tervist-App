import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'treadmill/treadmill_tracker_screen.dart';
import 'running/running_tracker_screen.dart' as running;
import 'walking/walking_tracker_screen.dart' as walking;
import 'cycling/cycling_tracker_screen.dart' as cycling;

class WorkoutNavbar extends StatelessWidget {
  final String currentWorkoutType;
  final Function(String) onWorkoutTypeChanged;

  const WorkoutNavbar({
    Key? key,
    required this.currentWorkoutType,
    required this.onWorkoutTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildWorkoutTypeButton(context, 'Outdoor\nrunning', _isSelected('running') || _isSelected('Running')),
          _buildWorkoutTypeButton(context, 'Walking', _isSelected('walking') || _isSelected('Walking')),
          _buildWorkoutTypeButton(context, 'Treadmill', _isSelected('treadmill') || _isSelected('Treadmill')),
          _buildWorkoutTypeButton(context, 'Outdoor\ncycling', _isSelected('cycling') || _isSelected('Cycling')),
        ],
      ),
    );
  }

  bool _isSelected(String type) {
    return currentWorkoutType.toLowerCase() == type.toLowerCase();
  }

  Widget _buildWorkoutTypeButton(BuildContext context, String label, bool isSelected) {
    String workoutType = '';
    
    if (label.contains('running')) {
      workoutType = 'running';
    } else if (label.contains('Walking')) {
      workoutType = 'walking';
    } else if (label.contains('Treadmill')) {
      workoutType = 'treadmill';
    } else if (label.contains('cycling')) {
      workoutType = 'cycling';
    }
    
    return InkWell(
      onTap: () {
        if (!isSelected) {
          // Panggil callback parent terlebih dahulu
          onWorkoutTypeChanged(workoutType);
          
          // Lakukan navigasi bila perlu, dengan check canPop terlebih dahulu
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(); // Pop screen saat ini terlebih dahulu
          }
          
          // Biarkan WorkoutModule yang menangani navigasi ke screen yang sesuai
          // Tidak perlu pushReplacement di sini
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}