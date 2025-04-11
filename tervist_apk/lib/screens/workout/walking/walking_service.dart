// walking_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/api/api_config.dart';
import '/api/auth_helper.dart';

class WalkingService {
  Future<bool> saveWalkingActivity({
    required double distanceKm,
    required int timeSeconds,
    required double pace,
    required int caloriesBurned,
    required int steps,
    required DateTime date,
  }) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        print('No authentication token found');
        return false;
      }

      final response = await http.post(
        ApiConfig.walkingActivity,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'distance_km': distanceKm,
          'time_seconds': timeSeconds,
          'pace': pace,
          'calories_burned': caloriesBurned,
          'steps': steps,
          'date': date
              .toIso8601String()
              .split('T')[0], // Hanya kirim format YYYY-MM-DD
        }),
      );

      if (response.statusCode == 201) {
        print('Walking activity saved successfully');
        return true;
      } else {
        print('Failed to save walking activity: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving walking activity: $e');
      return false;
    }
  }
}
