import 'package:flutter/material.dart';
import 'screens/workout/workout_module.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tervist App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2AAF7F)),
        useMaterial3: true,
      ),
      home: const WorkoutModule(), // Directly show the treadmill tracker
    );
  }
}