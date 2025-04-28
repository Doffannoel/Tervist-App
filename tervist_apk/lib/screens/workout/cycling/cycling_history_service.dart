import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/auth_helper.dart';
import 'package:tervist_apk/models/cycling_history_model.dart';

class CyclingHistoryService {
  Future<CyclingHistoryModel> getCyclingHistory() async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        ApiConfig.cyclingHistory, // This needs to be added to ApiConfig
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CyclingHistoryModel.fromJson(data);
      } else {
        throw Exception('Failed to load cycling history');
      }
    } catch (e) {
      print('Error fetching cycling history: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCyclingActivityDetail(int activityId) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/cycling-activity/$activityId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 Detailed activity data: ${data.keys}');
        return data;
      } else {
        throw Exception(
            'Failed to load cycling activity details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cycling activity details: $e');
      rethrow;
    }
  }

  Future<Map<String, String?>> getUserProfile() async {
    String? cachedName = await AuthHelper.getUserName();
    String? cachedProfilePic = await AuthHelper.getProfilePicture();

    if (cachedName != null && cachedProfilePic != null) {
      return {'username': cachedName, 'profileImageUrl': cachedProfilePic};
    }

    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        return {'username': cachedName, 'profileImageUrl': cachedProfilePic};
      }

      final response = await http.get(
        ApiConfig.profile,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final username = data['username'];
        final profileImageUrl = data['profile_picture'];

        if (username != null) {
          await AuthHelper.saveUserName(username);
        }

        if (profileImageUrl != null) {
          await AuthHelper.saveProfilePicture(profileImageUrl);
        }

        return {'username': username, 'profileImageUrl': profileImageUrl};
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }

    return {'username': cachedName, 'profileImageUrl': cachedProfilePic};
  }
}
