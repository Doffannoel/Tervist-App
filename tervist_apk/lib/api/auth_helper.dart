import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'dart:async';

class AuthHelper {
  static const String TOKEN_KEY = 'auth_token';
  static const String ACCESS_TOKEN_KEY = 'access_token';
  static const String USER_ID_KEY = 'user_id';
  static const String USER_NAME_KEY = 'user_name';

  static String? _cachedToken;
  static DateTime? _lastTokenValidation;
  static const Duration _tokenValidationCooldown = Duration(minutes: 30);

  /// ✅ Simpan token ke SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setString(ACCESS_TOKEN_KEY, token);
    _cachedToken = token;
    print('✅ Token saved successfully');
  }

  /// 🧹 Bersihkan token saat login ulang atau logout
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(ACCESS_TOKEN_KEY);
    _cachedToken = null;
    print('🧹 Token cleared');
  }

  /// 🔐 Ambil token dari cache atau SharedPreferences
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(TOKEN_KEY);

    if (token == null || token.isEmpty) {
      token = prefs.getString(ACCESS_TOKEN_KEY);
      if (token != null && token.isNotEmpty) {
        await prefs.setString(TOKEN_KEY, token);
      }
    }

    _cachedToken = token;
    return token;
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(USER_ID_KEY, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(USER_ID_KEY);
  }

  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_NAME_KEY, userName);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_NAME_KEY);
  }

  /// 🔐 Logout: Bersihkan semua data login
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(ACCESS_TOKEN_KEY);
    await prefs.remove(USER_ID_KEY);
    await prefs.remove(USER_NAME_KEY);
    await prefs.remove('profile_picture');
    _cachedToken = null;
    _lastTokenValidation = null;
    print('🚫 Auth data cleared');
  }

  /// 🔁 Cek apakah user masih login dan token valid
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    if (_lastTokenValidation != null &&
        DateTime.now().difference(_lastTokenValidation!) <
            _tokenValidationCooldown) {
      return true;
    }

    try {
      final response = await http.get(
        ApiConfig.profile,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _lastTokenValidation = DateTime.now();
        return true;
      }
      return false;
    } catch (e) {
      print('⚠️ Token validation error: $e');
      return _lastTokenValidation != null;
    }
  }

  /// 🔧 Header autentikasi untuk request API
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': token != null ? 'Bearer $token' : '',
      'Content-Type': 'application/json',
    };
  }

  /// 🖼️ Foto profil user
  static Future<void> saveProfilePicture(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_picture', url);
  }

  static Future<String?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_picture');
  }

  static Future<void> refreshTokenIfNeeded() async {
    final isLoggedInNow = await isLoggedIn();
    if (!isLoggedInNow) {
      print('🔄 Token dianggap expired, redirect atau ambil ulang kalau perlu');
      // Lu bisa tambahin logic login ulang otomatis di sini
      // Atau redirect ke login screen
    } else {
      print('✅ Token masih valid');
    }
  }
}
