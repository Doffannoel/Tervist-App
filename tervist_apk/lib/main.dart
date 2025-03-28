import 'package:flutter/material.dart';
// import 'package:tervist_apk/screens/onboarding_screen.dart';
// import 'package:flutter/material.dart';
import 'package:tervist_apk/screens/workout/workout_module.dart'; // Update import

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
      home: const WorkoutModule(), // Changed from OnboardingScreen to WorkoutModule
    );
  }
}
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//           primarySwatch: Colors.blue),
//       home: OnboardingScreen(),
//     );
//   }
// }