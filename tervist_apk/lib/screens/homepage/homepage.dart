import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/api_service.dart';
import 'package:tervist_apk/screens/login/signup_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State variables
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  final bool _showLogoutDialog = false;

  // Data containers
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _userProfileData;

  @override
  void initState() {
    super.initState();
    _initializeHomePage();
  }

  Future<void> _initializeHomePage() async {
    try {
      // Attempt to load token
      final token = await _loadToken();

      if (token != null) {
        // Fetch dashboard and profile data
        await _fetchInitialData(token);
      } else {
        // Redirect to login if no token
        _redirectToLogin();
      }
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  Future<String?> _loadToken() async {
    try {
      // Use SharedPreferences to read token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      debugPrint('Token retrieved: ${token != null ? "Found" : "Not Found"}');
      return token;
    } catch (e) {
      debugPrint('Error loading token: $e');
      return null;
    }
  }

  Future<void> _fetchInitialData(String token) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Parallel data fetching
      final results = await Future.wait(
          [_fetchDashboardData(token), _fetchUserProfile(token)]);

      setState(() {
        _dashboardData = results[0];
        _userProfileData = results[1];
        _isLoading = false;
      });
    } catch (e) {
      _handleDataFetchError(e);
    }
  }

  Future<Map<String, dynamic>> _fetchDashboardData(String token) async {
    try {
      final response = await http.get(
        ApiConfig.dashboard,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to load dashboard: ${response.body}');
      }
    } catch (e) {
      debugPrint('Dashboard fetch error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _fetchUserProfile(String token) async {
    try {
      final response = await http.get(
        ApiConfig.profile,
        headers: {
          'Authorization': 'Bearer $token', // Gunakan 'Bearer' untuk JWT
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('Profile Request Headers: ${response.request?.headers}');
      print('Profile Response Status: ${response.statusCode}');
      print('Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Profile fetch failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');

        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
      print('Profile fetch error details: $e');
      rethrow;
    }
  }

  void _handleInitializationError(dynamic error) {
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
    });
    _redirectToLogin();
  }

  void _handleDataFetchError(dynamic error) {
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
    });
  }

<<<<<<< Updated upstream
  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    });
  }

  Future<void> _handleLogout() async {
    try {
      // Clear tokens from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');

      // Redirect to login
      _redirectToLogin();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<void> _refreshData() async {
    final token = await _loadToken();
    if (token != null) {
      await _fetchInitialData(token);
    }
  }

  // Widget untuk menampilkan dialog logout
  Widget _buildLogoutDialog() {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleLogout,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Logout'),
=======
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
>>>>>>> Stashed changes
        ),
      ),
    ]
  );
}


  @override
<<<<<<< Updated upstream
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      appBar: _buildAppBar(),
      body: _buildBody(),
=======
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
>>>>>>> Stashed changes
    );
  }

  // [Sisipkan semua metode widget yang telah dibuat sebelumnya di sini]
  // Seperti _buildAppBar(), _buildProfileMenu(), _buildBody(),
  // _buildCalorieBudget(), _buildMealSummary(), dll.

  // Metode-metode widget lainnya (contoh)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF1F7F6),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Hi, ${_userProfileData?['username'] ?? 'User'}!",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
<<<<<<< Updated upstream
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text("11", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
=======
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
>>>>>>> Stashed changes
          ),
          Text(
            "Track your daily progress",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        _buildProfileMenu(),
      ],
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundImage: _userProfileData?['profile_picture'] != null
            ? NetworkImage(_userProfileData!['profile_picture'])
            : const AssetImage('assets/images/profile.png') as ImageProvider,
        radius: 20,
      ),
      onSelected: (value) {
        if (value == 'logout') {
          showDialog(context: context, builder: (_) => _buildLogoutDialog());
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'profile',
          child: Text('View profile'),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Log out', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

<<<<<<< Updated upstream
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error Loading Data',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            Text(_errorMessage),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (_dashboardData == null) {
      return const Center(child: Text('No data available'));
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCalorieBudget(_dashboardData!),
          const SizedBox(height: 24),
          _buildMealSummary(_dashboardData!),
          const SizedBox(height: 16),
          _buildStepsCard(_dashboardData!),
          const SizedBox(height: 16),
          _buildCaloriesBurnedCard(_dashboardData!),
          const SizedBox(height: 16),
          _buildHeartWorkoutRow(),
          const SizedBox(height: 16),
          _buildAchievementsCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

// Metode untuk menghitung kalori yang dikonsumsi
  int _calculateConsumedCalories(Map<String, dynamic> data) {
    int totalConsumed = 0;
    Map<String, dynamic> categorizedFood = data['categorized_food'] ?? {};

    for (var category in categorizedFood.keys) {
      List<dynamic> meals = categorizedFood[category] ?? [];
      for (var meal in meals) {
        if (meal['food_data'] != null &&
            meal['food_data']['calories'] != null) {
          totalConsumed += int.parse(meal['food_data']['calories'].toString());
        } else if (meal['manual_calories'] != null) {
          totalConsumed += int.parse(meal['manual_calories'].toString());
        }
      }
    }

    return totalConsumed;
  }

  // Method untuk meal summary
  Widget _buildMealSummary(Map<String, dynamic> data) {
    Map<String, dynamic> categorizedFood = data['categorized_food'] ?? {};

    int breakfastCalories =
        _calculateMealTypeCalories(categorizedFood['Breakfast'] ?? []);
    int lunchCalories =
        _calculateMealTypeCalories(categorizedFood['Lunch'] ?? []);
    int dinnerCalories =
        _calculateMealTypeCalories(categorizedFood['Dinner'] ?? []);
    int snackCalories =
        _calculateMealTypeCalories(categorizedFood['Snack'] ?? []);

    bool isBreakfastActive = breakfastCalories > 0;
    bool isLunchActive = lunchCalories > 0;
    bool isDinnerActive = dinnerCalories > 0;
    bool isSnackActive = snackCalories > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMealColumn('Breakfast', breakfastCalories,
              'assets/images/breakfast.png', isBreakfastActive),
          _buildMealColumn(
              'Lunch', lunchCalories, 'assets/images/lunch.png', isLunchActive),
          _buildMealColumn('Dinner', dinnerCalories, 'assets/images/dinner.png',
              isDinnerActive),
          _buildMealColumn(
              'Snack', snackCalories, 'assets/images/snack.png', isSnackActive),
        ],
      ),
    );
  }

  // Method untuk menghitung kalori per tipe makanan
  int _calculateMealTypeCalories(List<dynamic> meals) {
    int totalCalories = 0;
    for (var meal in meals) {
      if (meal['food_data'] != null && meal['food_data']['calories'] != null) {
        totalCalories += int.parse(meal['food_data']['calories'].toString());
      } else if (meal['manual_calories'] != null) {
        totalCalories += int.parse(meal['manual_calories'].toString());
      }
    }
    return totalCalories;
  }

  // Method untuk kolom makanan
  Widget _buildMealColumn(
      String label, int calories, String imagePath, bool isActive) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
=======
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
>>>>>>> Stashed changes
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
<<<<<<< Updated upstream
=======
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
>>>>>>> Stashed changes
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
<<<<<<< Updated upstream
                color: Colors.black12.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
=======
                color: Colors.grey.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isActive ? const Color(0xFF425E8E) : const Color(0xFF828282),
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
            backgroundColor: Colors.white,
=======

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
>>>>>>> Stashed changes
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

<<<<<<< Updated upstream
  // Method untuk steps card
  Widget _buildStepsCard(Map<String, dynamic> data) {
    final totalSteps = data['total_steps'] ?? 0;
    final stepsGoal = data['steps_goal'] ?? 10000;
    final progress = stepsGoal > 0 ? (totalSteps / stepsGoal) : 0;
    final percentProgress = (progress * 100).toInt();

    final distance = data['distance_km'] ?? 1.7;
    final pace = data['pace'] ?? "14 min/km";

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
                const Icon(Icons.directions_walk, color: Color(0xFF587DBD)),
                const SizedBox(width: 8),
                const Text(
                  'Daily steps',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  totalSteps.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF587DBD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    color: Colors.grey.shade200,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: (progress * 100 * 0.75).toInt().clamp(0, 100),
                        child: Container(
                            color: const Color(0xFF587DBD), height: 8),
                      ),
                      Expanded(
                        flex: (progress * 100 * 0.25).toInt().clamp(0, 100),
                        child: Container(
                            color: const Color(0xFF2CC2A1), height: 8),
                      ),
                      Expanded(
                        flex:
                            100 - (progress * 100).toInt().clamp(0, 100) as int,
                        child: Container(color: Colors.transparent, height: 8),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('$percentProgress% of daily goal ($stepsGoal steps)'),
            const SizedBox(height: 12),
            Text('Distance: $distance km'),
            Text('Avg. Pace: $pace'),
          ],
        ),
      ),
    );
  }
=======
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


>>>>>>> Stashed changes

  // Method untuk calories burned card
  Widget _buildCaloriesBurnedCard(Map<String, dynamic> data) {
    final totalCaloriesBurned = data['total_calories_burned'] ?? 0;
    final caloriesBurnedGoal = data['calories_burned_goal'] ?? 1000;
    final progress =
        caloriesBurnedGoal > 0 ? (totalCaloriesBurned / caloriesBurnedGoal) : 0;
    final percentProgress = (progress * 100).toInt();

    final exerciseCalories = data['exercise_calories'] ?? 286;
    final bmrCalories = data['bmr_calories'] ?? 200;

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
                const Icon(Icons.local_fire_department,
                    color: Color(0xFFFF8800)),
                const SizedBox(width: 8),
                const Text(
                  'Calories Burned',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  totalCaloriesBurned.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFFF8800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    color: Colors.grey.shade200,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: (progress * 100 * 0.55).toInt().clamp(0, 100),
                        child: Container(
                            color: const Color(0xFFFF8800), height: 8),
                      ),
                      Expanded(
                        flex: (progress * 100 * 0.45).toInt().clamp(0, 100),
                        child: Container(
                            color: const Color(0xFF2CC2A1), height: 8),
                      ),
                      Expanded(
                        flex:
                            100 - (progress * 100).toInt().clamp(0, 100) as int,
                        child: Container(color: Colors.transparent, height: 8),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('$percentProgress% of daily goal ($caloriesBurnedGoal kcal)'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Exercise', style: TextStyle(fontSize: 12)),
                    Text('$exerciseCalories kcal',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('BMR', style: TextStyle(fontSize: 12)),
                    Text('$bmrCalories kcal',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< Updated upstream

  // Method untuk heart dan workout row
  Widget _buildHeartWorkoutRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          icon: Icons.favorite_border,
          iconColor: Colors.red,
          title: 'Heart Rate',
          value: '72 BPM',
          valueColor: Colors.red,
          subtitleTop: 'Resting',
          subtitleBottom: '',
        ),
        Container(
          height: 160,
          width: 1,
          color: Colors.blue.withOpacity(0.2),
        ),
        _buildStatCard(
          icon: Icons.watch_later_outlined,
          iconColor: const Color(0xFF587DBD),
          title: 'Workout Time',
          value: '42 min',
          valueColor: const Color(0xFF587DBD),
          subtitleTop: '35% of daily goal',
          subtitleBottom: '(2 hours)',
        ),
      ],
    );
  }

  // Method untuk stat card
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
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
          if (subtitleTop.isNotEmpty)
            Text(
              subtitleTop,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
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

  // Method untuk achievements card
  Widget _buildAchievementsCard() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Recent Achievements',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAchievementItem(
              imagePath: 'assets/images/step.png',
              title: 'First Step',
              subtitle: 'Walk 1,000 steps in a day',
            ),
            const SizedBox(height: 12),
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

  // Method untuk achievement item
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
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

  // Method untuk Calorie Budget
  Widget _buildCalorieBudget(Map<String, dynamic> data) {
    final totalBudget = data['calorie_target'] ?? 1236;
    final consumedCalories = _calculateConsumedCalories(data);
    final caloriesLeft =
        totalBudget - consumedCalories > 0 ? totalBudget - consumedCalories : 0;

    double progress = totalBudget > 0 ? consumedCalories / totalBudget : 0;
    if (progress > 1.0) progress = 1.0;

    double darkBlueProgress = progress * 0.55;
    double lightBlueProgress = progress * 0.45;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Calorie Budget',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                totalBudget.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 28,
                backgroundColor: const Color(0xfff1f7f6),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade300),
              ),
            ),
            SizedBox(
              height: 180,
              width: 180,
              child: CircularProgressIndicator(
                value: darkBlueProgress,
                strokeWidth: 28,
                backgroundColor: Colors.transparent,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF425E8E)),
              ),
            ),
            SizedBox(
              height: 180,
              width: 180,
              child: Transform.rotate(
                angle: 2 * pi * darkBlueProgress,
                child: CircularProgressIndicator(
                  value: lightBlueProgress,
                  strokeWidth: 28,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF587DBD)),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  caloriesLeft.toString(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Text(
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
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 6),
        Center(
          child: Container(
            width: 180,
            height: 3,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }
}
=======
}
>>>>>>> Stashed changes
