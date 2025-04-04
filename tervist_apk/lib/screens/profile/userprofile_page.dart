import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/screens/profile/editprofile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F7F6), // Gunakan background sesuai Theme
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Profile card with border
            Container(
              width: 370,
              height: 119,
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 90, bottom: 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/profile_image.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Text(
                    'Yesaya',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.ios_share,
                        size: 10, color: Colors.orange),
                    label: Text(
                      'Share',
                      style: GoogleFonts.poppins(
                        color: Colors.orange,
                        fontSize: 8,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(58, 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  EditProfilePage(),
                          ));
                    },
                    icon: const Icon(Icons.edit_square,
                        size: 10, color: Colors.orange),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        color: Colors.orange,
                        fontSize: 8,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(58, 20),
                    ),
                  ),
                ],
              ),
            ),

            // Weekly Progress Chart
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/runicon.png',
                          width: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'This week',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            '0,00 mi',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 7,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            '0h',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 7,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height: 120,
                    child: LineChartSample(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            buildMenuItem(Icons.show_chart_outlined, 'Statistic', '---'),
            const Divider(height: 1),
            buildMenuItem(Icons.restaurant_outlined, 'Nutrition', '---'),
            const Divider(height: 1),
            buildMenuItem(Icons.emoji_events, 'Achievement', '---'),
            const Divider(height: 1),
            buildMenuItem(Icons.access_time, 'Reminder', '---'),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String title, String value) {
    return Container(
      color: const Color(0xFFF1F7F6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Color(0xFFF1F7F6),
              borderRadius: BorderRadius.circular(8),
              // border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Icon(icon, size: 25),
          ),
          const SizedBox(
            width: 18,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class LineChartSample extends StatelessWidget {
  const LineChartSample({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'Mai'];
                final index = value.toInt();
                if (index >= 0 && index < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      titles[index],
                      style: GoogleFonts.poppins(
                        color: Colors.orange.shade300,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 4,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 2),
              FlSpot(1, 2.8),
              FlSpot(2, 3.8),
              FlSpot(3, 3.5),
              FlSpot(4, 4.8),
            ],
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.orange,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.orange.withOpacity(0.3),
                  Colors.orange.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
