import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'dart:async';

class AuthHelper {
  static const String TOKEN_KEY = 'auth_token';
  static const String ACCESS_TOKEN_KEY = 'access_token';
  static const String USER_ID_KEY = 'user_id';
  static const String USER_NAME_KEY = 'user_name';

  // Cache untuk mengurangi panggilan berulang
  static String? _cachedToken;
  static DateTime? _lastTokenValidation;
  static const Duration _tokenValidationCooldown = Duration(minutes: 30);

  // Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setString(ACCESS_TOKEN_KEY, token);

    // Update cached token
    _cachedToken = token;
    print('Token saved successfully');
  }

  // Get token from SharedPreferences
  static Future<String?> getToken() async {
    // Return cached token jika sudah ada
    if (_cachedToken != null) return _cachedToken;

    final prefs = await SharedPreferences.getInstance();

    // Coba ambil token dari TOKEN_KEY terlebih dahulu
    String? token = prefs.getString(TOKEN_KEY);

    // Jika tidak ada, coba dari ACCESS_TOKEN_KEY
    if (token == null || token.isEmpty) {
      token = prefs.getString(ACCESS_TOKEN_KEY);
      if (token != null && token.isNotEmpty) {
        // Sinkronkan token
        await prefs.setString(TOKEN_KEY, token);
      }
    }

    // Simpan ke cache
    _cachedToken = token;
    return token;
  }

  // Save user ID to SharedPreferences
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(USER_ID_KEY, userId);
  }

  // Get user ID from SharedPreferences
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(USER_ID_KEY);
  }

  // Save username to SharedPreferences
  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_NAME_KEY, userName);
  }

  // Get username from SharedPreferences
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_NAME_KEY);
  }

  // Clear auth data on logout
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(ACCESS_TOKEN_KEY);
    await prefs.remove(USER_ID_KEY);
    await prefs.remove(USER_NAME_KEY);

    // Reset cached token
    _cachedToken = null;
    _lastTokenValidation = null;
  }

  // Check if user is logged in dengan caching validasi token
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    // Cek apakah token sudah divalidasi baru-baru ini
    if (_lastTokenValidation != null &&
        DateTime.now().difference(_lastTokenValidation!) <
            _tokenValidationCooldown) {
      return true;
    }

    try {
      final response = await http.get(
        ApiConfig.profile,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10)); // Tambah timeout

      if (response.statusCode == 200) {
        // Update timestamp validasi terakhir
        _lastTokenValidation = DateTime.now();
        return true;
      }
      return false;
    } catch (e) {
      print('Token validation error: $e');
      // Kembalikan status terakhir jika ada error koneksi
      return _lastTokenValidation != null;
    }
  }

  // Get authentication headers for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': token != null ? 'Bearer $token' : '',
      'Content-Type': 'application/json',
    };
  }

  static Future<void> saveProfilePicture(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_picture', url);
  }

  static Future<String?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_picture');
  }
}
