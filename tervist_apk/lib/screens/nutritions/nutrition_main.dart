import 'package:flutter/material.dart';
import 'package:tervist_apk/api/nutritisi_service.dart';
import 'package:tervist_apk/screens/nutritions/selected_food_page.dart';
import 'package:tervist_apk/screens/nutritions/fooddatabase_page.dart';
import 'package:tervist_apk/widgets/calendar_popup.dart';
import 'package:intl/intl.dart';
import 'scanfood.dart';

class NutritionMainPage extends StatefulWidget {
  const NutritionMainPage({super.key});

  @override
  State<NutritionMainPage> createState() => _NutritionMainPageState();
}

class _NutritionMainPageState extends State<NutritionMainPage> {
  // Date handling
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime(2025, 2, 16);

  // Nutrition data
  int caloriesLeft = 887;
  int proteinLeft = 59;
  int carbsLeft = 123;
  int fatsLeft = 22;

  // Initial values from API
  int caloriesTotal = 1236;
  int proteinTotal = 75;
  int carbsTotal = 156;
  int fatsTotal = 34;

  late final NutrisiService _nutritionService = NutrisiService();

  // Progress percentages
  double caloriesProgress = 0.28;
  double proteinProgress = 0.21;
  double carbsProgress = 0.21;
  double fatsProgress = 0.35;

  // Food data
  List<Map<String, dynamic>> _recentlyLoggedFood = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getDailySummary();
    _fetchFoodIntake();
  }

  // Fetch nutritional targets and consumption data
  Future<void> getDailySummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get nutritional targets from API
      final response = await _nutritionService.getDailySummary(_selectedDate);

      // Process response data
      setState(() {
        // Get values from API response
        caloriesTotal = response['calorie_target']?.toInt() ?? 1236;
        proteinTotal = response['protein_target']?.toInt() ?? 75;
        carbsTotal = response['carbs_target']?.toInt() ?? 156;
        fatsTotal = response['fats_target']?.toInt() ?? 34;

        // Get consumption data
        // This may vary based on your actual API response structure
        int caloriesConsumed = response['calories_consumed']?.toInt() ?? 349;
        int proteinConsumed = response['protein_consumed']?.toInt() ?? 16;
        int carbsConsumed = response['carbs_consumed']?.toInt() ?? 33;
        int fatsConsumed = response['fats_consumed']?.toInt() ?? 12;

        // Calculate remaining values
        caloriesLeft = caloriesTotal - caloriesConsumed;
        proteinLeft = proteinTotal - proteinConsumed;
        carbsLeft = carbsTotal - carbsConsumed;
        fatsLeft = fatsTotal - fatsConsumed;

        // Make sure we don't have negative values
        caloriesLeft = caloriesLeft < 0 ? 0 : caloriesLeft;
        proteinLeft = proteinLeft < 0 ? 0 : proteinLeft;
        carbsLeft = carbsLeft < 0 ? 0 : carbsLeft;
        fatsLeft = fatsLeft < 0 ? 0 : fatsLeft;

        // Calculate progress for the progress bars
        caloriesProgress =
            caloriesConsumed / (caloriesTotal > 0 ? caloriesTotal : 1);
        proteinProgress =
            proteinConsumed / (proteinTotal > 0 ? proteinTotal : 1);
        carbsProgress = carbsConsumed / (carbsTotal > 0 ? carbsTotal : 1);
        fatsProgress = fatsConsumed / (fatsTotal > 0 ? fatsTotal : 1);

        // Ensure progress doesn't exceed 1.0
        caloriesProgress = caloriesProgress > 1.0 ? 1.0 : caloriesProgress;
        proteinProgress = proteinProgress > 1.0 ? 1.0 : proteinProgress;
        carbsProgress = carbsProgress > 1.0 ? 1.0 : carbsProgress;
        fatsProgress = fatsProgress > 1.0 ? 1.0 : fatsProgress;
      });
    } catch (e) {
      print('Error fetching nutritional data: $e');
      // Handle error - show error message or retry
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch food intake data
  Future<void> _fetchFoodIntake() async {
    try {
      // Get food intake from API
      final response = await _nutritionService.getFoodIntake(_selectedDate);

      // Process food intake data
      final List<Map<String, dynamic>> foodData = [];

      for (var item in response) {
        // Extract food information from the response
        // Adjust these fields based on your actual API response structure
        Map<String, dynamic> foodItem = {
          'id': item['id'],
          'name': item['food_data'] != null
              ? item['food_data']['name']
              : 'Custom Meal',
          'calories': item['food_data'] != null
              ? item['food_data']['calories']
              : (item['manual_calories']?.toInt() ?? 0),
          'protein': item['food_data'] != null
              ? item['food_data']['protein']?.toDouble()
              : (item['manual_protein']?.toDouble() ?? 0),
          'carbs': item['food_data'] != null
              ? item['food_data']['carbs']?.toDouble()
              : (item['manual_carbs']?.toDouble() ?? 0),
          'fats': item['food_data'] != null
              ? item['food_data']['fat']?.toDouble()
              : (item['manual_fats']?.toDouble() ?? 0),
          'time': item['time'] != null
              ? DateFormat('HH:mm')
                  .format(DateTime.parse('2025-01-01T${item['time']}'))
              : '',
          'meal_type': item['meal_type'] ?? 'Meal',
        };

        foodData.add(foodItem);
      }

      setState(() {
        _recentlyLoggedFood = foodData;
      });
    } catch (e) {
      print('Error fetching food intake: $e');
      // Handle error - show error message or retry
    }
  }

  // Handle date selection
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    getDailySummary();
    _fetchFoodIntake();
  }

  // Show calendar popup
  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalendarPopup(
          initialSelectedDate: _selectedDate,
          onDateSelected: (date) {
            _onDateSelected(date);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // Change week in calendar
  void _changeWeek(int direction) {
    setState(() {
      _startDate = _startDate.add(Duration(days: direction * 7));
    });
  }

  // Show food selection options
  void _showFoodSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodDatabasePage(),
                      ),
                    ).then((_) {
                      // Refresh data when returning from food database
                      getDailySummary();
                      _fetchFoodIntake();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/fooddtbs.png', height: 24),
                        SizedBox(height: 8),
                        Text(
                          'Food Database',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanFoodPage(),
                      ),
                    ).then((_) {
                      // Refresh data when returning from scan food
                      getDailySummary();
                      _fetchFoodIntake();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/scanfood.png', height: 24),
                        SizedBox(height: 8),
                        Text(
                          'Scan Food',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final List<DateTime> currentWeek =
        List.generate(7, (i) => _startDate.add(Duration(days: i)));
    final DateTime today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/logotervist.png',
                          height: 24,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/images/fire.png', height: 20),
                              const SizedBox(width: 5),
                              const Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Calendar header
                    GestureDetector(
                      onTap: _showCalendarDialog,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat("MMMM yyyy").format(_selectedDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Week view calendar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _changeWeek(-1),
                          child: const Icon(Icons.chevron_left, size: 24),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(7, (index) {
                              final date = currentWeek[index];
                              final isSelected =
                                  date.day == _selectedDate.day &&
                                      date.month == _selectedDate.month &&
                                      date.year == _selectedDate.year;
                              final isToday = date.day == today.day &&
                                  date.month == today.month &&
                                  date.year == today.year;

                              return GestureDetector(
                                onTap: () => _onDateSelected(date),
                                child: Column(
                                  children: [
                                    Text(
                                      days[index],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.red
                                            : Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.red, width: 2)
                                            : isToday
                                                ? Border.all(
                                                    color: Colors.black,
                                                    width: 1)
                                                : Border.all(
                                                    color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(18),
                                        color: Colors.transparent,
                                      ),
                                      child: Center(
                                        child: Text(
                                          date.day.toString(),
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _changeWeek(1),
                          child: const Icon(Icons.chevron_right, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Calories left card with progress
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$caloriesLeft',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Calories left',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  value: caloriesProgress,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              ),
                              Image.asset('assets/images/fire.png', height: 24),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Macronutrients row with progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMacroCard(
                          '$proteinLeft' 'g',
                          'Proteins left',
                          'assets/images/protein.png',
                          proteinProgress,
                          Colors.red,
                        ),
                        _buildMacroCard(
                          '$carbsLeft' 'g',
                          'Carbs left',
                          'assets/images/carb.png',
                          carbsProgress,
                          Colors.amber,
                        ),
                        _buildMacroCard(
                          '$fatsLeft' 'g',
                          'Fats left',
                          'assets/images/fat.png',
                          fatsProgress,
                          Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // Recently logged section
                    const Text(
                      'Recently logged',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Recently logged food items or empty state
                    Expanded(
                      child: _recentlyLoggedFood.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F7F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "You haven't uploaded any food",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "Start tracking today's meals by taking a\nquick picture",
                                            style: TextStyle(
                                                fontSize: 14, height: 1.3),
                                          ),
                                        ],
                                      ),
                                      Transform.rotate(
                                        angle: 0.5,
                                        child: const Icon(Icons.arrow_forward,
                                            size: 24),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: _recentlyLoggedFood.length,
                              itemBuilder: (context, index) {
                                final food = _recentlyLoggedFood[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildFoodItem(food),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFoodSelection(context);
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Build macronutrient card with circular progress
  Widget _buildMacroCard(String value, String label, String imagePath,
      double progress, Color progressColor) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              Image.asset(imagePath, height: 18),
            ],
          ),
        ],
      ),
    );
  }

  // Build food item card for recently logged food
  Widget _buildFoodItem(Map<String, dynamic> food) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE2E8EF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                food['name'] ?? 'Unknown Food',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                food['time'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Image.asset("assets/images/calories_streak.png", width: 25),
              const SizedBox(width: 4),
              Text(
                '${food['calories']} calories',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  food['meal_type'] ?? 'Meal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildNutrientInfo('P', '${food['protein']}g', Colors.red),
              const SizedBox(width: 15),
              _buildNutrientInfo('C', '${food['carbs']}g', Colors.amber),
              const SizedBox(width: 15),
              _buildNutrientInfo('F', '${food['fats']}g', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  // Build nutrient info pill for food items
  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
