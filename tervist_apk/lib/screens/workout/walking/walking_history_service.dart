import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/auth_helper.dart';
import 'package:tervist_apk/models/walking_history_model.dart';

class WalkingHistoryService {
  Future<WalkingHistoryModel> getWalkingHistory() async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        ApiConfig.walkingHistory,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WalkingHistoryModel.fromJson(data);
      } else {
        throw Exception('Failed to load walking history');
      }
    } catch (e) {
      print('Error fetching walking history: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWalkingActivityDetail(int activityId) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/walking-history/$activityId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load walking activity details');
      }
    } catch (e) {
      print('Error fetching walking activity details: $e');
      rethrow;
    }
  }

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
