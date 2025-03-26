import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:tervist_apk/screens/nutritions/nutrition_main.dart';
=======
<<<<<<< HEAD
import 'screens/workout/workout_module.dart';
=======
import 'package:tervist_apk/screens/onboarding_screen.dart';
>>>>>>> a18811088ccb4dd93afd3aa4ba94e03407573d63
>>>>>>> 632a2bb0f35fd57f82369a7b71f1c837834cc111

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
<<<<<<< HEAD
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          primarySwatch: Colors.blue),
      home: NutritionMainPage(),
=======
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2AAF7F)),
        useMaterial3: true,
      ),
<<<<<<< HEAD
      home: const WorkoutModule(), // Directly show the treadmill tracker
=======
      home: OnboardingScreen(),
>>>>>>> a18811088ccb4dd93afd3aa4ba94e03407573d63
>>>>>>> 632a2bb0f35fd57f82369a7b71f1c837834cc111
    );
  }
}