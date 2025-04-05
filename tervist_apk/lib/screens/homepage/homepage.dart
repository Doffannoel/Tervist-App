import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    return Card(
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
                Icon(Icons.directions_walk, color: Colors.blue),
                SizedBox(width: 8),
                Text('Daily steps',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text('7,234',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.72,
              backgroundColor: const Color.fromARGB(255, 25, 167, 77),
              color: const Color.fromARGB(255, 70, 129, 248),
              minHeight: 6,
            ),
            SizedBox(height: 4),
            Text('72% of daily goal (10,000 steps)'),
            SizedBox(height: 8),
            Text('Distance: 1.7 km'),
            Text('Avg. Pace: 14 min/km'),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesBurnedCard() {
    return Card(
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
                Icon(Icons.local_fire_department, color: Colors.orange),
                SizedBox(width: 8),
                Text('Calories Burned',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text('486',
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.48,
              backgroundColor: const Color.fromARGB(255, 26, 153, 47),
              color: const Color.fromARGB(255, 245, 169, 39),
              minHeight: 6,
            ),
            SizedBox(height: 4),
            Text('48% of daily goal (1000 kcal)'),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exercise\n286 kcal',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  children: [
                    Text('BMR'),
                    SizedBox(height: 4),
                    Container(height: 4, width: 80, color: Colors.black),
                    SizedBox(height: 4),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFEBFDFA), // Changed background color to F1F7F6
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
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12), // was: EdgeInsets.all(16)
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildCalorieBudget(),
                      SizedBox(height: 24), // was: 16
                      _buildMealSummary(),
                      SizedBox(height: 24),
                      _buildStepsCard(),
                      SizedBox(height: 24),
                      _buildCaloriesBurnedCard(),
                      SizedBox(height: 24),
                      _buildHeartWorkoutRow(),
                      SizedBox(height: 24),
                      _buildAchievementsCard(),
                      SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
            if (_showLogoutDialog) _buildLogoutDialog(),
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
        SizedBox(height: 40),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMealItem('Breakfast', 220, 'assets/images/breakfast.png',
              const Color(0xFF425E8E)),
          _buildMealItem(
              'Lunch', 498, 'assets/images/lunch.png', const Color(0xFF587DBD)),
          _buildMealItem(
              'Dinner', 0, 'assets/images/dinner.png', const Color(0xFF828282)),
          _buildMealItem(
              'Snack', 0, 'assets/images/snack.png', const Color(0xFF828282)),
        ],
      ),
    );
  }

  Widget _buildMealItem(
      String label, int calories, String imagePath, Color borderColor) {
    return Column(
      children: [
        // Label makanan
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 6),

        // Kotak kalori
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(0, 3),
                blurRadius: 6,
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

        // Gambar makanan dengan border lingkaran
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 4),
          ),
          child: CircleAvatar(
            radius: 38, // Ukuran lebih besar
            backgroundImage: AssetImage(imagePath),
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHeartWorkoutRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMiniCard(
          icon: Icons.favorite_border,
          iconColor: Colors.red,
          title: 'Heart Rate',
          value: '72 BPM',
          valueColor: Colors.red,
          subtitle: 'Resting',
        ),
        _buildMiniCard(
          icon: Icons.timer_outlined,
          iconColor: Colors.blue,
          title: 'Workout Time',
          value: '42 min',
          valueColor: Colors.blue,
          subtitle: '35% of daily goal\n(2 hours)',
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                )),
            SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title,
      required String value,
      required String subtitle}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subtitle),
          ],
        ),
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
