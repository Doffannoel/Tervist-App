import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/api/statistics_service.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  bool isRiding = true;

  Map<String, dynamic> runningStats = {};
  Map<String, dynamic> cyclingStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final running = await StatisticsService.fetchRunningStats();
    final cycling = await StatisticsService.fetchCyclingStats();
    setState(() {
      runningStats = running ?? {};
      cyclingStats = cycling ?? {};
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = isRiding ? runningStats : cyclingStats;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  _buildToggle(),
                  _buildSectionTitle('ACTIVITY', isRiding),
                  const SizedBox(height: 12),
                  _buildActivityDetails(stats),
                  const SizedBox(height: 16),
                  _buildYearToDateTitle(),
                  const SizedBox(height: 12),
                  _buildYearToDateDetails(stats),
                  const Spacer(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios, size: 16),
                const SizedBox(width: 4),
                Text('Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          Text('Statistic',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.only(right: 16, left: 16, bottom: 10),
      alignment: isRiding ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isRiding = !isRiding;
          });
        },
        child: Container(
          width: 64,
          height: 27,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.orange),
            borderRadius: BorderRadius.circular(5),
          ),
          child: isRiding
              ? Icon(Icons.pedal_bike, size: 22, color: Colors.orange)
              : Image.asset('assets/images/runicon.png',
                  width: 22, height: 20, color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool showRunIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          showRunIcon
              ? Image.asset('assets/images/runicon.png', width: 20, height: 20)
              : const Icon(Icons.pedal_bike, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              )),
        ],
      ),
    );
  }

  Widget _buildActivityDetails(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          buildStatRow('Avg ${isRiding ? 'Runs' : 'Rides'}/Week',
              stats['weekly']?['average_per_week']?.toString() ?? '0'),
          buildStatRow('Avg Time/Week',
              stats['weekly']?['average_time_per_week']?.toString() ?? '0'),
          buildStatRow('Avg Distance/Week',
              stats['weekly']?['average_distance_per_week']?.toString() ?? '0'),
        ],
      ),
    );
  }

  Widget _buildYearToDateTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: Text('YEAR-TO-DATE',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 10,
          )),
    );
  }

  Widget _buildYearToDateDetails(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          buildStatRow(isRiding ? 'Runs' : 'Rides',
              stats['year_to_date']?['total_count']?.toString() ?? '0'),
          buildStatRow('Time', stats['year_to_date']?['total_time'] ?? '0'),
          buildStatRow(
              'Distance', stats['year_to_date']?['total_distance'] ?? '0'),
          buildStatRow('Elevation Gain',
              stats['year_to_date']?['total_elevation_gain'] ?? '0'),
        ],
      ),
    );
  }

  Widget buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              )),
          Text(value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
