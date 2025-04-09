import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static const String TOKEN_KEY = 'auth_token';
  static const String ACCESS_TOKEN_KEY = 'access_token'; // Add reference to the access_token key
  static const String USER_ID_KEY = 'user_id';
  static const String USER_NAME_KEY = 'user_name';

  // Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    
    // Also save as access_token for backward compatibility
    await prefs.setString(ACCESS_TOKEN_KEY, token);
    
    print('Token saved successfully to both TOKEN_KEY and ACCESS_TOKEN_KEY');
  }

  // Get token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try both token keys
    String? token = prefs.getString(TOKEN_KEY);
    
    // If not found, try access_token
    if (token == null || token.isEmpty) {
      token = prefs.getString(ACCESS_TOKEN_KEY);
      if (token != null && token.isNotEmpty) {
        print('Found token in ACCESS_TOKEN_KEY');
        // Sync the tokens if found in access_token
        await prefs.setString(TOKEN_KEY, token);
      }
    } else {
      print('Found token in TOKEN_KEY');
    }
    
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
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Get authentication headers for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      return {'Content-Type': 'application/json'};
    } else {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
  }
}