import 'package:flutter/material.dart';
import 'treadmill/treadmill_tracker_screen.dart';
import 'running/running_tracker_screen.dart';

enum WorkoutType {
  treadmill,
  running,
  walking,
  cycling
}

class WorkoutModule extends StatefulWidget {
  final WorkoutType initialWorkoutType;
  final Color? customPrimaryColor;
  
  const WorkoutModule({
    super.key, 
    this.initialWorkoutType = WorkoutType.treadmill,
    this.customPrimaryColor,
  });

  @override
  State<WorkoutModule> createState() => _WorkoutModuleState();
}

class _WorkoutModuleState extends State<WorkoutModule> {
  late WorkoutType _currentWorkoutType;
  
  @override
  void initState() {
    super.initState();
    _currentWorkoutType = widget.initialWorkoutType;
  }
  
  @override
  Widget build(BuildContext context) {
    switch (_currentWorkoutType) {
      case WorkoutType.running:
        return const RunningTrackerScreen();
      case WorkoutType.treadmill:
      default:
        return const TreadmillTrackerScreen();
    }
  }
}