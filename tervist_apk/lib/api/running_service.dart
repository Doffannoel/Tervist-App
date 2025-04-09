import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/api/api_config.dart';
import '/models/running_activity.dart';
import '/api/auth_helper.dart'; // Import AuthHelper

class RunningService {
  // Fungsi untuk mengirim data aktivitas lari ke backend
  Future<bool> saveRunningActivity({
    required double distanceKm,
    required int timeSeconds,
    required double pace,
    required int caloriesBurned,
    required int steps,
    DateTime? date,
  }) async {
    try {
      // Get token using AuthHelper for consistency
      final token = await AuthHelper.getToken();
      
      // Also get access_token from SharedPreferences as fallback
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      // Use token from AuthHelper first, then fallback to access_token
      final authToken = token ?? accessToken;
      
      // Log token status for debugging
      print('Running service token check:');
      print('- AuthHelper token: ${token != null ? 'Present' : 'Not found'}');
      print('- SharedPrefs access_token: ${accessToken != null ? 'Present' : 'Not found'}');
      
      if (authToken == null) {
        print('User is not authenticated - no valid token found');
        return false;
      }
      
      // Prepare request data
      final requestData = {
        'distance_km': distanceKm,
        'time_seconds': timeSeconds,
        'pace': pace,
        'calories_burned': caloriesBurned,
        'steps': steps,
        'date': date?.toIso8601String().split('T')[0] ?? 
                DateTime.now().toIso8601String().split('T')[0],
      };
      
      // Log request data for debugging
      print('Sending running activity data:');
      print(requestData);
      
      final response = await http.post(
        ApiConfig.runningActivity,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );
      
      // Detailed logging of response
      print('Running activity response status: ${response.statusCode}');
      print('Running activity response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Running activity successfully saved to backend');
        return true;
      } else {
        print('Failed to save running activity: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving running activity: $e');
      return false;
    }
  }

  // Fungsi untuk mendapatkan username dari token (profile)
  Future<String?> getUserName() async {
    try {
      // Use AuthHelper for consistent token management
      final token = await AuthHelper.getToken();
      
      // Fallback to SharedPreferences if needed
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      final authToken = token ?? accessToken;
      
      if (authToken == null) {
        print('User is not authenticated - no valid token found');
        return null;
      }
      
      print('Fetching user profile with token');
      
      final response = await http.get(
        ApiConfig.profile,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      
      print('Profile response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['username'] ?? 'User';
      } else {
        print('Failed to fetch user profile: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
  
  // Add function to verify authentication status
  Future<bool> verifyAuthentication() async {
    try {
      final token = await AuthHelper.getToken();
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      final authToken = token ?? accessToken;
      
      if (authToken == null) {
        return false;
      }
      
      // Test authentication with a simple profile request
      final response = await http.get(
        ApiConfig.profile,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Authentication verification error: $e');
      return false;
    }
  }
}