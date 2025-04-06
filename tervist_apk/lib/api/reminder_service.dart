import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/reminder_model.dart';
import 'package:tervist_apk/api/reminder_service.dart';

// // Add this extension to ApiConfig in api_config.dart:
// static Uri get reminders => Uri.parse('$baseUrl/api/reminders/');

class ReminderService {
  // Get all reminders
  Future<List<Reminder>> getReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Modify this URL to match your actual API endpoint
      final response = await http.get(
        ApiConfig.reminders,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Reminder.fromJson(json)).toList();
      } else {
        // For now, return empty list instead of throwing an exception
        print('Failed to load reminders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching reminders: $e');
      // Return empty list to prevent app crashes
      return [];
    }
  }

  // Create or update a reminder - simulated for now if API not ready
  Future<Reminder> saveReminder(Reminder reminder) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Try to call the real API
      try {
        final response = await http
            .post(
              ApiConfig.reminders,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
              body: json.encode(reminder.toJson()),
            )
            .timeout(Duration(seconds: 15));

        if (response.statusCode == 200 || response.statusCode == 201) {
          return Reminder.fromJson(json.decode(response.body));
        } else {
          print('API call failed with status: ${response.statusCode}');
          // Fall back to returning the provided reminder if API not ready
          return reminder;
        }
      } catch (apiError) {
        print('API error: $apiError - Using fallback');
        // Return the input reminder as a fallback
        return reminder;
      }
    } catch (e) {
      print('Error saving reminder: $e');
      return reminder; // Return the input as a fallback
    }
  }

  // Update a reminder's status - simulated for now if API not ready
  Future<Reminder> updateReminderStatus(
      int? id, bool isActive, String mealType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Only try to call API if we have an ID
      if (id != null) {
        try {
          final response = await http
              .patch(
                Uri.parse('${ApiConfig.reminders.toString()}/$id/'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $accessToken',
                },
                body: json.encode({'is_active': isActive}),
              )
              .timeout(Duration(seconds: 15));

          if (response.statusCode == 200) {
            return Reminder.fromJson(json.decode(response.body));
          } else {
            print('API status update failed: ${response.statusCode}');
            // Fall back to returning a mock reminder
            return Reminder(
              id: id,
              mealType: mealType,
              time: "08:00",
              isActive: isActive,
            );
          }
        } catch (apiError) {
          print('API error: $apiError - Using fallback');
        }
      }

      // If we're here, either there's no ID or the API call failed
      return Reminder(
        id: id,
        mealType: mealType,
        time: "08:00",
        isActive: isActive,
      );
    } catch (e) {
      print('Error updating reminder status: $e');
      return Reminder(
        id: id,
        mealType: mealType,
        time: "08:00",
        isActive: isActive,
      );
    }
  }
}
