import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/screens/main_navigation.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
        builder: (context) =>
            loggedIn ? const MainNavigation() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFE6F4F1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRect(
              child: Transform.scale(
                scale: 2, // 👉 nambah scale supaya gambar melebar
                child: Image.asset(
                  'assets/svg/splashscreennew.gif',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
