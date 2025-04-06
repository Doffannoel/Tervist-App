import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';

class NutritionService {
  // Fetch weekly nutrition summary
  Future<Map<String, dynamic>> getWeeklyNutritionSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        ApiConfig.weeklyNutritionSummary,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(Duration(seconds: ApiConfig.timeoutDuration));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load nutrition data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching nutrition data: $e');
    }
  }
}
