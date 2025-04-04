import 'package:flutter/material.dart';

import 'package:tervist_apk/screens/onboarding_screen.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';
import 'package:tervist_apk/screens/workout/workout_module.dart';
import 'package:tervist_apk/screens/homepage/homepage.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          primarySwatch: Colors.blue),
      home: HomePage(), // kalo mau ganti disini OnboardingScreen to WorkoutModule
    );
  }
}