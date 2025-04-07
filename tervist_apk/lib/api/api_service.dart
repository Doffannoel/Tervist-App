import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'dart:math' as math;

class ApiService {
  // Fungsi untuk mendapatkan data dashboard
  Future<Map<String, dynamic>> fetchDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

        print('Fetching dashboard with token: ${token.substring(0, math.min(10, token.length))}...'); // Debug logging tanpa menampilkan seluruh token
        
    final response = await http.get(
      ApiConfig.dashboard,
      headers: {
        'Authorization':
            'Bearer $token', // Menggunakan 'Bearer' sesuai dengan JWTAuthentication
        'Content-Type': 'application/json',
      },
    );

    print('Dashboard response status: ${response.statusCode}');

    // Hanya tampilkan sebagian dari response jika terlalu besar
    if (response.body.length > 500) {
      print(
          'Dashboard response preview: ${response.body.substring(0, 500)}...');
    } else {
      print('Dashboard response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    } else {
      throw Exception('Failed to load dashboard data: ${response.statusCode}');
    }
  }
}
