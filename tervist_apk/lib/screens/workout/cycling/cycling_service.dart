import 'package:http/http.dart' as http;
import 'package:tervist_apk/screens/workout/map_service.dart';
import 'dart:convert';
import '/api/api_config.dart';
import '/api/auth_helper.dart';

class CyclingService {
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs'; // ✅ Format 'HH:MM:SS' yang Django mau
  }

  Future<bool> saveCyclingActivity({
    required DateTime date,
    required Duration duration,
    required double distanceKm,
    required double avgSpeedKmh,
    required double maxSpeedKmh,
    int elevationGainM = 0,
    required int durationSeconds,
  }) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        print('No authentication token found');
        return false;
      }

      final routePoints = MapService.getRouteHistory();
      final routeData = routePoints
          .map((e) => {
                'latitude': e.latitude,
                'longitude': e.longitude,
              })
          .toList();

      // Use your formatting function instead of direct conversion
      final formattedDuration = _formatDuration(durationSeconds);

      // Round values to meet validation requirements
// Round values to meet validation requirements
      final roundedDistance = double.parse(distanceKm.toStringAsFixed(2));
      final roundedAvgSpeed =
          double.parse(avgSpeedKmh.toStringAsFixed(1)); // Changed from 2 to 1
      final roundedMaxSpeed =
          double.parse(maxSpeedKmh.toStringAsFixed(1)); // Changed from 2 to 1

      // Create the route data string
      final routeDataString = json.encode(routeData);

      final response = await http.post(
        ApiConfig.cyclingActivity,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'date': date.toIso8601String().split('T')[0],
          'duration': formattedDuration,
          'distance_km': roundedDistance,
          'avg_speed_kmh': roundedAvgSpeed,
          'max_speed_kmh': roundedMaxSpeed,
          'elevation_gain_m': elevationGainM,
          'route_data': routeDataString,
        }),
      );

      if (response.statusCode != 201) {
        print('Error response: ${response.body}'); // Print actual error message
      }

      return response.statusCode == 201;
    } catch (e) {
      print('Error saving cycling activity: $e');
      return false;
    }
  }

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

  Future<String?> getUserName() async {
    try {
      String? cachedName = await AuthHelper.getUserName();
      if (cachedName != null && cachedName.isNotEmpty) {
        return cachedName;
      }

      final token = await AuthHelper.getToken();
      if (token == null) {
        print('No authentication token found');
        return null;
      }

      final response = await http.get(
        ApiConfig.profile,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final username = data['username'];

        if (username != null) {
          await AuthHelper.saveUserName(username);
        }

        return username;
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  Future<String?> getProfileImageUrl() async {
    try {
      String? cachedImageUrl = await AuthHelper.getProfilePicture();
      if (cachedImageUrl != null && cachedImageUrl.isNotEmpty) {
        return cachedImageUrl;
      }

      final token = await AuthHelper.getToken();
      if (token == null) {
        print('No authentication token found');
        return null;
      }

      final response = await http.get(
        ApiConfig.profile,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profileImageUrl = data['profile_picture'];

        if (profileImageUrl != null) {
          await AuthHelper.saveProfilePicture(profileImageUrl);
        }

        return profileImageUrl;
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching profile image URL: $e');
      return null;
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
