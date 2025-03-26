import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final int _calorieGoal = 1236;
  final int _caloriesConsumed = 654; // 220 + 498
  final int _caloriesBurned = 486;

  // Navigation items
  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Food'),
    BottomNavigationBarItem(
        icon: Icon(Icons.directions_run), label: 'Exercise'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.red),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:
                        const Text('Log out', style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      Navigator.pop(context);
                      // Add logout logic here
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Back', style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showProfileMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + button.size.width - 160,
        offset.dy + 80,
        offset.dx + 20,
        offset.dy,
      ),
      items: [
        PopupMenuItem(
          child: const Text('View profile'),
          onTap: () {
            // Add a delay to allow menu to close before navigation
            Future.delayed(const Duration(milliseconds: 10), () {
              Navigator.pushNamed(context, '/profile');
            });
          },
        ),
        PopupMenuItem(
          child: const Text('Log out', style: TextStyle(color: Colors.red)),
          onTap: () {
            // Add a delay to allow menu to close before showing dialog
            Future.delayed(const Duration(milliseconds: 10), () {
              _showLogoutDialog();
            });
          },
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate remaining calories
    final int caloriesRemaining =
        _calorieGoal - _caloriesConsumed + _caloriesBurned;
    final double calorieProgress = 1 - (caloriesRemaining / _calorieGoal);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Home page', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin header section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Hi, admin!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.notifications_none,
                              color: Colors.orange[300]),
                          const Text('(1)',
                              style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                      GestureDetector(
                        onTap: _showProfileMenu,
                        child: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 16,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Track your daily progress',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Calorie budget section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Calorie Budget',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('$_calorieGoal'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Calorie progress chart
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProgressIndicator(
                          value: calorieProgress,
                          backgroundColor: Colors.grey[200],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                          strokeWidth: 12,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$caloriesRemaining',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'kcal\nLeft',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress indicator line
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Meal tracking section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMealItem('Breakfast', 220, Icons.breakfast_dining),
                      _buildMealItem('Lunch', 498, Icons.lunch_dining),
                      _buildMealItem('Dinner', 0, Icons.dinner_dining),
                      _buildMealItem('Snack', 0, Icons.icecream),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Daily steps card
            _buildMetricCard(
              title: 'Daily steps',
              value: '7,234',
              subtitle: '75% of daily goal (10,000 steps)',
              icon: Icons.directions_walk,
              progressValue: 0.75,
              progressColor: Colors.blue,
              additionalInfo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Distance: 5.1 km'),
                  Text('Avg. Pace: 15 min/km'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Calories burned card
            _buildMetricCard(
              title: 'Calories Burned',
              value: '486',
              subtitle: '49% of daily goal (1000 kcal)',
              icon: Icons.local_fire_department_outlined,
              progressValue: 0.49,
              progressColor: Colors.orange,
              additionalInfo: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Exercises: 286 kcal'),
                  Text('BMR: 200 kcal'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Health metrics row
            Row(
              children: [
                Expanded(
                  child: _buildSimpleMetricCard(
                    title: 'Heart Rate',
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    value: '72 BPM',
                    subtitle: 'Resting',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSimpleMetricCard(
                    title: 'Workout time',
                    icon: Icons.timer_outlined,
                    iconColor: Colors.blue,
                    value: '42 min',
                    subtitle: '70% of daily goal',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Achievements section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.emoji_events, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Recent Achievements',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAchievementItem(
                    title: 'First Step',
                    subtitle: '1000 steps in a day',
                    icon: Icons.directions_walk,
                    iconBgColor: Colors.blue[100]!,
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildAchievementItem(
                    title: 'Balanced Eater',
                    subtitle: '50% macros in 7 days in a row',
                    icon: Icons.restaurant,
                    iconBgColor: Colors.green[100]!,
                    iconColor: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: _navItems,
      ),
    );
  }

  Widget _buildMealItem(String title, int calories, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$calories',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required double progressValue,
    required Color progressColor,
    required Widget additionalInfo,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: progressColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progressValue,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          additionalInfo,
        ],
      ),
    );
  }

  Widget _buildSimpleMetricCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile Page'),
      ),
    );
  }
}