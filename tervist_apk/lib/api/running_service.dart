import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/auth_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/models/running_history_model.dart';

class RunningService {
  Future<bool> saveRunningActivity({
    required double distanceKm,
    required int timeSeconds,
    required double pace,
    required int caloriesBurned,
    required int steps,
    required DateTime date,
    required List<Map<String, double>> routeData,
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
        'route_data': routeData,
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

  // New method to get both username and profile image in one call
  Future<Map<String, String?>> getUserProfile() async {
    // First check if we have cached values
    String? cachedName = await AuthHelper.getUserName();
    String? cachedProfilePic = await AuthHelper.getProfilePicture();

    // If both values are cached, return them without API call
    if (cachedName != null && cachedProfilePic != null) {
      return {'username': cachedName, 'profileImageUrl': cachedProfilePic};
    }

    // Otherwise fetch from API
    final token = await AuthHelper.getToken();
    final response = await http.get(
      ApiConfig.profile,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final username = data['username'];
      final profileImageUrl =
          data['profile_picture']; // Adjust field name to match your API

      // Save to local storage for future use
      if (username != null) {
        AuthHelper.saveUserName(username);
      }

      if (profileImageUrl != null) {
        AuthHelper.saveProfilePicture(profileImageUrl);
      }

      return {'username': username, 'profileImageUrl': profileImageUrl};
    }

    // Fallback to cached values if API call fails
    return {'username': cachedName, 'profileImageUrl': cachedProfilePic};
  }

  Future<RunningHistoryModel> getRunningHistory() async {
    final token = await AuthHelper.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        ApiConfig.runningHistory, // Add this to your ApiConfig.dart
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: ApiConfig.timeoutDuration));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RunningHistoryModel.fromJson(data);
      } else {
        throw Exception(
            'Failed to load running history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching running history: $e');
    }
  }

  // Add this to your RunningService class
  Future<Map<String, dynamic>> getRunningDetail(int id) async {
    final token = await AuthHelper.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        ApiConfig.runningDetail(id.toString()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: ApiConfig.timeoutDuration));

      print("RESPONSE STATUS: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load running detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching running detail: $e');
    }
  }
}
