import 'package:http/http.dart' as http;
import 'dart:convert';
import '/api/api_config.dart';
import '/api/auth_helper.dart';

class CyclingService {
  Future<bool> saveCyclingActivity({
    required DateTime date,
    required int durationSeconds,
    required double distanceKm,
    required double avgSpeedKmh,
    required double maxSpeedKmh,
    int elevationGainM = 0,
  }) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        print('No authentication token found');
        return false;
      }

      final response = await http.post(
        ApiConfig.cyclingActivity,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'date': date.toIso8601String().split('T')[0],
          'duration': durationSeconds, // Kirim durasi dalam detik
          'distance_km': distanceKm,
          'avg_speed_kmh': avgSpeedKmh,
          'max_speed_kmh': maxSpeedKmh,
          'elevation_gain_m': elevationGainM,
        }),
      );

      if (response.statusCode == 201) {
        print('Cycling activity saved successfully');
        return true;
      } else {
        print('Failed to save cycling activity: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving cycling activity: $e');
      return false;
    }
  }

  // Method untuk mengambil statistik cycling
  Future<Map<String, dynamic>> getCyclingStats() async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        ApiConfig.cyclingStats,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load cycling stats');
      }
    } catch (e) {
      print('Error fetching cycling stats: $e');
      rethrow;
    }
  }
}
