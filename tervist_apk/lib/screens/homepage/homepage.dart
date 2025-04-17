import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/api_service.dart';
import 'package:tervist_apk/screens/login/signup_screen.dart';
import 'package:tervist_apk/screens/main_navigation.dart';
import 'package:tervist_apk/screens/nutritions/streak_popup_dialog.dart';
import 'package:tervist_apk/screens/profile/userprofile_page.dart';

// Custom shape class for the popup menu with a "tail" pointing to the profile picture
class TooltipShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double radius = 25.0;
    final double tailSize = 15.0;
    final double tailXPosition =
        rect.width * 0.75; // Position from the left side

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      // Add the tail at the top of the popup
      ..moveTo(tailXPosition, rect.top)
      ..lineTo(tailXPosition + tailSize, rect.top - tailSize)
      ..lineTo(tailXPosition + tailSize * 2, rect.top)
      ..close();

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

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
      // Add timestamp to prevent caching
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final today = DateTime.now();
      final formattedDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      final dashboardUri = Uri.parse(
          '${ApiConfig.dashboard.toString()}?date=$formattedDate&t=${DateTime.now().millisecondsSinceEpoch}');
      final response = await http.get(
        dashboardUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store',
          'Pragma': 'no-cache',
        },
      ).timeout(const Duration(seconds: 15));

      print('Dashboard Request URL: $dashboardUri');
      print('Dashboard Response Status: ${response.statusCode}');

      // Debug response body (limited to avoid log overflow)
      if (response.body.isNotEmpty) {
        final previewLength =
            response.body.length > 300 ? 300 : response.body.length;
        print(
            'Dashboard Response Preview: ${response.body.substring(0, previewLength)}...');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debug food data
        if (data.containsKey('categorized_food')) {
          print('Food data found:');
          final foodData = data['categorized_food'];
          foodData.forEach((mealType, meals) {
            print('$mealType: ${meals.length} items');
          });
        } else {
          print('No categorized_food data in response');
        }

        return data;
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
      backgroundColor: Colors.white,
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
      automaticallyImplyLeading: false,
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
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const StreakPopupDialog();
                    },
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/images/fireon.png', height: 16),
                      const SizedBox(width: 4),
                      const Text(
                        '1',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
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
    return Theme(
      // Override popup menu theme to add a custom shape with a "tail"
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: TooltipShape(),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        color: Colors.white,
        offset: const Offset(-15, 50),
        elevation: 5,
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
          PopupMenuItem<String>(
            value: 'profile',
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: const Center(
              child: Text(
                'View profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            onTap: () {
              // Use a small delay to allow the menu to close before navigation
              Future.delayed(
                const Duration(milliseconds: 10),
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          const MainNavigation(initialIndex: 3)),
                ),
              );
            },
          ),
          const PopupMenuItem<String>(
            value: 'logout',
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Center(
              child: Text(
                'Log out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
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

    // Verify the total calories match what's expected in the nutrition view
    int totalCalculatedCalories =
        breakfastCalories + lunchCalories + dinnerCalories + snackCalories;
    print(
        'Total calculated calories across all meals: $totalCalculatedCalories');

    // Define active states based on calories or food items
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

// Method untuk menghitung kalori per tipe makanan - FIXED VERSION
  int _calculateMealTypeCalories(List<dynamic> meals) {
    int totalCalories = 0;
    print('Processing meals: $meals');

    for (var meal in meals) {
      print('Current meal: $meal');

      // IMPORTANT: Only use one source of calories per meal
      // Option 1: Use manual calories if available (priority)
      if (meal['manual_calories'] != null) {
        int manualCalories =
            double.tryParse(meal['manual_calories'].toString())?.round() ?? 0;
        print('Using manual calories only: $manualCalories');
        totalCalories += manualCalories;
      }
      // Option 2: Fall back to food_data measurements ONLY if manual_calories is not set
      else if (meal['food_data'] != null) {
        print('No manual calories, using food data: ${meal['food_data']}');

        // Check if measurements exist and has items
        if (meal['food_data']['measurements'] != null &&
            meal['food_data']['measurements'] is List &&
            (meal['food_data']['measurements'] as List).isNotEmpty) {
          // Get the first measurement (usually the default one)
          var measurement = meal['food_data']['measurements'][0];

          if (measurement['calories'] != null) {
            // Parse serving size (default to 1 if not specified)
            double servingSize =
                double.tryParse(meal['serving_size']?.toString() ?? '1') ?? 1.0;

            double calories =
                double.tryParse(measurement['calories'].toString()) ?? 0;
            double calculatedCalories = calories * servingSize;
            print(
                'Parsed calories from measurement: $calories with serving size $servingSize = $calculatedCalories');
            totalCalories += calculatedCalories.round();
          }
        }
      }
    }

    print('Total calories calculated: $totalCalories');
    return totalCalories;
  }

  // Method untuk Calorie Budget dengan 4 warna
  Widget _buildCalorieBudget(Map<String, dynamic> data) {
    int calculateConsumedCalories(Map<String, dynamic> data) {
      int totalConsumed = 0;
      Map<String, dynamic> categorizedFood = data['categorized_food'] ?? {};

      // Only iterate through each category's meals once
      for (var category in categorizedFood.keys) {
        List<dynamic> meals = categorizedFood[category] ?? [];
        // Use the _calculateMealTypeCalories method for consistent calculation
        int categoryCalories = _calculateMealTypeCalories(meals);
        print('Category $category calories: $categoryCalories');
        totalConsumed += categoryCalories;
      }

      print('Total consumed calories: $totalConsumed');
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

  // Method untuk kolom makanan
// Modified _buildMealColumn method to change calorie box color
  Widget _buildMealColumn(
      String label, int calories, String imagePath, bool isActive) {
    // Determine color based on label meal type
    Color mealColor;
    switch (label) {
      case 'Breakfast':
        mealColor = const Color(0xFF425E8E); // Color for Breakfast
        break;
      case 'Lunch':
        mealColor = const Color(0xFF587DBD); // Color for Lunch
        break;
      case 'Dinner':
        mealColor = const Color(0xFF00A991); // Color for Dinner
        break;
      case 'Snack':
        mealColor = const Color(0xFF007F6D); // Color for Snack
        break;
      default:
        mealColor = const Color(0xFF828282); // Default color
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
            color: isActive ? const Color(0xFFE2E8EF) : Colors.white,
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
              // Use defined color if active, otherwise gray
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
                    '$animatedPercent% of daily goal (${stepsGoal.ceil()} steps)');
              },
            ),
            const SizedBox(height: 12),
            Text('Distance: ${distance.ceil()} km'),
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
                    '$animatedPercent% of daily goal (${caloriesBurnedGoal.ceil()} kcal)');
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
