import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showLogoutDialog = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

 Widget _buildStepsCard() {
  double progress = 0.72;

  return Card(
  color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_walk, color: Color(0xFF587DBD)),
              SizedBox(width: 8),
              Text(
                'Daily steps',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Spacer(),
              Text(
                '7.234',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF587DBD),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Custom progress bar with 2 colors
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: (progress * 100 * 0.75).toInt(), // 55% dari progress
                      child: Container(color: Color(0xFF587DBD), height: 8),
                    ),
                    Expanded(
                      flex: (progress * 100 * 0.25).toInt(), // 45% dari progress
                      child: Container(color: Color(0xFF2CC2A1), height: 8),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text('72% of daily goal (10.000 steps)'),
          SizedBox(height: 12),
          Text('Distance: 1.7 km'),
          Text('Avg. Pace: 14 min/km'),
        ],
      ),
    ),
  );
}

Widget _buildCaloriesBurnedCard() {
  double progress = 0.48;

  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Color(0xFFFF8800)),
              SizedBox(width: 8),
              Text(
                'Calories Burned',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Spacer(),
              Text(
                '486',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFFF8800),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: (progress * 100 * 0.55).toInt(),
                      child: Container(color: Color(0xFFFF8800), height: 8),
                    ),
                    Expanded(
                      flex: (progress * 100 * 0.45).toInt(),
                      child: Container(color: Color(0xFF2CC2A1), height: 8),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text('48% of daily goal (1.000 kcal)'),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exercise', style: TextStyle(fontSize: 12)),
                  Text('286 kcal',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('BMR', style: TextStyle(fontSize: 12)),
                  Text('200 kcal',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAchievementsCard() {
  return Card(
    color: Colors.white,
    margin: EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Recent Achievements',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildAchievementItem(
            imagePath: 'assets/images/step.png',
            title: 'First Step',
            subtitle: 'Walk 1,000 steps in a day',
          ),
          SizedBox(height: 12),
          _buildAchievementItem(
            imagePath: 'assets/images/fnb.png',
            title: 'Balanced Eater',
            subtitle: 'Log meals for 7 days in a row',
          ),
        ],
      ),
    ),
  );
}

 Widget _buildAchievementItem({
  required String imagePath,
  required String title,
  required String subtitle,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        backgroundImage: AssetImage(imagePath),
        radius: 20,
        backgroundColor: Colors.grey.shade200,
      ),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    ]
  );
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFEBFDFA),

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 12),
              color: const Color(0xFFEBFDFA),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Hi, admin!",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.local_fire_department,
                                      color: Colors.orange, size: 16),
                                  SizedBox(width: 4),
                                  Text("11",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Track your daily progress",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.png'),
                      radius: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'logout') {
                        setState(() {
                          _showLogoutDialog = true;
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Text('View profile'),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Log out',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildCalorieBudget(),
                SizedBox(height: 24),
                _buildMealSummary(),
                SizedBox(height: 16),
                _buildStepsCard(),
                SizedBox(height: 16),
                _buildCaloriesBurnedCard(),
                SizedBox(height: 16),
                _buildHeartWorkoutRow(),
                SizedBox(height: 16),
                _buildAchievementsCard(),
                SizedBox(height: 80),
              ],
            ),
            if (_showLogoutDialog) _buildLogoutDialog(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
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
              isActive: _selectedIndex == 0,
              activeIcon: Icons.home,
              inactiveIcon: Icons.home_outlined,
              label: 'Home',
              onTap: () => _onItemTapped(0),
            ),
            _buildNavItem(
              isActive: _selectedIndex == 1,
              activeIcon: Icons.restaurant,
              inactiveIcon: Icons.restaurant_outlined,
              label: 'Nutrition',
              onTap: () => _onItemTapped(1),
            ),
            _buildNavItem(
              isActive: _selectedIndex == 2,
              activeIcon: Icons.directions_run,
              inactiveIcon: Icons.directions_run_outlined,
              label: 'Workout',
              onTap: () => _onItemTapped(2),
            ),
            _buildNavItem(
              isActive: _selectedIndex == 3,
              activeIcon: Icons.person,
              inactiveIcon: Icons.person_outlined,
              label: 'Profile',
              onTap: () => _onItemTapped(3),
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

  Widget _buildCalorieBudget() {
    double totalBudget = 1236.0;
    double caloriesLeft = 582.0;
    double caloriesUsed = totalBudget - caloriesLeft;

    // Calculate progress percentages for the two blue segments
    double darkBlueProgress = caloriesUsed *
        0.55 /
        totalBudget; // First blue segment (darker blue - 425E8E)
    double lightBlueProgress = caloriesUsed *
        0.45 /
        totalBudget; // Second blue segment (lighter blue - 587DBD)

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Calorie Budget',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                '1.236',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            // Gray background circle (E7E7E7)
            SizedBox(
            height: 180,
            width: 180,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 28,
              backgroundColor: Color(0xFFE7E7E7),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE7E7E7)),
            ),
          ),

            // Dark blue segment (425E8E)
            SizedBox(
              height: 180,
              width: 180,
              child: CircularProgressIndicator(
                value: darkBlueProgress,
                strokeWidth: 28,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF425E8E)),
              ),
            ),
            // Light blue segment (587DBD) - starts where the dark blue ends
            SizedBox(
              height: 180,
              width: 180,
              child: Transform.rotate(
                angle: 2 *
                    pi *
                    darkBlueProgress, // Rotate to start after dark blue
                child: CircularProgressIndicator(
                  value: lightBlueProgress,
                  strokeWidth: 28,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF587DBD)),
                ),
              ),
            ),
            // Text inside the circle
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '582',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Left',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        // Three lines at the bottom with specifications
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.shade300,
        ),
        SizedBox(height: 6),
        Center(
          child: Container(
            width: 180,
            height: 3,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

 Widget _buildMealSummary() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMealColumn('Breakfast', 220, 'assets/images/breakfast.png', true),
        _buildMealColumn('Lunch', 498, 'assets/images/lunch.png', true),
        _buildMealColumn('Dinner', 0, 'assets/images/dinner.png', false),
        _buildMealColumn('Snack', 0, 'assets/images/snack.png', false),
      ],
    ),
  );
}
Widget _buildMealColumn(String label, int calories, String imagePath, bool isActive) {
  return Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$calories',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? const Color(0xFF425E8E) : const Color(0xFF828282),
            width: 3,
          ),
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(imagePath),
          backgroundColor: Colors.white,
        ),
      ),
    ],
  );
}


  Widget _buildMealItem(String label, int calories) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            '$calories',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealImage(String imagePath, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: isActive ? Color(0xFF425E8E) : Colors.grey, width: 2),
      ),
      child: CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage(imagePath),
        backgroundColor: Colors.white,
      ),
    );
  }

 Widget _buildHeartWorkoutRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildStatCard(
        icon: Icons.favorite_border, // Changed to outline icon
        iconColor: Colors.red,
        title: 'Heart Rate',
        value: '72 BPM',
        valueColor: Colors.red,
        subtitleTop: 'Resting',
        subtitleBottom: '',
      ),
      // Add a vertical divider between cards
      Container(
        height: 160,
        width: 1,
        color: Colors.blue.withOpacity(0.2),
      ),
      _buildStatCard(
        icon: Icons.watch_later_outlined, // Changed to outline icon
        iconColor: Color(0xFF587DBD),
        title: 'Workout Time',
        value: '42 min',
        valueColor: Color(0xFF587DBD),
        subtitleTop: '35% of daily goal',
        subtitleBottom: '(2 hours)',
      ),
    ],
  );
}

Widget _buildStatCard({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String value,
  required Color valueColor,
  required String subtitleTop,
  required String subtitleBottom,
}) {
  return Container(
    width: 160,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Just the icon without a circle border
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 12),

        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Main value
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Top subtitle
        if (subtitleTop.isNotEmpty)
          Text(
            subtitleTop,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

        // Bottom subtitle
        if (subtitleBottom.isNotEmpty)
          Text(
            subtitleBottom,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
      ],
    ),
  );
}



  Widget _buildLogoutDialog() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Log out'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showLogoutDialog = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}