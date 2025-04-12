import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/notification_service.dart';
import 'package:tervist_apk/screens/main_navigation.dart';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';

void main() async {
  // Ensure Flutter is initialized before calling any platform methods
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications service
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      await prefs.remove(
          'access_token'); // Changed from 'token' to 'access_token' to match your other code
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data == true
                ? const MainNavigation()
                : const  OnboardingScreen();
          }
        },
      ),
    );
  }
}
