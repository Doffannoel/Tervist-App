import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  bool isRiding = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button and Title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 1),
              ),
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Statistic',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 60), // balance spacing
                ],
              ),
            ),

            // Toggle icon section
            Container(
              margin: const EdgeInsets.only(right: 16, left: 16, bottom: 10),
              alignment:
                  isRiding ? Alignment.centerRight : Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isRiding = !isRiding;
                  });
                },
                child: Container(
                  width: 64,
                  height: 27,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: isRiding
                      ? Icon(Icons.pedal_bike, size: 22, color: Colors.orange)
                      : Image.asset(
                          'assets/images/runicon.png',
                          width: 22,
                          height: 20,
                          color: Colors.orange,
                        ),
                ),
              ),
            ),

            // Activity section with correct icon
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  isRiding
                      ? Image.asset(
                          'assets/images/runicon.png',
                          width: 20,
                          height: 20,
                        )
                      : const Icon(
                          Icons.pedal_bike,
                          size: 20,
                        ),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVITY',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Activity Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildStatRow(
                      isRiding ? 'Avg Runs/Week' : 'Avg Rides/Week', '0'),
                  const SizedBox(height: 16),
                  buildStatRow('Avg Time/Week', '0h'),
                  const SizedBox(height: 16),
                  buildStatRow('Avg Distance/Week', '0mi'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Year-to-Date Header in white container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                'YEAR-TO-DATE',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Year-to-Date Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildStatRow(isRiding ? 'Runs' : 'Rides', '0'),
                  const SizedBox(height: 16),
                  buildStatRow('Time', '0h'),
                  const SizedBox(height: 16),
                  buildStatRow('Distance', '0mi'),
                  const SizedBox(height: 16),
                  buildStatRow('Elevation Gain', '0ft'),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
