import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/models/running_activity.dart';
import 'package:tervist_apk/api/auth_helper.dart';

class RunningService {
  // Save running activity to the backend
  Future<bool> saveRunningActivity({
    required double distanceKm,
    required int timeSeconds,
    required double pace,
    required int caloriesBurned,
    required int steps,
    DateTime? activityDate,
  }) async {
    try {
      // Get auth token
      final String? token = await AuthHelper.getToken();
      
      if (token == null) {
        return false; // User not authenticated
      }

      final response = await http.post(
        ApiConfig.runningActivity,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'distance_km': distanceKm,
          'time_seconds': timeSeconds,
          'pace': pace,
          'calories_burned': caloriesBurned,
          'steps': steps,
          'date': activityDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Failed to save running activity: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving running activity: $e');
      return false;
    }
  }

  // Get user's running activities
  Future<List<RunningActivity>> getRunningActivities() async {
    try {
      // Get auth token
      final String? token = await AuthHelper.getToken();
      
      if (token == null) {
        return []; // User not authenticated
      }

      final response = await http.get(
        ApiConfig.runningActivity,
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RunningActivity.fromJson(json)).toList();
      } else {
        print('Failed to fetch running activities: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching running activities: $e');
      return [];
    }
  }

  // Get running statistics
  Future<Map<String, dynamic>> getRunningStats() async {
    try {
      // Get auth token and user ID
      final String? token = await AuthHelper.getToken();
      final int? userId = await AuthHelper.getUserId();
      
      if (token == null || userId == null) {
        return {}; // User not authenticated
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/running-stats/?user_id=$userId'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch running stats: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error fetching running stats: $e');
      return {};
    }
  }
}