import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';
import '../models/food_database.dart';

class FoodDatabaseService {
  // Fetch all food items or search by name
  Future<List<FoodDatabase>> getFoodItems({String? searchQuery}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      Uri uri = ApiConfig.foodIntake;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        uri = Uri.parse('${uri.toString()}?search=$searchQuery');
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: ApiConfig.timeoutDuration));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => FoodDatabase.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load food items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting food items: $e');
    }
  }

  // Log food intake
  Future<void> logFoodIntake({
    required int foodDataId,
    required String mealType,
    required String servingSize,
    DateTime? date,
    String? time,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http
          .post(
            ApiConfig.foodIntake,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'food_data_id': foodDataId,
              'meal_type': mealType,
              'serving_size': servingSize,
              'date': date?.toIso8601String().split('T')[0] ??
                  DateTime.now().toIso8601String().split('T')[0],
              'time': time ??
                  DateTime.now().toString().split(' ')[1].substring(0, 5),
            }),
          )
          .timeout(const Duration(seconds: ApiConfig.timeoutDuration));

      if (response.statusCode != 201) {
        throw Exception('Failed to log food intake: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error logging food intake: $e');
    }
  }

  // Log empty meal (manual calories)
  Future<void> logEmptyMeal({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required String mealType,
    DateTime? date,
    String? time,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http
          .post(
            ApiConfig.foodIntake,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'manual_calories': calories,
              'manual_protein': protein,
              'manual_carbs': carbs,
              'manual_fats': fats,
              'meal_type': mealType,
              'date': date?.toIso8601String().split('T')[0] ??
                  DateTime.now().toIso8601String().split('T')[0],
              'time': time ??
                  DateTime.now().toString().split(' ')[1].substring(0, 5),
            }),
          )
          .timeout(const Duration(seconds: ApiConfig.timeoutDuration));

      if (response.statusCode != 201) {
        throw Exception('Failed to log empty meal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error logging empty meal: $e');
    }
  }

  // Get recently logged food
  Future<List<FoodDatabase>> getRecentlyLoggedFood() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        ApiConfig.foodIntake,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: ApiConfig.timeoutDuration));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Set<int> uniqueFoodIds = {};
        final List<FoodDatabase> recentFoods = [];

        // Extract unique food items from recently logged entries
        for (var item in data) {
          if (item['food_data'] != null &&
              !uniqueFoodIds.contains(item['food_data']['id'])) {
            uniqueFoodIds.add(item['food_data']['id']);
            recentFoods.add(FoodDatabase.fromJson(item['food_data']));

            // Limit to 5 recent items
            if (recentFoods.length >= 5) break;
          }
        }

        return recentFoods;
      } else {
        throw Exception(
            'Failed to load recently logged food: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recently logged food: $e');
    }
  }
}
