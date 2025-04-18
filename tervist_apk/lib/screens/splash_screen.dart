import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/screens/main_navigation.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
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

  void _navigateAfterSplash() async {
    // Tunggu 3 detik untuk menampilkan splashscreen
    await Future.delayed(const Duration(seconds: 3));
    
    // Cek status login setelah splash screen
    final loggedIn = await isLoggedIn();
    
    if (!mounted) return;
    
    // Navigate to the appropriate screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => loggedIn 
            ? const MainNavigation() 
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/svg/splashtervist.gif',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
