import 'package:flutter/material.dart';
import 'package:tervist_apk/screens/nutritions/nutrition_main.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';
import 'package:tervist_apk/screens/profile/userprofile_page.dart';
// import 'package:tervist_apk/screens/onboarding_screen.dart';
import 'package:tervist_apk/screens/workout/workout_module.dart';

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
      home:
          ProfilePage(), // kalo mau ganti disini OnboardingScreen to WorkoutModule
    );
  }
}
