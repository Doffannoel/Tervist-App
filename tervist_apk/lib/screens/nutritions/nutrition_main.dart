import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tervist_apk/screens/nutritions/selected_food_page.dart';
import 'package:tervist_apk/widgets/calendar_popup.dart';
import 'package:intl/intl.dart';
import 'scanfood.dart';
import 'package:tervist_apk/widgets/navigation_bar.dart';

class NutritionMainPage extends StatefulWidget {
  const NutritionMainPage({super.key});

  @override
  State<NutritionMainPage> createState() => _NutritionMainPageState();
}

class _NutritionMainPageState extends State<NutritionMainPage> {
  DateTime _startDate = DateTime(2025, 2, 16);

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CalendarPopup();
      },
    );
  }

  void _changeWeek(int direction) {
    setState(() {
      _startDate = _startDate.add(Duration(days: direction * 7));
    });
  }

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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/fooddtbs.png', height: 24),
                      SizedBox(height: 5),
                      Text('Food Database',
                          style: TextStyle(color: Colors.black, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScanFoodPage()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/scanfood.png', height: 24),
                        SizedBox(height: 5),
                        Text('Scan Food',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
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
    final DateTime today = DateTime(2025, 2, 20);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logotervist.png',
                    height: 24,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/images/fire.png', height: 20),
                        const SizedBox(width: 5),
                        const Text('0',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              GestureDetector(
                onTap: _showCalendarDialog,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 6),
                    Text(DateFormat("MMMM yyyy").format(_startDate),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 15),

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
                        final isSelected = date.day == 18;
                        final isToday = date == today;

                        return Column(
                          children: [
                            Text(days[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.red : Colors.black,
                                  fontWeight: FontWeight.w500,
                                )),
                            const SizedBox(height: 4),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(color: Colors.red, width: 2)
                                    : isToday
                                        ? Border.all(
                                            color: Colors.black, width: 1)
                                        : Border.all(color: Colors.transparent),
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

              // Calories left card
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1236',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold)),
                        Text('Calories left', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 8,
                        ),
                      ),
                      child: Image.asset('assets/images/fire.png', height: 24),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Macronutrients row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMacroCard(
                      '75g', 'Proteins left', 'assets/images/protein.png'),
                  _buildMacroCard(
                      '156g', 'Carbs left', 'assets/images/carb.png'),
                  _buildMacroCard('34g', 'Fats left', 'assets/images/fat.png'),
                ],
              ),
              const SizedBox(height: 40),

              // Recently logged section
              const Text('Recently logged',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Empty state message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EAF0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("You haven't uploaded any food",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 6),
                            Text(
                                "Start tracking today's meals by taking a\nquick picture",
                                style: TextStyle(fontSize: 14, height: 1.3)),
                          ],
                        ),
                        Transform.rotate(
                          angle: 0.5,
                          child: const Icon(Icons.arrow_forward, size: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Gw matiin bentar ya pris, gw butuh update progress ke pak mata jadi tombol plus nya gw arahain ke page selected food dulu
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showFoodSelection(context);
      //   },
      //   backgroundColor: Colors.black,
      //   shape: const CircleBorder(),
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SelectedFoodPage()));
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMacroCard(String value, String label, String imagePath) {
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
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 6,
              ),
            ),
            child: Image.asset(imagePath, height: 18),
          ),
        ],
      ),
    );
  }
}
