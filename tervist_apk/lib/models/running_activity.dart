class RunningActivity {
  final int? id;
  final double distanceKm;
  final int timeSeconds;
  final double pace;
  final int caloriesBurned;
  final int steps;
  final DateTime date;

  RunningActivity({
    this.id,
    required this.distanceKm,
    required this.timeSeconds,
    required this.pace,
    required this.caloriesBurned,
    required this.steps,
    required this.date,
  });

  factory RunningActivity.fromJson(Map<String, dynamic> json) {
    return RunningActivity(
      id: json['id'],
      distanceKm: json['distance_km'],
      timeSeconds: json['time_seconds'],
      pace: json['pace'],
      caloriesBurned: json['calories_burned'],
      steps: json['steps'],
      date: DateTime.parse(json['date']),
    );
  }
}