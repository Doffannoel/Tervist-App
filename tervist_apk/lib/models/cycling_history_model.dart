class CyclingHistoryModel {
  final DateTime startDate;
  final int totalWorkouts;
  final double totalTimeSeconds;
  final double totalDistance;
  final double totalCalories;
  final double avgSpeed;
  final List<CyclingRecord> records;

  CyclingHistoryModel({
    required this.startDate,
    required this.totalWorkouts,
    required this.totalTimeSeconds,
    required this.totalDistance,
    required this.totalCalories,
    required this.avgSpeed,
    required this.records,
  });

  factory CyclingHistoryModel.fromJson(Map<String, dynamic> json) {
    List<CyclingRecord> recordsList = [];
    if (json['records'] != null) {
      recordsList = (json['records'] as List)
          .map((record) => CyclingRecord.fromJson(record))
          .toList();
    }

    return CyclingHistoryModel(
      startDate: DateTime.parse(json['start_date']),
      totalWorkouts: json['total_workouts'],
      totalTimeSeconds: (json['total_time_seconds'] ?? 0).toDouble(),
      totalDistance: json['total_distance'].toDouble(),
      totalCalories: (json['total_calories'] ?? 0).toDouble(),
      avgSpeed: json['avg_speed'].toDouble(),
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

class CyclingRecord {
  final int id;
  final double distance;
  final DateTime date;

  CyclingRecord({
    required this.id,
    required this.distance,
    required this.date,
  });

  factory CyclingRecord.fromJson(Map<String, dynamic> json) {
    return CyclingRecord(
      id: json['id'],
      distance: json['distance'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}
