import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tervist_apk/api/nutrition_model.dart';
import 'package:tervist_apk/api/nutrition_service.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final NutritionService _nutritionService = NutritionService();
  bool _isLoading = true;
  String _errorMessage = '';
  WeeklyNutritionData? _nutritionData;

  @override
  void initState() {
    super.initState();
    _fetchNutritionData();
  }

  Future<void> _fetchNutritionData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final data = await _nutritionService.getWeeklyNutritionSummary();

      setState(() {
        _nutritionData = WeeklyNutritionData.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load nutrition data: $e';
        _isLoading = false;
      });
      print('Error: $_errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 1),
              ),
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
                    'Nutrition',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 60),
                ],
              ),
            ),

            // Chart Section
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _errorMessage,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchNutritionData,
                  child: ListView(
                    children: [
                      // Chart Container
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.restaurant_outlined, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'This week',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 150,
                              child: NutritionChartSample(
                                weekData: _nutritionData?.weekData ?? [],
                                goalValue: _nutritionData?.goal ?? 0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Calorie Stats Section
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 31,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset('assets/images/caloriesicon.png',
                                  width: 20, height: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Calories',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildStatRow(
                              'Net Calories Under Weekly Goal',
                              _nutritionData?.netDifference.toString() ?? '0',
                            ),
                            const SizedBox(height: 16),
                            buildStatRow(
                              'Net Average',
                              _nutritionData?.netAverage.toString() ?? '0',
                            ),
                            const SizedBox(height: 16),
                            buildStatRow(
                              'Goal',
                              _nutritionData?.goal.toString() ?? '0',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class NutritionChartSample extends StatelessWidget {
  final List<DailyCalories> weekData;
  final int goalValue;

  const NutritionChartSample({
    super.key,
    required this.weekData,
    required this.goalValue,
  });

  @override
  Widget build(BuildContext context) {
    // Prepare chart data
    List<FlSpot> spots = [];
    List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    Map<String, int> dayToIndex = {
      'Mon': 0,
      'Tue': 1,
      'Wed': 2,
      'Thu': 3,
      'Fri': 4,
      'Sat': 5,
      'Sun': 6
    };

    // Default empty spots
    spots = List.generate(7, (index) => FlSpot(index.toDouble(), 0));

    // Fill with data if available
    if (weekData.isNotEmpty) {
      for (var day in weekData) {
        int? index = dayToIndex[day.date];
        if (index != null) {
          spots[index] = FlSpot(index.toDouble(), day.calories.toDouble());
        }
      }
    } else {
      // If no data, generate some sample data (gradually increasing values)
      spots =
          List.generate(7, (index) => FlSpot(index.toDouble(), index * 200.0));
    }

    // Find max Y for scaling chart
    double maxY = 0;
    for (var spot in spots) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }

    // Ensure we have a non-zero goal value
    double goalDouble = goalValue > 0 ? goalValue.toDouble() : 2000.0;

    // Choose the larger of max data point or goal value
    maxY = maxY < goalDouble ? goalDouble : maxY * 1.2;

    // Ensure maxY is never too small (minimum of 400)
    maxY = maxY < 400 ? 400 : maxY;

    // Round up to nearest 400 for better readability
    maxY = ((maxY / 400).ceil() * 400).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          // Ensure horizontalInterval is never zero
          horizontalInterval: maxY <= 0 ? 100 : maxY / 4,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade400,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade400,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < weekDays.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      weekDays[index],
                      style: GoogleFonts.poppins(
                        color: Colors.orange,
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toInt().toString(),
                    style: GoogleFonts.poppins(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
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
