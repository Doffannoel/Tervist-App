class WeeklyNutritionData {
  final List<DailyCalories> weekData;
  final int goal;
  final int totalEaten;
  final int netDifference;
  final int netAverage;

  WeeklyNutritionData({
    required this.weekData,
    required this.goal,
    required this.totalEaten,
    required this.netDifference,
    required this.netAverage,
  });

  factory WeeklyNutritionData.fromJson(Map<String, dynamic> json) {
    List<DailyCalories> weekDataList = [];

    if (json['week_data'] != null) {
      weekDataList = List<DailyCalories>.from(
          json['week_data'].map((day) => DailyCalories.fromJson(day)));
    }

    return WeeklyNutritionData(
      weekData: weekDataList,
      goal: json['goal'] ?? 0,
      totalEaten: json['total_eaten'] ?? 0,
      netDifference: json['net_difference'] ?? 0,
      netAverage: json['net_average'] ?? 0,
    );
  }
}

class DailyCalories {
  final String date; // Contains day abbreviation like 'Mon', 'Tue', etc.
  final int calories;

  DailyCalories({
    required this.date,
    required this.calories,
  });

  factory DailyCalories.fromJson(Map<String, dynamic> json) {
    return DailyCalories(
      date: json['date'] ?? '',
      calories: json['calories'] ?? 0,
    );
  }
}
