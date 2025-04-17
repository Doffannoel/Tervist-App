// treadmill_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/api/api_config.dart';
import '/api/auth_helper.dart';

class TreadmillService {
  // Get username from profile endpoint
  Future<String?> getUserName() async {
    final token = await AuthHelper.getToken();
    if (token == null) {
      return null;
    }

    try {
      final response = await http.get(
        ApiConfig.profile,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['username'];
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return null;
  }

  // Get complete user profile including image URL
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
        final profileImageUrl = data[
            'profile_picture']; // Adjust field name if needed to match your API

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
