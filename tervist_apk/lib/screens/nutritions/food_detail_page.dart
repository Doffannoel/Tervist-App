import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/api/food_database_service.dart';
import '../../models/food_database.dart';

class FoodDetailPage extends StatefulWidget {
  final FoodDatabase food;

  const FoodDetailPage({Key? key, required this.food}) : super(key: key);

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

  FoodMeasurement get selectedMeasurement =>
      widget.food.measurements[_selectedIndex];

  Future<void> _logFoodIntake() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _foodService.logFoodIntake(
        foodDataId: widget.food.id,
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
    if (hour >= 15 && hour < 20) return 'Dinner';
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
                  children: List.generate(widget.food.measurements.length, (index) {
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
                          onPressed: _servings > 0.5
                              ? () => setState(() => _servings -= 0.5)
                              : null,
                          padding: EdgeInsets.zero,
                        ),
                        Text('$_servings',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () {},
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
                      _buildSimpleNutritionFactRow('Saturated Fat',
                          '${(selectedMeasurement.saturatedFat ?? 0) * _servings}g'),
                      _buildSimpleNutritionFactRow('Polyunsaturated Fat',
                          '${(selectedMeasurement.polyunsaturatedFat ?? 0) * _servings}g'),
                      _buildSimpleNutritionFactRow('Monounsaturated Fat',
                          '${(selectedMeasurement.monounsaturatedFat ?? 0) * _servings}g'),
                      _buildSimpleNutritionFactRow('Cholesterol',
                          '${(selectedMeasurement.cholesterol ?? 0) * _servings}mg'),
                      _buildSimpleNutritionFactRow('Sodium',
                          '${(selectedMeasurement.sodium ?? 0) * _servings}mg'),
                      _buildSimpleNutritionFactRow('Fiber',
                          '${(selectedMeasurement.dietaryFiber ?? 0) * _servings}g'),
                      _buildSimpleNutritionFactRow('Sugar',
                          '${(selectedMeasurement.totalSugars ?? 0) * _servings}g'),
                      _buildSimpleNutritionFactRow('Potassium',
                          '${(selectedMeasurement.potassium ?? 0) * _servings}mg'),
                      _buildSimpleNutritionFactRow('Vitamin A',
                          '${(selectedMeasurement.vitaminA ?? 0) * _servings}μg'),
                      _buildSimpleNutritionFactRow('Vitamin C',
                          '${(selectedMeasurement.vitaminC ?? 0) * _servings}mg'),
                      _buildSimpleNutritionFactRow('Calcium',
                          '${(selectedMeasurement.calcium ?? 0) * _servings}mg'),
                      _buildSimpleNutritionFactRow('Iron',
                          '${(selectedMeasurement.iron ?? 0) * _servings}mg'),
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
            child: const Icon(Icons.local_fire_department, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calories', 
                  style: GoogleFonts.poppins(
                    fontSize: 14, 
                    color: Colors.grey[600],
                  )),
              Row(
                children: [
                  Text(
                    '${(selectedMeasurement.calories ?? 0) * _servings}',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${((selectedMeasurement.calories ?? 0) * (_servings - 1)).toInt()}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow() {
    return Row(
      children: [
        // Protein Box
        Expanded(
          child: _buildMacroBox(
            'Protein',
            '${(selectedMeasurement.protein ?? 0) * _servings}g',
            Icons.local_dining, // Replaced with a new chicken leg icon
            Colors.pink,
            '+0', // Only one +0 here
          ),
        ),
        const SizedBox(width: 8),
        // Carbs Box
        Expanded(
          child: _buildMacroBox(
            'Carbs',
            '${(selectedMeasurement.carbs ?? 0) * _servings}g',
            Icons.grain,
            Colors.orange,
            '+0', // Only one +0 here
          ),
        ),
        const SizedBox(width: 8),
        // Fats Box
        Expanded(
          child: _buildMacroBox(
            'Fats',
            '${(selectedMeasurement.fat ?? 0) * _servings}g',
            Icons.av_timer, // Replaced with avocado icon
            Colors.blue,
            '+0', // Only one +0 here
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBox(String label, String value, IconData icon, Color color, String additionalValue) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  additionalValue,
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.bold),
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
          Text(label, style: GoogleFonts.poppins(fontSize: 14)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500)),
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
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: !isSelected ? Border.all(color: Colors.grey.shade300, width: 1) : null,
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
