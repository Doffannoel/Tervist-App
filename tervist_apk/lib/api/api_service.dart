import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';

class ApiService {
  // Fungsi untuk mendapatkan data dashboard
  Future<Map<String, dynamic>> fetchDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      ApiConfig.dashboard,
      headers: {
        'Authorization': 'Bearer $token', // Gunakan 'Bearer'
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    } else {
      throw Exception('Failed to load dashboard data: ${response.body}');
    }
  }
}
