import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_helper.dart';
import 'api_config.dart';

class RunningService {
  Future<bool> saveRunningActivity({
    required double distanceKm,
    required int timeSeconds,
    required double pace,
    required int caloriesBurned,
    required int steps,
    required DateTime date,
  }) async {
    final token = await AuthHelper.getToken();

    final response = await http.post(
      ApiConfig.runningActivity,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'distance_km': distanceKm,
        'time_seconds': timeSeconds,
        'pace': pace,
        'calories_burned': caloriesBurned,
        'steps': steps,
        'date': date.toIso8601String().substring(0, 10),
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return response.statusCode == 201;
  }

  Future<String?> getUserName() async {
    final token = await AuthHelper.getToken();
    final response = await http.get(
      ApiConfig.profile,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['username'];
    }
    return null;
  }
}
