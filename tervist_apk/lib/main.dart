import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/notification_service.dart';
import 'package:tervist_apk/screens/main_navigation.dart';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';
import 'dart:async';

void main() async {
  // Ensure Flutter is initialized before calling any platform methods
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications service
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
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
    Timer(const Duration(seconds: 8), () {
      navigateToNextScreen();
    });
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) return false;

    final response = await http.get(
      ApiConfig.profile,
      headers: {'Authorization': 'Bearer $token'},
    );

    debugPrint('Profile response status: ${response.statusCode}');
    debugPrint('Profile response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      // Token tidak valid, hapus dari SharedPreferences
      await prefs.remove('access_token');
      return false;
    }
  }

  void navigateToNextScreen() async {
    bool isUserLoggedIn = await isLoggedIn();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isUserLoggedIn
              ? const MainNavigation()
              : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset(
            'assets/svg/splashtervist.gif',
          ),
        ),
      ),
    );
  }
}
