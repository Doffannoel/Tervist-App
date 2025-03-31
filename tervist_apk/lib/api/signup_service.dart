import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/signup_data.dart';

class SignupService {
  static Future<http.Response> submitSignup(SignupData data) async {
    print(jsonEncode(data.toJson()));
    return await http.post(
      ApiConfig.signup,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data.toJson()),
    );
  }
}
