import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/auth_helper.dart'; // ⬅️ pastikan ini sudah ada

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

      // Simpan token ke AuthHelper
      await AuthHelper.saveToken(accessToken);

      // Ambil profil setelah login berhasil
      final profileRes = await http.get(
        ApiConfig.profile,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (profileRes.statusCode == 200) {
        final profile = jsonDecode(profileRes.body);

        // Simpan user ID dan username
        await AuthHelper.saveUserId(profile['id']);
        await AuthHelper.saveUserName(profile['username'] ?? 'User');
      } else {
        print('⚠️ Gagal mengambil profil');
      }

      // Simpan juga refresh_token jika dibutuhkan nanti
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('refresh_token', refreshToken);

      return true;
    } else {
      print("Login failed: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Login gagal: ${jsonDecode(response.body)["detail"]}');
    }
  }
}
