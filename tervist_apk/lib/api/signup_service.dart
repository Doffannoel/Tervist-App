import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/auth_helper.dart';
import 'package:tervist_apk/api/signup_data.dart';

class SignupService {
  static Future<http.Response> submitSignup(SignupData data) {
    return http.post(
      ApiConfig.signup,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );
  }

  static Future<bool> loginUser(String email, String password) async {
    final response = await http.post(
      ApiConfig.login,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Login response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token']; // sesuaikan nama field-nya

      if (token != null) {
        await AuthHelper.saveToken(token);
        return true;
      }
    }

    return false;
  }
}
