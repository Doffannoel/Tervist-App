import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  bool isBiking = false;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 1),
              ),
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios, size: 20),
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Statistic',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isBiking = !isBiking;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.directions_bike,
                        size: 16,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Activity Toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            isBiking
                                ? Icons.directions_run
                                : Icons.directions_bike,
                            size: 16,
                            color: Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVITY',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Activity Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  buildStatRow(
                      isBiking ? 'Avg Rides/Week' : 'Avg Runs/Week', '0'),
                  const SizedBox(height: 16),
                  buildStatRow('Avg Time/Week', '0h'),
                  const SizedBox(height: 16),
                  buildStatRow('Avg Distance/Week', '0mi'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Year-to-Date Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year-to-Date Header
                  Text(
                    'YEAR-TO-DATE',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Year-to-Date Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        buildStatRow(isBiking ? 'Rides' : 'Runs', '0'),
                        const SizedBox(height: 16),
                        buildStatRow('Time', '0h'),
                        const SizedBox(height: 16),
                        buildStatRow('Distance', '0mi'),
                        const SizedBox(height: 16),
                        buildStatRow('Elevation Gain', '0ft'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Space for the navbar that will be imported
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
