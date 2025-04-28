import 'package:flutter/material.dart';

class StreakPopupDialog extends StatelessWidget {
  const StreakPopupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/logotervist.png',
                  height: 25,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/fireon.png',
                        height: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "1",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Day streak api dengan angka 1
            Image.asset(
              'assets/images/day1strik.png',
              height: 150,
            ),

            SizedBox(height: 20),

            // Weekly calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDayCircle('S', false),
                  _buildDayCircle('M', false), // Active day
                  _buildDayCircle('T', true),
                  _buildDayCircle('W', false),
                  _buildDayCircle('T', false),
                  _buildDayCircle('F', false),
                  _buildDayCircle('S', false),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Motivational text
            Text(
              "You're on fire! Every day matters for hitting your goal!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),

            SizedBox(height: 20),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator ke nutrition_main.dart jika diperlukan
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => NutritionMainPage()),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCircle(String day, bool isActive) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: day == 'T' ? Colors.orange : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.orange : Colors.grey[300],
          ),
          child: isActive
              ? Icon(Icons.check, color: Colors.white, size: 15)
              : null,
        ),
      ],
    );
  }
}
