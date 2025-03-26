import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'screens/workout/workout_module.dart';
=======
import 'package:tervist_apk/screens/onboarding_screen.dart';
>>>>>>> a18811088ccb4dd93afd3aa4ba94e03407573d63

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
<<<<<<< HEAD
      home: const WorkoutModule(), // Directly show the treadmill tracker
=======
      home: OnboardingScreen(),
>>>>>>> a18811088ccb4dd93afd3aa4ba94e03407573d63
    );
  }
}