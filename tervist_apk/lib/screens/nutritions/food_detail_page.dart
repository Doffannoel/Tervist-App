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
      backgroundColor: Colors.white,
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
              const SizedBox(height: 20),
              Text(widget.food.name,
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('Measurement',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Number of Servings',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 16),
                          onPressed: _servings > 0.5
                              ? () => setState(() => _servings -= 0.5)
                              : null,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        Text(_servings.toString(),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500)),
                        IconButton(
                          icon: Icon(Icons.add, size: 16),
                          onPressed: () => setState(() => _servings += 0.5),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildMacroRow(),
              const SizedBox(height: 20),
              Text('Other nutrition facts',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildNutritionFactRow('Saturated Fat',
                          '${(selectedMeasurement.saturatedFat * _servings).toStringAsFixed(1)}g'),
                      _buildNutritionFactRow('Polyunsaturated Fat',
                          '${(selectedMeasurement.polyunsaturatedFat * _servings).toStringAsFixed(2)}g'),
                      _buildNutritionFactRow('Monounsaturated Fat',
                          '${(selectedMeasurement.monounsaturatedFat * _servings).toStringAsFixed(1)}g'),
                      _buildNutritionFactRow('Cholesterol',
                          '${(selectedMeasurement.cholesterol * _servings).toStringAsFixed(0)}mg'),
                      _buildNutritionFactRow('Sodium',
                          '${(selectedMeasurement.sodium * _servings).toStringAsFixed(0)}mg'),
                      _buildNutritionFactRow('Fiber',
                          '${(selectedMeasurement.dietaryFiber * _servings).toStringAsFixed(2)}g'),
                      _buildNutritionFactRow('Sugar',
                          '${(selectedMeasurement.totalSugars * _servings).toStringAsFixed(2)}g'),
                      _buildNutritionFactRow('Potassium',
                          '${(selectedMeasurement.potassium * _servings).toStringAsFixed(0)}mg'),
                      _buildNutritionFactRow('Vitamin A',
                          '${(selectedMeasurement.vitaminA * _servings).toStringAsFixed(0)}μg'),
                      _buildNutritionFactRow('Vitamin C',
                          '${(selectedMeasurement.vitaminC * _servings).toStringAsFixed(2)}mg'),
                      _buildNutritionFactRow('Calcium',
                          '${(selectedMeasurement.calcium * _servings).toStringAsFixed(0)}mg'),
                      _buildNutritionFactRow('Iron',
                          '${(selectedMeasurement.iron * _servings).toStringAsFixed(2)}mg'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _logFoodIntake,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Log',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildMacroRow() {
    return Row(
      children: [
        _buildMacroBox('Calories',
            '${(selectedMeasurement.calories * _servings).round()}'),
        const SizedBox(width: 10),
        _buildMacroBox('Protein',
            '${(selectedMeasurement.protein * _servings).toStringAsFixed(1)}g',
            color: Colors.red),
        const SizedBox(width: 10),
        _buildMacroBox('Carbs',
            '${(selectedMeasurement.carbs * _servings).toStringAsFixed(1)}g',
            color: Colors.amber),
        const SizedBox(width: 10),
        _buildMacroBox('Fats',
            '${(selectedMeasurement.fat * _servings).toStringAsFixed(1)}g',
            color: Colors.blue),
      ],
    );
  }

  Widget _buildMacroBox(String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFEEF2F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: color ?? Colors.black),
                const SizedBox(width: 4),
                Text(label,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: color ?? Colors.black)),
              ],
            ),
            Text(value,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionFactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  const MeasurementButton(
      {Key? key,
      required this.label,
      required this.isSelected,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
