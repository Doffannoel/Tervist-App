import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/signup_data.dart';

class SignupService {
  static Future<http.Response> submitSignup(SignupData data) {
    return http.post(
      ApiConfig.signup,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );
  }

  static Future<http.Response> loginUser(String email, String password) {
    return http
        .post(
      ApiConfig.login,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    )
        .then((response) {
      print('Login response headers: ${response.headers}');
      print('Login response body: ${response.body}');
      return response;
    });
  }
}
