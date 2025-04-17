import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/api/food_database_service.dart';
import '../../models/food_database.dart';

class FoodDetailPage extends StatefulWidget {
  final FoodDatabase food;

  const FoodDetailPage({super.key, required this.food});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late int _selectedIndex;
  late double _servings;
  final FoodDatabaseService _foodService = FoodDatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _servings = 1.0;
    _selectedIndex = 0;
  }

  void _increaseServing() {
    setState(() {
      _servings = (_servings + 1).toInt().toDouble();
    });
  }

  void _decreaseServing() {
    if (_servings > 1) {
      setState(() {
        _servings = (_servings - 1).toInt().toDouble();
      });
    }
  }

  FoodMeasurement get selectedMeasurement =>
      widget.food.measurements[_selectedIndex];

  // Helper function to format nutrition values without .0 for whole numbers
  String formatNutritionValue(double value, String unit) {
    if (value == value.toInt().toDouble()) {
      // If the value is a whole number (e.g., 34.0), show as integer
      return '${value.toInt()}$unit';
    } else {
      // If it has decimal places, round to 1 decimal place
      return '${value.toStringAsFixed(1)}$unit';
    }
  }

  Future<void> _logFoodIntake() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _foodService.logFoodIntake(
        foodDataId: widget.food.id,
        measurementId: _selectedIndex, //biar bisa ikut measurmeent nya
        mealType: _getMealTypeBasedOnTime(),
        servingSize: _servings.toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.food.name} added to your food log')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging food: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getMealTypeBasedOnTime() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 10) return 'Breakfast';
    if (hour >= 10 && hour < 15) return 'Lunch';
    // aku aganti dari & jadi ||
    if (hour >= 15 || hour < 2) return 'Dinner';
    return 'Snack';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Selected food',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.food.name,
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Measurement',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      List.generate(widget.food.measurements.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: MeasurementButton(
                        label: widget.food.measurements[index].label,
                        isSelected: _selectedIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Number of Servings',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed:
                              _servings > 1 ? () => _decreaseServing() : null,
                          padding: EdgeInsets.zero,
                        ),
                        Text('${_servings.toInt()}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add,
                              size: 18), // Changed from edit to add icon
                          onPressed: () => _increaseServing(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCaloriesBox(),
              const SizedBox(height: 16),
              _buildMacroRow(),
              const SizedBox(height: 16),
              Text('Other nutrition facts',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSimpleNutritionFactRow(
                          'Saturated Fat',
                          formatNutritionValue(
                              (selectedMeasurement.saturatedFat ?? 0) *
                                  _servings,
                              'g')),
                      _buildSimpleNutritionFactRow(
                          'Polyunsaturated Fat',
                          formatNutritionValue(
                              (selectedMeasurement.polyunsaturatedFat ?? 0) *
                                  _servings,
                              'g')),
                      _buildSimpleNutritionFactRow(
                          'Monounsaturated Fat',
                          formatNutritionValue(
                              (selectedMeasurement.monounsaturatedFat ?? 0) *
                                  _servings,
                              'g')),
                      _buildSimpleNutritionFactRow(
                          'Cholesterol',
                          formatNutritionValue(
                              (selectedMeasurement.cholesterol ?? 0) *
                                  _servings,
                              'mg')),
                      _buildSimpleNutritionFactRow(
                          'Sodium',
                          formatNutritionValue(
                              (selectedMeasurement.sodium ?? 0) * _servings,
                              'mg')),
                      _buildSimpleNutritionFactRow(
                          'Fiber',
                          formatNutritionValue(
                              (selectedMeasurement.dietaryFiber ?? 0) *
                                  _servings,
                              'g')),
                      _buildSimpleNutritionFactRow(
                          'Sugar',
                          formatNutritionValue(
                              (selectedMeasurement.totalSugars ?? 0) *
                                  _servings,
                              'g')),
                      _buildSimpleNutritionFactRow(
                          'Potassium',
                          formatNutritionValue(
                              (selectedMeasurement.potassium ?? 0) * _servings,
                              'mg')),
                      _buildSimpleNutritionFactRow(
                          'Vitamin A',
                          formatNutritionValue(
                              (selectedMeasurement.vitaminA ?? 0) * _servings,
                              'μg')),
                      _buildSimpleNutritionFactRow(
                          'Vitamin C',
                          formatNutritionValue(
                              (selectedMeasurement.vitaminC ?? 0) * _servings,
                              'mg')),
                      _buildSimpleNutritionFactRow(
                          'Calcium',
                          formatNutritionValue(
                              (selectedMeasurement.calcium ?? 0) * _servings,
                              'mg')),
                      _buildSimpleNutritionFactRow(
                          'Iron',
                          formatNutritionValue(
                              (selectedMeasurement.iron ?? 0) * _servings,
                              'mg')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _logFoodIntake,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('Log',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildCaloriesBox() {
    // Calculate the additional calories based on servings
    num? caloriesValue = selectedMeasurement.calories;
    int baseCalories = caloriesValue.toInt() ?? 0;
    int additionalCalories =
        _servings > 1 ? ((baseCalories * _servings).toInt() - baseCalories) : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_fire_department,
                color: Colors.black, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calories',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    )),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        formatNutritionValue(baseCalories * _servings, ''),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Visibility(
                      visible: _servings > 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${formatNutritionValue(additionalCalories.toDouble(), '')}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow() {
    // Calculate additional values for protein, carbs, and fats
    num? proteinValue = selectedMeasurement.protein;
    double baseProtein = proteinValue.toDouble() ?? 0;
    double additionalProtein =
        _servings > 1 ? (baseProtein * _servings - baseProtein) : 0;

    num? carbsValue = selectedMeasurement.carbs;
    double baseCarbs = carbsValue.toDouble() ?? 0;
    double additionalCarbs =
        _servings > 1 ? (baseCarbs * _servings - baseCarbs) : 0;

    num? fatValue = selectedMeasurement.fat;
    double baseFat = fatValue.toDouble() ?? 0;
    double additionalFat = _servings > 1 ? (baseFat * _servings - baseFat) : 0;

    return Row(
      children: [
        // Protein Box
        Expanded(
          child: _buildMacroBox(
            'Protein',
            formatNutritionValue(baseProtein * _servings, 'g'),
            Icons.local_dining,
            Colors.pink,
            '+${formatNutritionValue(additionalProtein, '')}',
          ),
        ),
        const SizedBox(width: 8),
        // Carbs Box
        Expanded(
          child: _buildMacroBox(
            'Carbs',
            formatNutritionValue(baseCarbs * _servings, 'g'),
            Icons.grain,
            Colors.orange,
            '+${formatNutritionValue(additionalCarbs, '')}',
          ),
        ),
        const SizedBox(width: 8),
        // Fats Box
        Expanded(
          child: _buildMacroBox(
            'Fats',
            formatNutritionValue(baseFat * _servings, 'g'),
            Icons.av_timer,
            Colors.blue,
            '+${formatNutritionValue(additionalFat, '')}',
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBox(String label, String value, IconData icon, Color color,
      String additionalValue) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Use a fixed width container or FittedBox to ensure text fits
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Visibility(
                  visible: _servings > 1,
                  child: Text(
                    additionalValue,
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleNutritionFactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class MeasurementButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MeasurementButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: !isSelected
              ? Border.all(color: Colors.grey.shade300, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
