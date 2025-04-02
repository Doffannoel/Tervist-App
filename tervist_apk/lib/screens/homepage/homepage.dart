import 'package:flutter/material.dart';

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
  return Card(
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
              Text('Daily steps', style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Text('7,234', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
              Text('Calories Burned', style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Text('486', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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
              Text('Exercise\n286 kcal', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: [
                  Text('BMR'),
                  SizedBox(height: 4),
                  Container(height: 4, width: 80, color: Colors.black),
                  SizedBox(height: 4),
                  Text('200 kcal', style: TextStyle(fontWeight: FontWeight.bold)),
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
              imagePath: 'images/step.png',
              title: 'First Step',
              subtitle: 'Walk 1,000 steps in a day',
            ),
            SizedBox(height: 12),
            _buildAchievementItem(
              imagePath: 'images/fnb.png',
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text("Hi, admin!",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.local_fire_department, color: Colors.orange),
            Text("11", style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundImage: AssetImage('images/profile.png'),
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
                child: Text('Log out', style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildCalorieBudget(),
                      SizedBox(height: 16),
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
                    ]),
                  ),
                ),
              ],
            ),
            if (_showLogoutDialog) _buildLogoutDialog(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true, // Hanya label aktif (home) yang tampil
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieBudget() {
    return Column(
      children: [
        Text('Your Calorie Budget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                value: 582 / 1236,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),
            Column(
              children: [
                Text('582',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('kcal Left'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMealItem('Breakfast', 220, 'images/breakfast.png'),
        _buildMealItem('Lunch', 498, 'images/lunch.png'),
        _buildMealItem('Dinner', 0, 'images/dinner.png'),
        _buildMealItem('Snack', 0, 'images/snack.png'),
      ],
    );
  }

  Widget _buildMealItem(String label, int cal, String assetPath) {
    return Column(
      children: [
        CircleAvatar(radius: 30, backgroundImage: AssetImage(assetPath)),
        SizedBox(height: 4),
        Text(label),
        Text('$cal kcal', style: TextStyle(fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 32),
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
