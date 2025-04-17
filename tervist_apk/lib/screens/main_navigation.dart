import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/screens/homepage/homepage.dart';
import 'package:tervist_apk/screens/nutritions/nutrition_main.dart';
import 'package:tervist_apk/screens/nutritions/selected_food_page.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';
import 'package:tervist_apk/screens/profile/userprofile_page.dart';
import 'package:tervist_apk/screens/workout/workout_module.dart';
import 'package:tervist_apk/widgets/navigation_bar.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex = 0;
  bool _checkingToken = true;

  // Use a key for each page to maintain state
  final List<Widget> _pages = const [
    HomePage(),
    NutritionMainPage(),
    WorkoutModule(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkTokenValidity();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _checkTokenValidity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      // Token tidak ada → arahkan ke onboarding/login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
            settings: const RouteSettings(name: 'OnboardingScreen'),
          ),
        );
      }
    } else {
      // Token ada, lanjutkan ke home
      setState(() {
        _checkingToken = false;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingToken) {
      // Saat sedang cek token, bisa tampilkan loading dulu
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      // Handle back button presses
      onWillPop: () async {
        if (_currentIndex != 0) {
          // If not on home tab, go to home tab
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true; // Allow app to exit if on home tab
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: AppNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
