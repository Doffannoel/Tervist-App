import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/api/auth_helper.dart';
import 'package:tervist_apk/api/signup_data.dart';
import 'package:tervist_apk/api/signup_service.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/screens/homepage/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tervist_apk/screens/main_navigation.dart';

class UserDataPage extends StatefulWidget {
  final SignupData signupData;

  const UserDataPage({super.key, required this.signupData});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  Map<String, dynamic>? nutritionalData;

  @override
  void initState() {
    super.initState();
    fetchGoalSummary();
  }

  // Fetch Goal Summary based on user data from widget.signupData
  void fetchGoalSummary() async {
    try {
      print("DEBUG: Fetching nutritional data with user data...");

      // Ambil data dari widget.signupData (data pengguna yang diisi selama registrasi)
      final goal = widget.signupData.goal;
      final weight = widget.signupData.weight;
      final height = widget.signupData.height;
      final age = widget.signupData.age;
      final gender = widget.signupData.gender;

      // Validasi untuk memastikan weight dan height tidak null atau kurang dari 0
      if (weight == null || weight <= 0 || height == null || height <= 0) {
        print("ERROR: Weight or Height is invalid.");
        return; // Jangan kirim data jika ada yang invalid
      }

      // Debug log untuk memastikan data pengguna yang dikirim
      print(
          "DEBUG: User Data - Goal: $goal, Weight: $weight, Height: $height, Age: $age, Gender: $gender");

      // Menyiapkan data yang diperlukan untuk API call
      final body = {
        'goal': goal,
        'weight': weight,
        'height': height,
        'age': age,
        'gender': gender,
      };

      // Debugging: Memastikan data yang dikirim ke API
      print("DEBUG: Sending data to NutritionalTarget API: $body");

      // Memanggil API untuk menghitung target nutrisi tanpa autentikasi
      final response = await http.post(
        ApiConfig.calculateNutritionPreview,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // Debugging: Memeriksa status kode dan respons body
      print("DEBUG: API Response Status Code: ${response.statusCode}");
      print("DEBUG: API Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("DEBUG: Nutritional data from API: $data");

        setState(() {
          nutritionalData = data;
        });
      } else {
        print(
            "ERROR: Failed to fetch data from API. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Menangani kesalahan saat memanggil API
      print("ERROR: Exception occurred while calling API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/check.png', height: 63),
                      const SizedBox(height: 24),
                      Image.asset('assets/images/welcome.png',
                          height: 55, width: 270),
                      const SizedBox(height: 8),
                      Text(
                        'Your personalized fitness plan is all set—\ntime to kick off your journey!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        'Goal Summary',
                        Column(
                          children: [
                            _buildGoalItem(
                                'Goal Type:',
                                widget.signupData.goal ??
                                    'Maintain current weight'),
                            const SizedBox(height: 8),
                            _buildGoalItem(
                              'Target:',
                              '${widget.signupData.targetWeight != null ? widget.signupData.targetWeight!.toStringAsFixed(1) : widget.signupData.weight?.toStringAsFixed(1)} kg',
                            ),
                            const SizedBox(height: 8),
                            _buildGoalItem(
                              'Timeline:',
                              widget.signupData.timeline ?? '2 weeks',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        'Daily Recommendation',
                        nutritionalData == null
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'You can edit this anytime',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFF8E98A8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildMacroItem(
                                          'Calories',
                                          '${(nutritionalData!['calorie_target'] ?? 0).round()}',
                                          0.75,
                                          Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildMacroItem(
                                          'Carbs',
                                          '${(nutritionalData!['carbs_target'] ?? 0).round()}g',
                                          0.7,
                                          Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildMacroItem(
                                          'Protein',
                                          '${(nutritionalData!['protein_target'] ?? 0).round()}g',
                                          0.6,
                                          Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildMacroItem(
                                          'Fats',
                                          '${(nutritionalData!['fats_target'] ?? 0).round()}g',
                                          0.4,
                                          Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        'How to reach your goals:',
                        Column(
                          children: [
                            _buildTipItem(Icons.directions_run, 'Do exercises'),
                            const SizedBox(height: 8),
                            _buildTipItem(
                                Image.asset('assets/images/goal2.png'),
                                'Follow your daily calorie recommendation'),
                            const SizedBox(height: 8),
                            _buildTipItem(
                                Image.asset('assets/images/goal3.png'),
                                'Track your food'),
                            const SizedBox(height: 8),
                            _buildTipItem('assets/images/goal4.png',
                                'Balance your carbs, proteins, and fats'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              // STEP 1: Kirim data signup
                              final response = await SignupService.submitSignup(
                                  widget.signupData);

                              if (response.statusCode == 201) {
                                // STEP 2: Login setelah signup
                                final loginSuccess =
                                    await SignupService.loginUser(
                                  widget.signupData.email!,
                                  widget.signupData.password!,
                                );

                                if (loginSuccess) {
                                  // STEP 3: Ambil token setelah login berhasil
                                  final token = await AuthHelper.getToken();

                                  // STEP 4: Simpan target nutrisi dengan token (user sudah login)
                                  if (nutritionalData != null &&
                                      token != null) {
                                    final saveTargetResponse = await http.post(
                                      Uri.parse(
                                          '${ApiConfig.baseUrl}/api/nutritional-target/'),
                                      headers: {
                                        'Authorization': 'Bearer $token',
                                        'Content-Type': 'application/json',
                                      },
                                      body: jsonEncode({
                                        "calorie_target": (nutritionalData![
                                                    'calorie_target'] ??
                                                0)
                                            .toDouble(),
                                        "protein_target": (nutritionalData![
                                                    'protein_target'] ??
                                                0)
                                            .toDouble(),
                                        "carbs_target":
                                            (nutritionalData!['carbs_target'] ??
                                                    0)
                                                .toDouble(),
                                        "fats_target":
                                            (nutritionalData!['fats_target'] ??
                                                    0)
                                                .toDouble(),
                                      }),
                                    );

                                    print(
                                        "✅ Save NutritionalTarget response: ${saveTargetResponse.statusCode}");
                                    print(
                                        "✅ Save NutritionalTarget body: ${saveTargetResponse.body}");
                                  }

                                  // STEP 5: Navigasi ke MainNavigation
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MainNavigation()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Signup berhasil, tapi login gagal'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              } else {
                                // Signup gagal
                                final error = jsonDecode(response.body);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(error['detail'] ?? 'Signup gagal'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              print("❌ Exception during signup/login: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Terjadi kesalahan: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Finish',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildGoalItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem(
      String title, String value, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 14, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(dynamic icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          icon is IconData
              ? Icon(icon, size: 30, color: Colors.black87)
              : icon is Widget
                  ? SizedBox(width: 30, height: 30, child: icon)
                  : icon is String
                      ? SizedBox(
                          width: 30, height: 30, child: Image.asset(icon))
                      : Icon(Icons.circle, size: 20, color: Colors.black87),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
