import 'package:flutter/material.dart';
import 'package:tervist_apk/api/nutritisi_service.dart';
import 'package:tervist_apk/screens/nutritions/selected_food_page.dart';
import 'package:tervist_apk/screens/nutritions/fooddatabase_page.dart';
import 'package:tervist_apk/widgets/calendar_popup.dart';
import 'package:intl/intl.dart';
import 'scanfood.dart';
import 'package:tervist_apk/screens/nutritions/streak_popup_dialog.dart';
import 'package:dotted_border/dotted_border.dart';

class NutritionMainPage extends StatefulWidget {
  const NutritionMainPage({super.key});

  @override
  State<NutritionMainPage> createState() => _NutritionMainPageState();
}

class _NutritionMainPageState extends State<NutritionMainPage>
    with SingleTickerProviderStateMixin {
  // Date handling
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime(2025, 2, 16);
  late AnimationController _animationController;
  late Animation<double> _caloriesAnimation;
  late Animation<double> _proteinAnimation;
  late Animation<double> _carbsAnimation;
  late Animation<double> _fatsAnimation;

  CalendarDayStatus _getDayStatus(DateTime date) {
    if (_dayStatusCache.containsKey(date)) {
      return _dayStatusCache[date]!;
    }

    final DateTime checkDate = DateTime(date.year, date.month, date.day);
    final DateTime today = DateTime.now();
    final bool isToday = checkDate.day == today.day &&
        checkDate.month == today.month &&
        checkDate.year == today.year;

    bool hasFoodEntries = false;
    double totalCalories = 0;

    if (_foodIntakeCache.containsKey(checkDate)) {
      List<Map<String, dynamic>> foodEntries = _foodIntakeCache[checkDate]!;
      hasFoodEntries = foodEntries.isNotEmpty;

      for (var food in foodEntries) {
        totalCalories += food['calories'] ?? 0;
      }
    } else {
      hasFoodEntries = false;
      totalCalories = 0;
    }

    // Ini diperbaiki
    bool meetsCalorieTarget = totalCalories >= caloriesTotal;

    CalendarDayStatus status;
    if (isToday) {
      status = meetsCalorieTarget
          ? CalendarDayStatus.blackSolid
          : CalendarDayStatus
              .redSolid; // <-- kalau TODAY & TIDAK MEET TARGET, HARUS RED SOLID, bukan blackDashed
    } else if (hasFoodEntries) {
      status = meetsCalorieTarget
          ? CalendarDayStatus.graySolid
          : CalendarDayStatus.redSolid;
    } else {
      status = CalendarDayStatus.grayDashed;
    }

    _dayStatusCache[checkDate] = status;
    return status;
  }

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

  // Food intake cache to reduce API calls
  final Map<DateTime, List<Map<String, dynamic>>> _foodIntakeCache = {};
// Status cache per date to reduce repeated calculations
  final Map<DateTime, CalendarDayStatus> _dayStatusCache = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _caloriesAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    _proteinAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    _carbsAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    _fatsAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    getDailySummary();
    _fetchFoodIntake();
  }

  Future<void> _fetchFoodIntakeForMonth(DateTime month) async {
    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      for (int i = 0; i <= lastDay.day - 1; i++) {
        final date = firstDay.add(Duration(days: i));

        final response = await _nutritionService.getFoodIntake(date);
        final List<Map<String, dynamic>> foodData = [];

        double totalCalories = 0;
        for (var item in response) {
          double calories = (item['manual_calories'] ?? 0).toDouble();
          foodData.add({'calories': calories});
          totalCalories += calories;
        }

        _foodIntakeCache[date] = foodData;
        _dayStatusCache.remove(date); // Reset status buat di-recompute
      }

      setState(() {});
    } catch (e) {
      print('Error fetching month food intake: $e');
    }
  }

  //Refresh
  Future<void> _refreshData() async {
    await getDailySummary();
    await _fetchFoodIntake();

    _dayStatusCache.clear(); // Reset cache status hari
    setState(() {}); // Refresh UI
    if (mounted) {
      setState(() {});
      _animationController.reset();
      _animationController
          .forward(); // Tambahin ini biar animasi jalan lagi habis refresh
    }
  }

  // Fetch nutritional targets and consumption data
  Future<void> getDailySummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get nutritional targets from API
      final response = await _nutritionService.getDailySummary(_selectedDate);

      // Debug print to check response
      print('API Response: $response');

      // Process response data
      setState(() {
        // Get values from API response
        caloriesTotal =
            (response['calorie_target']?.toDouble()?.ceil() ?? 1236);
        proteinTotal = response['protein_target']?.toInt() ?? 75;
        carbsTotal = response['carbs_target']?.toInt() ?? 156;
        fatsTotal = response['fats_target']?.toInt() ?? 34;

        // Print targets
        print(
            'Targets - Cal: $caloriesTotal, Pro: $proteinTotal, Carb: $carbsTotal, Fat: $fatsTotal');

        // Get consumption data
        int caloriesConsumed = response['calories_consumed']?.toInt() ?? 349;
        int proteinConsumed = response['protein_consumed']?.toInt() ?? 16;
        int carbsConsumed = response['carbs_consumed']?.toInt() ?? 33;
        int fatsConsumed = response['fats_consumed']?.toInt() ?? 12;

        // Print consumption values
        print(
            'Consumed - Cal: $caloriesConsumed, Pro: $proteinConsumed, Carb: $carbsConsumed, Fat: $fatsConsumed');

        // Calculate remaining values
        caloriesLeft = caloriesTotal - caloriesConsumed;
        proteinLeft = proteinTotal - proteinConsumed;
        carbsLeft = carbsTotal - carbsConsumed;
        fatsLeft = fatsTotal - fatsConsumed;

        // Print remaining values
        print(
            'Left - Cal: $caloriesLeft, Pro: $proteinLeft, Carb: $carbsLeft, Fat: $fatsLeft');

        // Jgn sampai negative values
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

        // Print progress values
        print(
            'Progress - Cal: $caloriesProgress, Pro: $proteinProgress, Carb: $carbsProgress, Fat: $fatsProgress');

        // Ensure progress doesn't exceed 1.0
        caloriesProgress = caloriesProgress > 1.0 ? 1.0 : caloriesProgress;
        proteinProgress = proteinProgress > 1.0 ? 1.0 : proteinProgress;
        carbsProgress = carbsProgress > 1.0 ? 1.0 : carbsProgress;
        fatsProgress = fatsProgress > 1.0 ? 1.0 : fatsProgress;
      });

      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _animationController.reset();
          _animationController.forward();
        }
      });
    } catch (e) {
      print('Error fetching nutritional data: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch food intake data
  Future<void> _fetchFoodIntake() async {
    try {
      final response = await _nutritionService.getFoodIntake(_selectedDate);
      final List<Map<String, dynamic>> foodData = [];

      // For manual calculation
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFats = 0;

      for (var item in response) {
        // Parse serving size (default to 1 if invalid)
        final servingSize =
            double.tryParse(item['serving_size']?.toString() ?? '1') ?? 1;

        // Get nutrition values
        double calories, protein, carbs, fats;

        if (item['manual_calories'] != null) {
          // Use manual values if available
          calories = (item['manual_calories'] as num).toDouble();
          protein = (item['manual_protein'] as num).toDouble();
          carbs = (item['manual_carbs'] as num).toDouble();
          fats = (item['manual_fats'] as num).toDouble();
        } else {
          // Use first measurement if no manual values
          final measurements = item['food_data']?['measurements'] ?? [];
          final firstMeasurement =
              measurements.isNotEmpty ? measurements[0] : null;

          calories =
              (firstMeasurement?['calories'] ?? 0).toDouble() * servingSize;
          protein =
              (firstMeasurement?['protein'] ?? 0).toDouble() * servingSize;
          carbs = (firstMeasurement?['carbs'] ?? 0).toDouble() * servingSize;
          fats = (firstMeasurement?['fat'] ?? 0).toDouble() *
              servingSize; // Note: 'fat' not 'fats'
        }

        // Add to totals
        totalCalories += calories;
        totalProtein += protein;
        totalCarbs += carbs;
        totalFats += fats;

        // Format time
        String formattedTime = '';
        try {
          if (item['time'] != null) {
            formattedTime = DateFormat('HH:mm').format(
                DateFormat('HH:mm:ss').parse(item['time'].split('.')[0]));
          }
        } catch (e) {
          print('Error parsing time: ${item['time']}');
        }

        Map<String, dynamic> foodItem = {
          'id': item['id'],
          'name': item['name'] ?? item['food_data']?['name'] ?? 'Custom Meal',
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fats': fats,
          'time': formattedTime,
          'meal_type': item['meal_type'] ?? 'Meal',
        };

        foodData.add(foodItem);
      }

      setState(() {
        _foodIntakeCache[_selectedDate] = foodData;
        _dayStatusCache.remove(_selectedDate);
        _recentlyLoggedFood = foodData;

        // Update progress manually if API isn't providing correct data
        print(
            'Manually calculated - Cal: $totalCalories, Pro: $totalProtein, Carb: $totalCarbs, Fat: $totalFats');

        // Calculate remaining values
        caloriesLeft = caloriesTotal - totalCalories.toInt();
        proteinLeft = proteinTotal - totalProtein.toInt();
        carbsLeft = carbsTotal - totalCarbs.toInt();
        fatsLeft = fatsTotal - totalFats.toInt();

        // Make sure we don't have negative values
        caloriesLeft = caloriesLeft < 0 ? 0 : caloriesLeft;
        proteinLeft = proteinLeft < 0 ? 0 : proteinLeft;
        carbsLeft = carbsLeft < 0 ? 0 : carbsLeft;
        fatsLeft = fatsLeft < 0 ? 0 : fatsLeft;

        // Calculate progress for the progress bars
        caloriesProgress =
            totalCalories / (caloriesTotal > 0 ? caloriesTotal : 1);
        proteinProgress = totalProtein / (proteinTotal > 0 ? proteinTotal : 1);
        carbsProgress = totalCarbs / (carbsTotal > 0 ? carbsTotal : 1);
        fatsProgress = totalFats / (fatsTotal > 0 ? fatsTotal : 1);

        // Ensure progress doesn't exceed 1.0
        caloriesProgress = caloriesProgress > 1.0 ? 1.0 : caloriesProgress;
        proteinProgress = proteinProgress > 1.0 ? 1.0 : proteinProgress;
        carbsProgress = carbsProgress > 1.0 ? 1.0 : carbsProgress;
        fatsProgress = fatsProgress > 1.0 ? 1.0 : fatsProgress;
      });
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      print('Error fetching food intake: $e');
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
  void _showCalendarDialog() async {
    await _fetchFoodIntakeForMonth(_selectedDate);

    Map<DateTime, CalendarDayStatus> dayStatuses = {};

    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, i);
      dayStatuses[date] = _getDayStatus(date);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalendarPopup(
          initialSelectedDate: _selectedDate,
          dayStatuses: dayStatuses,
          onDateSelected: (date) {
            _onDateSelected(date);
            Navigator.pop(context);
          },
        );
      },
    );
  }

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
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 150),
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
                    ).then((result) {
                      _refreshData(); // ini yang aku maksud
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
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: Color(0xFFF1F7F6),
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
                            height: 28,
                          ),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
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
                                  Image.asset('assets/images/fireon.png',
                                      height: 16),
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
                      const SizedBox(height: 24),

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

                                final status = _getDayStatus(date);

                                Color borderColor;
                                bool isDashed;
                                double borderWidth;

                                switch (status) {
                                  case CalendarDayStatus.redSolid:
                                    borderColor = Colors.red;
                                    isDashed = false;
                                    borderWidth = 2.0;
                                    break;
                                  case CalendarDayStatus.graySolid:
                                    borderColor = Colors.grey;
                                    isDashed = false;
                                    borderWidth = 1.0;
                                    break;
                                  case CalendarDayStatus.grayDashed:
                                    borderColor = Colors.grey;
                                    isDashed = true;
                                    borderWidth = 1.0;
                                    break;
                                  case CalendarDayStatus.blackDashed:
                                    borderColor = Colors.black;
                                    isDashed = true;
                                    borderWidth = 1.0;
                                    break;
                                  case CalendarDayStatus.blackSolid:
                                    borderColor = Colors.black;
                                    isDashed = false;
                                    borderWidth = 1.0;
                                    break;
                                }

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
                                      isDashed
                                          ? DottedBorder(
                                              borderType: BorderType.Circle,
                                              color: borderColor,
                                              strokeWidth: borderWidth,
                                              dashPattern: const [3, 2],
                                              child: SizedBox(
                                                width: 34,
                                                height: 34,
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
                                            )
                                          : Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: borderColor,
                                                  width: borderWidth,
                                                ),
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
                                  child: AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return CircularProgressIndicator(
                                        value: caloriesProgress *
                                            _caloriesAnimation
                                                .value, // <<<<<< pakai animasi di sini
                                        strokeWidth: 8,
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.2),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                      );
                                    },
                                  ),
                                ),
                                Image.asset('assets/images/fire.png',
                                    height: 24),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align all cards to the top
                        children: [
                          _buildMacroCard(
                            '${proteinLeft}g',
                            'Proteins left',
                            'assets/images/protein.png',
                            proteinProgress,
                            Colors.red,
                          ),
                          _buildMacroCard(
                            '${carbsLeft}g',
                            'Carbs left',
                            'assets/images/carb.png',
                            carbsProgress,
                            Colors.amber,
                          ),
                          _buildMacroCard(
                            '${fatsLeft}g',
                            'Fats left',
                            'assets/images/fat.png',
                            fatsProgress,
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Recently logged section
                      const Text(
                        'Recently logged',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Recently logged food items or empty state
                      Expanded(
                        child: _recentlyLoggedFood.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F7F6),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                      fontSize: 14,
                                                      height: 1.3),
                                                ),
                                              ],
                                            ),
                                            Transform.rotate(
                                              angle: 0.5,
                                              child: const Icon(
                                                  Icons.arrow_forward,
                                                  size: 24),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 100),
                                ],
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 20),
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

  // Build macronutrient card to match the image
  Widget _buildMacroCard(String value, String label, String imagePath,
      double progress, Color progressColor) {
    return Container(
      width: 115,
      height: 150,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    width: 50,
                    height: 50,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: progress * _animationController.value,
                          strokeWidth: 5,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(progressColor),
                        );
                      },
                    )),
                Image.asset(imagePath, height: 20),
              ],
            ),
          ),
          const SizedBox(height: 4),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  food['time'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
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
              _buildNutrientInfo(
                  'C', '${food['carbs'].toStringAsFixed(1)}g', Colors.amber),
              const SizedBox(width: 15),
              _buildNutrientInfo('F', '${food['fats']}g', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Row(
      children: [
        Image.asset(
          label == 'P'
              ? 'assets/images/protein.png'
              : label == 'C'
                  ? 'assets/images/carb.png'
                  : label == 'F'
                      ? 'assets/images/fat.png'
                      : 'assets/images/fat.png',
          height: 16,
          width: 16,
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
