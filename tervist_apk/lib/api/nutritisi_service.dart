import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';

class NutrisiService {
  // Get token from SharedPreferences
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? '';
    return accessToken;
  }

  NutrisiService();

  // Get nutritional targets and consumption for a specific date
  Future<Map<String, dynamic>> getNutritionalTargets(DateTime date) async {
    final token = await _getToken();
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await http.get(
      Uri.parse(
          '${ApiConfig.nutritionalTarget}/daily_summary/?date=$formattedDate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load nutritional targets: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getDailySummary(DateTime date) async {
    final token = await _getToken();
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    print('HIT DAILY SUMMARY: ${ApiConfig.dailySummary(formattedDate)}');
    print('TOKEN: $token');

    final response = await http.get(
      ApiConfig.dailySummary(formattedDate),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load daily summary: ${response.statusCode}');
    }
  }

  // Search food database
  Future<List<dynamic>> searchFoodDatabase(String query) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.foodIntake}?search=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search food database: ${response.statusCode}');
    }
  }

  // Log food intake
  Future<Map<String, dynamic>> logFoodIntake(Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.post(
      ApiConfig.foodIntake,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to log food intake: ${response.statusCode}, ${response.body}');
    }
  }

  // Get food intake for a specific date
  Future<List<dynamic>> getFoodIntake(DateTime date) async {
    final token = await _getToken();
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await http.get(
      Uri.parse('${ApiConfig.foodIntake}?date=$formattedDate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get food intake: ${response.statusCode}');
    }
  }

  // Update nutritional targets
  Future<Map<String, dynamic>> updateNutritionalTargets(
      Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      ApiConfig.nutritionalTarget,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to update nutritional targets: ${response.statusCode}');
    }
  }

  // Delete food intake
  Future<void> deleteFoodIntake(int foodIntakeId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${ApiConfig.foodIntake}$foodIntakeId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete food intake: ${response.statusCode}');
    }
  }

  // Get dashboard summary
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final token = await _getToken();
    final response = await http.get(
      ApiConfig.dashboard,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to get dashboard summary: ${response.statusCode}');
    }
  }

  // Get weekly nutrition summary
  Future<Map<String, dynamic>> getWeeklyNutritionSummary() async {
    final token = await _getToken();
    final response = await http.get(
      ApiConfig.weeklyNutritionSummary,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to get weekly nutrition summary: ${response.statusCode}');
    }
  }

  // Tambahkan method baru untuk manual food intake
  Future<Map<String, dynamic>> createManualFoodIntake({
    required String name,
    required String mealType,
    required double calories,
    double protein = 0,
    double carbs = 0,
    double fats = 0,
    double servingSize = 1,
  }) async {
    final token = await _getToken();
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

    // final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

    final data = {
      'name': name,
      'meal_type': mealType,
      'manual_calories': calories,
      'manual_protein': protein,
      'manual_carbs': carbs,
      'manual_fats': fats,
      'serving_size': servingSize,
      'date': currentDate,
      'time': currentTime,
    };

    final response = await http.post(
      ApiConfig.foodIntake,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to create manual food intake: ${response.statusCode}, ${response.body}');
    }
  }
}
