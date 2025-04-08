import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/api/chatbot_service.dart';
import 'package:tervist_apk/screens/nutritions/chatbot.dart';
import 'changefoodname_page.dart';
import 'edit_nutrition_page.dart';

class SelectedFoodPage extends StatefulWidget {
  const SelectedFoodPage({super.key});

  @override
  State<SelectedFoodPage> createState() => _SelectedFoodPageState();
}

class _SelectedFoodPageState extends State<SelectedFoodPage> {
  String foodName = '';
  int quantity = 1;
  String? selectedMeal;
  int calories = 0;
  int protein = 0;
  int carbs = 0;
  int fats = 0;

  final int caloriesTarget = 1236;
  final int proteinTarget = 75;
  final int carbsTarget = 156;
  final int fatsTarget = 34;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Selected food',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _showFoodNameDialog,
                        child: Text(
                          foodName.isEmpty ? 'Tap to Name' : foodName,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) quantity--;
                                });
                              },
                            ),
                            Text(
                              '$quantity',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Meals Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMealButton('Breakfast'),
                      _buildMealButton('Lunch'),
                      _buildMealButton('Dinner'),
                      _buildMealButton('Snack'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildCaloriesCard(),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _navigateToEdit(
                              'Protein', protein, proteinTarget),
                          child: _buildMacroCard('Protein', protein,
                              'assets/images/protein.png', Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _navigateToEdit('Carbs', carbs, carbsTarget),
                          child: _buildMacroCard('Carbs', carbs,
                              'assets/images/carb.png', Colors.amber),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _navigateToEdit('Fats', fats, fatsTarget),
                          child: _buildMacroCard('Fats', fats,
                              'assets/images/fat.png', Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(), // biar gak ketimpa tombol
                ],
              ),
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // 1. Latar putih di bagian bawah
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    color: Colors.white,
                  ),
                ),

                // 2. Tombol Log (posisi di atas container putih)
                Positioned(
                  bottom: 20,
                  left: 30,
                  right: 30,
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Log action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Text(
                        'Log',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Icon senyum di atas tombol Log
                Positioned(
                  bottom: 150, // lebih tinggi dari tombol Log
                  right: 30,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/iconsenyum.png',
                        height: 24,
                        width: 24,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TervyChatScreen()));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealButton(String mealType) {
    bool isSelected = selectedMeal == mealType;
    return GestureDetector(
      onTap: () => setState(() => selectedMeal = mealType),
      child: Container(
        width: 80,
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            mealType,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditNutritionPage(
              title: 'Calories',
              value: calories,
              onSave: (val) => setState(() => calories = val),
              dailyTarget: 1236, consumedValue: 0,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/images/calories_streak.png",
                height: 43, width: 40),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Calories",
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '$calories',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard(
      String label, int value, String iconPath, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(iconPath, height: 18, width: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.only(left: 23),
            child: Text(
              '${value}g',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(String title, int value, int target) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNutritionPage(
          title: title,
          value: value,
          onSave: (val) {
            setState(() {
              switch (title) {
                case 'Calories':
                  calories = val;
                  break;
                case 'Protein':
                  protein = val;
                  break;
                case 'Carbs':
                  carbs = val;
                  break;
                case 'Fats':
                  fats = val;
                  break;
              }
            });
          },
          dailyTarget: target, consumedValue: 0,
        ),
      ),
    );

    void _showFoodNameDialog() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeFoodNamePage(initialName: foodName),
        ),
      );
      if (result != null && result is String) {
        setState(() => foodName = result);
      }
    }
  }
    void _showFoodNameDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeFoodNamePage(initialName: foodName),
      ),
    );
    if (result != null && result is String) {
      setState(() => foodName = result);
    }
  }
}
