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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // State variables
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
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

    // Inisialisasi animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // 1.5 detik
    );

    // Animation untuk progress calorie budget
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _initializeHomePage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

        // Mulai animasi setelah data dimuat
        _animationController.forward();
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
          'Authorization': 'Bearer $token',
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      appBar: _buildAppBar(),
      body: _buildBody(),
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
// Add this button somewhere in your UI
            ElevatedButton(
              onPressed: () {
                // Clear any cached data first
                setState(() {
                  _dashboardData = null;
                  _isLoading = true;
                });

                // Then fetch fresh data
                _refreshData();
              },
              child: Text('Refresh Dashboard'),
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
  // Removed redundant local declaration of _calculateConsumedCalories

  // Method untuk meal summary
  Widget _buildMealSummary(Map<String, dynamic> data) {
    print('Full categorized food data: ${data['categorized_food']}');

    Map<String, dynamic> categorizedFood = data['categorized_food'] ?? {};

    // Debug prints for each meal type
    print('Breakfast raw data: ${categorizedFood['Breakfast']}');
    print('Lunch raw data: ${categorizedFood['Lunch']}');
    print('Dinner raw data: ${categorizedFood['Dinner']}');
    print('Snack raw data: ${categorizedFood['Snack']}');

    int breakfastCalories =
        _calculateMealTypeCalories(categorizedFood['Breakfast'] ?? []);
    int lunchCalories =
        _calculateMealTypeCalories(categorizedFood['Lunch'] ?? []);
    int dinnerCalories =
        _calculateMealTypeCalories(categorizedFood['Dinner'] ?? []);
    int snackCalories =
        _calculateMealTypeCalories(categorizedFood['Snack'] ?? []);

    print('Calculated Breakfast Calories: $breakfastCalories');
    print('Calculated Lunch Calories: $lunchCalories');
    print('Calculated Dinner Calories: $dinnerCalories');
    print('Calculated Snack Calories: $snackCalories');

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
    print('Processing meals: $meals');

    for (var meal in meals) {
      print('Current meal: $meal');

      if (meal['food_data'] != null) {
        print('Food data exists: ${meal['food_data']}');
        if (meal['food_data']['calories'] != null) {
          int calories =
              int.tryParse(meal['food_data']['calories'].toString()) ?? 0;
          print('Parsed calories from food_data: $calories');
          totalCalories += calories;
        }
      }

      if (meal['manual_calories'] != null) {
        int manualCalories =
            double.tryParse(meal['manual_calories'].toString())?.round() ?? 0;

        print('Parsed manual calories: $manualCalories');
        totalCalories += manualCalories;
      }
    }

    print('Total calories calculated: $totalCalories');
    return totalCalories;
  }

  // Method untuk kolom makanan
// Method untuk kolom makanan dengan warna yang diperbarui
  Widget _buildMealColumn(
      String label, int calories, String imagePath, bool isActive) {
    // Tentukan warna berdasarkan label makanan
    Color mealColor;
    switch (label) {
      case 'Breakfast':
        mealColor = const Color(0xFF425E8E); // Warna untuk Breakfast
        break;
      case 'Lunch':
        mealColor = const Color(0xFF587DBD); // Warna untuk Lunch
        break;
      case 'Dinner':
        mealColor = const Color(0xFF00A991); // Warna untuk Dinner
        break;
      case 'Snack':
        mealColor = const Color(0xFF007F6D); // Warna untuk Snack
        break;
      default:
        mealColor = const Color(0xFF828282); // Warna default
    }

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
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
              // Gunakan warna yang ditentukan jika aktif, jika tidak gunakan warna abu-abu
              color: isActive ? mealColor : const Color(0xFF828282),
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

  // Method untuk steps card dengan animasi
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
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: totalSteps),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF587DBD),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  final animatedProgress = progress * _progressAnimation.value;
                  return Stack(
                    children: [
                      Container(
                        height: 8,
                        color: Colors.grey.shade200,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: (animatedProgress * 100 * 0.75)
                                .toInt()
                                .clamp(0, 100),
                            child: Container(
                                color: const Color(0xFF587DBD), height: 8),
                          ),
                          Expanded(
                            flex: (animatedProgress * 100 * 0.25)
                                .toInt()
                                .clamp(0, 100),
                            child: Container(
                                color: const Color(0xFF2CC2A1), height: 8),
                          ),
                          Expanded(
                            flex: 100 -
                                ((animatedProgress * 100).toInt().clamp(0, 100)
                                    as int),
                            child:
                                Container(color: Colors.transparent, height: 8),
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final animatedPercent =
                    (progress * 100 * _progressAnimation.value).toInt();
                return Text(
                    '$animatedPercent% of daily goal ($stepsGoal steps)');
              },
            ),
            const SizedBox(height: 12),
            Text('Distance: $distance km'),
            Text('Avg. Pace: $pace'),
          ],
        ),
      ),
    );
  }

  // Method untuk calories burned card dengan animasi
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
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: totalCaloriesBurned),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFF8800),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  final animatedProgress = progress * _progressAnimation.value;
                  return Stack(
                    children: [
                      Container(
                        height: 8,
                        color: Colors.grey.shade200,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: (animatedProgress * 100 * 0.55)
                                .toInt()
                                .clamp(0, 100),
                            child: Container(
                                color: const Color(0xFFFF8800), height: 8),
                          ),
                          Expanded(
                            flex: (animatedProgress * 100 * 0.45)
                                .toInt()
                                .clamp(0, 100),
                            child: Container(
                                color: const Color(0xFF2CC2A1), height: 8),
                          ),
                          Expanded(
                            flex: 100 -
                                ((animatedProgress * 100).toInt().clamp(0, 100)
                                    as int),
                            child:
                                Container(color: Colors.transparent, height: 8),
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final animatedPercent =
                    (progress * 100 * _progressAnimation.value).toInt();
                return Text(
                    '$animatedPercent% of daily goal ($caloriesBurnedGoal kcal)');
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Exercise', style: TextStyle(fontSize: 12)),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: exerciseCalories),
                      duration: const Duration(milliseconds: 1200),
                      builder: (context, value, child) {
                        return Text('$value kcal',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold));
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('BMR', style: TextStyle(fontSize: 12)),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: bmrCalories),
                      duration: const Duration(milliseconds: 1200),
                      builder: (context, value, child) {
                        return Text('$value kcal',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
// Method untuk Calorie Budget dengan 4 warna
Widget _buildCalorieBudget(Map<String, dynamic> data) {
  int calculateConsumedCalories(Map<String, dynamic> data) {
    int totalConsumed = 0;
    Map<String, dynamic> categorizedFood = data['categorized_food'] ?? {};

    for (var category in categorizedFood.keys) {
      List<dynamic> meals = categorizedFood[category] ?? [];
      for (var meal in meals) {
        if (meal['food_data'] != null &&
            meal['food_data']['calories'] != null) {
          totalConsumed += int.parse(meal['food_data']['calories'].toString());
        } else if (meal['manual_calories'] != null) {
          totalConsumed +=
              double.tryParse(meal['manual_calories'].toString())?.round() ?? 0;

        }
      }
    }

    return totalConsumed;
  }

  final totalBudget = data['calorie_target'] ?? 1236;
  final consumedCalories = calculateConsumedCalories(data);
  final caloriesLeft =
      totalBudget - consumedCalories > 0 ? totalBudget - consumedCalories : 0;

  // Hitung persentase kalori yang dikonsumsi
  double progress = totalBudget > 0 ? consumedCalories / totalBudget : 0;
  if (progress > 1.0) progress = 1.0; // Batasi maksimal 100%

  // Bagi progress menjadi 4 segmen dengan warna berbeda
  // Setiap segmen mendapatkan 25% dari total progress
  double segment1Progress = progress >= 0.25 ? 0.25 : progress;
  double segment2Progress =
      progress >= 0.50 ? 0.25 : (progress > 0.25 ? progress - 0.25 : 0);
  double segment3Progress =
      progress >= 0.75 ? 0.25 : (progress > 0.50 ? progress - 0.50 : 0);
  double segment4Progress = progress > 0.75 ? progress - 0.75 : 0;

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
              totalBudget.round().toString(),
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
          // Background circle (light gray)
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

          // Segment 1 - Dark Blue (425E8E) - First 25%
          SizedBox(
            height: 180,
            width: 180,
            child: CircularProgressIndicator(
              value: segment1Progress,
              strokeWidth: 28,
              backgroundColor: Colors.transparent,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF425E8E)),
            ),
          ),

          // Segment 2 - Medium Blue (587DBD) - Second 25%
          SizedBox(
            height: 180,
            width: 180,
            child: Transform.rotate(
              angle: 2 * 3.14159 * 0.25, // Rotate to start at 25%
              child: CircularProgressIndicator(
                value: segment2Progress,
                strokeWidth: 28,
                backgroundColor: Colors.transparent,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF587DBD)),
              ),
            ),
          ),

          // Segment 3 - Teal (00A991) - Third 25%
          SizedBox(
            height: 180,
            width: 180,
            child: Transform.rotate(
              angle: 2 * 3.14159 * 0.50, // Rotate to start at 50%
              child: CircularProgressIndicator(
                value: segment3Progress,
                strokeWidth: 28,
                backgroundColor: Colors.transparent,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF00A991)),
              ),
            ),
          ),

          // Segment 4 - Dark Green (007F6D) - Last 25%
          SizedBox(
            height: 180,
            width: 180,
            child: Transform.rotate(
              angle: 2 * 3.14159 * 0.75, // Rotate to start at 75%
              child: CircularProgressIndicator(
                value: segment4Progress,
                strokeWidth: 28,
                backgroundColor: Colors.transparent,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF007F6D)),
              ),
            ),
          ),

          // Center text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                caloriesLeft.round().toString(),
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
              const Text(
                'kcal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Poppins',
                  color: Colors.grey,
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
