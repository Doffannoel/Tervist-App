// lib/models/running_history_model.dart
class RunningHistoryModel {
  final DateTime startDate;
  final int totalWorkouts;
  final int totalTimeSeconds;
  final double totalDistance;
  final int totalCalories;
  final List<RunningRecord> records;

  RunningHistoryModel({
    required this.startDate,
    required this.totalWorkouts,
    required this.totalTimeSeconds,
    required this.totalDistance,
    required this.totalCalories,
    required this.records,
  });

  factory RunningHistoryModel.fromJson(Map<String, dynamic> json) {
    List<RunningRecord> recordsList = [];
    if (json['records'] != null) {
      recordsList = (json['records'] as List)
          .map((record) => RunningRecord.fromJson(record))
          .toList();
    }

    return RunningHistoryModel(
      startDate: DateTime.parse(json['start_date']),
      totalWorkouts: json['total_workouts'],
      totalTimeSeconds: json['total_time_seconds'],
      totalDistance: json['total_distance'].toDouble(),
      totalCalories: json['total_calories'],
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

class RunningRecord {
  final int id;
  final double distance;
  final DateTime date;

  RunningRecord({
    required this.id,
    required this.distance,
    required this.date,
  });

  factory RunningRecord.fromJson(Map<String, dynamic> json) {
    return RunningRecord(
      id: json['id'],
      distance: json['distance'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}
