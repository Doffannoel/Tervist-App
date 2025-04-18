import 'package:flutter/material.dart';

class AppNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppNavigationBar({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F7F6), // Background color
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white, // Navigation bar container color
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              isActive: currentIndex == 0,
              activeIcon: Icons.home,
              inactiveIcon: Icons.home_outlined,
              label: 'Home',
              onTap: () => _handleTap(context, 0),
            ),
            _buildNavItem(
              isActive: currentIndex == 1,
              activeIcon: Icons.restaurant,
              inactiveIcon: Icons.restaurant_outlined,
              label: 'Nutrition',
              onTap: () => _handleTap(context, 1),
            ),
            _buildNavItem(
              isActive: currentIndex == 2,
              activeIcon: Icons.directions_run,
              inactiveIcon: Icons.directions_run_outlined,
              label: 'Workout',
              onTap: () => _handleTap(context, 2),
            ),
            _buildNavItem(
              isActive: currentIndex == 3,
              activeIcon: Icons.person,
              inactiveIcon: Icons.person_outlined,
              label: 'Profile',
              onTap: () => _handleTap(context, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required bool isActive,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top indicator line (only for active item)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              width: isActive ? 50 : 0,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CB9A0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Icon
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? Colors.black : Colors.grey[400],
              size: 24,
            ),
            // Label (only for active item)
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
    } else {
      _handleNavigation(context, index);
    }
  }
  
  void _handleNavigation(BuildContext context, int index) {
    // Jika sudah berada di tab yang sama, tidak perlu melakukan apa-apa
    if (index == currentIndex) return;
    
    // Pop semua halaman sampai kembali ke navigasi utama
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}