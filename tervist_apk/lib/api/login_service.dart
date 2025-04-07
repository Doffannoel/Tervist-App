import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';

class LoginService {
  static Future<bool> loginUser(String email, String password) async {
    final url = ApiConfig.login;

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString(
          'refresh_token', refreshToken); // untuk keperluan nanti

      return true;
    } else {
      print("Login failed: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Login gagal: ${jsonDecode(response.body)["detail"]}');
    }
  }
}
