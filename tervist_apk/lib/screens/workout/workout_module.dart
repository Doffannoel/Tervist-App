import 'package:flutter/material.dart';
import 'treadmill/treadmill_tracker_screen.dart';
import 'running/running_tracker_screen.dart';
import 'walking/walking_tracker_screen.dart';
import 'cycling/cycling_tracker_screen.dart';

enum WorkoutType { treadmill, running, walking, cycling }

class WorkoutModule extends StatefulWidget {
  const WorkoutModule({
    super.key,
  });

  @override
  State<WorkoutModule> createState() => _WorkoutModuleState();
}

class _WorkoutModuleState extends State<WorkoutModule> {
  WorkoutType _currentWorkoutType = WorkoutType.treadmill;

  void _onWorkoutTypeChanged(String workoutType) {
    setState(() {
      switch (workoutType.toLowerCase()) {
        case 'running':
          _currentWorkoutType = WorkoutType.running;
          break;
        case 'walking':
          _currentWorkoutType = WorkoutType.walking;
          break;
        case 'cycling':
          _currentWorkoutType = WorkoutType.cycling;
          break;
        case 'treadmill':
          _currentWorkoutType = WorkoutType.treadmill;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return the appropriate workout screen based on selected type
    Widget currentScreen;

    switch (_currentWorkoutType) {
      case WorkoutType.running:
        currentScreen = RunningTrackerScreen(
          onWorkoutTypeChanged: _onWorkoutTypeChanged,
        );
        break;
      case WorkoutType.walking:
        currentScreen = WalkingTrackerScreen(
          onWorkoutTypeChanged: _onWorkoutTypeChanged,
        );
        break;
      case WorkoutType.cycling:
        currentScreen = CyclingTrackerScreen(
          onWorkoutTypeChanged: _onWorkoutTypeChanged,
        );
        break;
      case WorkoutType.treadmill:
        currentScreen = TreadmillTrackerScreen(
          onWorkoutTypeChanged: _onWorkoutTypeChanged,
        );
        break;
    }

    return currentScreen;
  }
}
