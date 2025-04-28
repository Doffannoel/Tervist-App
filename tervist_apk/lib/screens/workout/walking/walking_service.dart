// walking_service.dart
import 'package:http/http.dart' as http;
import 'package:tervist_apk/screens/workout/map_service.dart';
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
          'date': date.toIso8601String().split('T')[0],
          'route_data': jsonEncode(MapService.getRouteHistory()
              .map((e) => {
                    'latitude': e.latitude,
                    'longitude': e.longitude,
                  })
              .toList()),
// 🔥 Tambahan route data
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

  // Added method to get username
  Future<String?> getUserName() async {
    final token = await AuthHelper.getToken();
    if (token == null) {
      return null;
    }

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
    if (token == null) {
      return {'username': cachedName, 'profileImageUrl': cachedProfilePic};
    }

    try {
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
    } catch (e) {
      print('Error fetching user profile: $e');
    }

    // Fallback to cached values if API call fails
    return {'username': cachedName, 'profileImageUrl': cachedProfilePic};
  }
}
