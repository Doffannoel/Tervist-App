import 'package:flutter/material.dart';
import 'package:tervist_apk/api/notification_service.dart';
import 'package:tervist_apk/screens/main_navigation.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';
import 'package:tervist_apk/api/auth_helper.dart'; // ✅ pakai AuthHelper
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      navigateToNextScreen();
    });
  }

  // ✅ Ganti cara cek login: gunakan AuthHelper yang konsisten
  Future<bool> isLoggedIn() async {
    return await AuthHelper.isLoggedIn();
  }

  void navigateToNextScreen() async {
    final isUserLoggedIn = await isLoggedIn();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            isUserLoggedIn ? const MainNavigation() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset('assets/svg/splashtervist.gif'),
        ),
      ),
    );
  }
}
