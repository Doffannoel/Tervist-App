import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';

class EditProfileService {
  /// Ambil data profil user (GET)
  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      ApiConfig.profile,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Failed to fetch profile: ${response.body}');
      return null;
    }
  }

  /// Update data profil user (PATCH) dengan dukungan upload foto
  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final uri = ApiConfig.profile; // Endpoint profile user
    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Tambahkan field biasa (kecuali file gambar)
    data.forEach((key, value) {
      if (value != null && key != 'profileImage') {
        request.fields[key] = value.toString();
      }
    });

    // Tambahkan file gambar jika ada dan valid
    if (data['profileImage'] != null) {
      final imagePath = data['profileImage'];
      final file = File(imagePath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', // nama field sesuai model Django
          imagePath,
        ));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("✅ Update Profile Response: ${response.statusCode}");
    print("📦 Body: ${response.body}");

    return response.statusCode == 200;
  }

  /// Logout → hapus token dari local storage
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
