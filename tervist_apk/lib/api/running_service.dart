import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/auth_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
