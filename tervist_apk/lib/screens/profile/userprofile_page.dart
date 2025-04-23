// Tetap import seperti sebelumnya
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';
import 'package:tervist_apk/screens/profile/achievement_page.dart';
import 'package:tervist_apk/screens/profile/editprofile_page.dart';
import 'package:tervist_apk/screens/profile/nutrition_page.dart';
import 'package:tervist_apk/screens/profile/reminder_page.dart';
import 'package:tervist_apk/screens/profile/statistic_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Yesaya';
  String? profilePictureUrl;

  final GlobalKey<_WeeklyChartState> chartKey = GlobalKey<_WeeklyChartState>();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      ApiConfig.profile,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Profile response status: ${response.statusCode}');
    print('Profile response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        username = data['username'] ?? 'User';
        profilePictureUrl = data['profile_picture'];
      });
    } else if (response.statusCode == 401) {
      await prefs.remove('access_token');
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchUserProfile();
            await chartKey.currentState?.refreshSummary();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
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
                        child: profilePictureUrl != null
                            ? Image.network(
                                profilePictureUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.person,
                                        color: Colors.grey),
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/profile.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Text(
                      username,
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
                            color: Colors.orange, fontSize: 8),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
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
                              builder: (context) => const EditProfilePage()),
                        ).then((_) {
                          fetchUserProfile();
                        });
                      },
                      icon: const Icon(Icons.edit_square,
                          size: 10, color: Colors.orange),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                            color: Colors.orange, fontSize: 8),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: const Size(58, 20),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: WeeklyChart(key: chartKey),
              ),
              const SizedBox(height: 40),
              buildMenuItem(
                icon: Icons.show_chart_outlined,
                title: 'Statistic',
                value: '---',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StatisticPage()),
                  );
                },
              ),
              const Divider(height: 1),
              buildMenuItem(
                icon: Icons.restaurant_outlined,
                title: 'Nutrition',
                value: '---',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NutritionPage()));
                },
              ),
              const Divider(height: 1),
              buildMenuItem(
                icon: Icons.emoji_events,
                title: 'Achievement',
                value: '---',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AchievementPage()));
                },
              ),
              const Divider(height: 1),
              buildMenuItem(
                  icon: Icons.access_time,
                  title: 'Reminder',
                  value: '---',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReminderPage()));
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: const Color(0xFFF1F7F6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F7F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 25),
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, fontSize: 12),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class WeeklyChart extends StatefulWidget {
  const WeeklyChart({super.key});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  List<FlSpot> spots = [];
  List<String> labels = [];
  double totalDistance = 0;
  double totalTime = 0;

  @override
  void initState() {
    super.initState();
    fetchMonthlySummary();
  }

  Future<void> refreshSummary() async {
    await fetchMonthlySummary();
  }

  Future<void> fetchMonthlySummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      ApiConfig.monthlySummary,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Monthly summary response status: ${response.statusCode}');
    print('Monthly summary response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<FlSpot> tempSpots = [];
      List<String> tempLabels = [];
      double distance = 0;
      double time = 0;

      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        tempSpots.add(FlSpot(i.toDouble(), item['distance_km'].toDouble()));
        tempLabels.add(item['month']);
        distance += item['distance_km'];
        time += item['time_minutes'];
      }

       setState(() {
        spots = tempSpots;
        labels = tempLabels;
        totalDistance = distance;
        totalTime = time;
      });
    } else if (response.statusCode == 401) {
      await prefs.remove('access_token');
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const Text("Belum ada data tersedia.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/runicon.png',
                width: 20, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              'Running Summary (This Year)',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Distance',
                    style:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 8)),
                Text('${totalDistance.toStringAsFixed(2)} km',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 7)),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time',
                    style:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 8)),
                Text('${(totalTime / 60).toStringAsFixed(1)}h',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 7)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
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
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < labels.length) {
                        return Text(
                          labels[index],
                          style: GoogleFonts.poppins(
                            color: Colors.orange.shade300,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (labels.length - 1).toDouble(),
              minY: 0,
              maxY: 10,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Colors.orange,
                    ),
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
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
