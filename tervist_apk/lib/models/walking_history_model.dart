class WalkingHistoryModel {
  final DateTime startDate;
  final int totalWorkouts;
  final int totalTimeSeconds;
  final double totalDistance;
  final int totalCalories;
  final List<WalkingRecord> records;

  WalkingHistoryModel({
    required this.startDate,
    required this.totalWorkouts,
    required this.totalTimeSeconds,
    required this.totalDistance,
    required this.totalCalories,
    required this.records,
  });

  factory WalkingHistoryModel.fromJson(Map<String, dynamic> json) {
    List<WalkingRecord> recordsList = [];
    if (json['records'] != null) {
      recordsList = (json['records'] as List)
          .map((record) => WalkingRecord.fromJson(record))
          .toList();
    }

    return WalkingHistoryModel(
      startDate: DateTime.parse(
          json['start_date'] ?? DateTime.now().toIso8601String()),
      totalWorkouts: json['total_workouts'] ?? 0,
      totalTimeSeconds: json['total_time_seconds'] ?? 0,
      totalDistance: (json['total_distance'] ?? 0.0).toDouble(),
      totalCalories: json['total_calories'] ?? 0,
      records: recordsList,
    );
  }

  // Helper method to format the total duration as HH:MM:SS
  String formatTotalDuration() {
    int hours = (totalTimeSeconds / 3600).floor();
    int minutes = ((totalTimeSeconds % 3600) / 60).floor();
    int seconds = (totalTimeSeconds % 60).floor();

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
  }
}

class WalkingRecord {
  final int id;
  final double distance;
  final DateTime date;
  final int timeSeconds;
  final int steps;
  final int calories;
  final double pace;
  final List<dynamic> routeData; // 🔥 Tambahan routeData

  WalkingRecord({
    required this.id,
    required this.distance,
    required this.date,
    required this.timeSeconds,
    required this.steps,
    required this.calories,
    required this.pace,
    required this.routeData, // 🔥 Tambahkan di constructor
  });

  factory WalkingRecord.fromJson(Map<String, dynamic> json) {
    return WalkingRecord(
      id: json['id'],
      distance: (json['distance'] ?? 0.0).toDouble(),
      date: DateTime.parse(json['date']),
      timeSeconds: json['time_seconds'] ?? 0,
      steps: json['steps'] ?? 0,
      calories: json['calories_burned'] ?? 0,
      pace: (json['pace'] ?? 0.0).toDouble(),
      routeData: json['route_data'] ?? [], // 🔥 Tambahan di fromJson
    );
  }
}
