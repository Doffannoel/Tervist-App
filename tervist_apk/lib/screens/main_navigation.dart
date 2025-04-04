import 'package:flutter/material.dart';
import 'package:tervist_apk/screens/homepage/homepage.dart';
import 'package:tervist_apk/screens/nutritions/nutrition_main.dart';
import 'package:tervist_apk/screens/profile/userprofile_page.dart';
import 'package:tervist_apk/screens/workout/workout_module.dart';
import 'package:tervist_apk/widgets/navigation_bar.dart'; // <- path ke AppNavigationBar

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    NutritionMainPage(),
    WorkoutModule(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
