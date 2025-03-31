import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/api/signup_data.dart';
import 'package:tervist_apk/api/signup_service.dart';
import 'package:tervist_apk/screens/homepage/homepage.dart';

class UserDataPage extends StatelessWidget {
  final SignupData signupData;

  const UserDataPage({super.key, required this.signupData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBFDFA),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'User Data',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Row untuk Weight, Height, Age
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dataBox(
                  title: 'Weight',
                  value: signupData.weight.toString(),
                  unit: 'kg',
                ),
                _dataBox(
                  title: 'Height',
                  value: signupData.height.toString(),
                  unit: 'cm',
                ),
                _dataBox(
                  title: 'Age',
                  value: signupData.age.toString(),
                  unit: 'yrs',
                ),
              ],
            ),
            const SizedBox(height: 30),
            _infoTile(
              title: 'Activity Level',
              value: signupData.activityLevel ?? 'Not specified',
            ),
            const SizedBox(height: 16),
            _infoTile(
              title: 'Goal',
              value: signupData.goal ?? 'Not specified',
            ),
            const SizedBox(height: 16),
            if (signupData.targetWeight != null)
              _infoTile(
                title: 'Target Weight',
                value: '${signupData.targetWeight?.toStringAsFixed(1)} kg',
              ),
            const SizedBox(height: 16),
            if (signupData.timeline != null)
              _infoTile(
                title: 'Timeline',
                value: signupData.timeline!,
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final response = await SignupService.submitSignup(signupData);
                  print('RESPONSE: ${response.statusCode} ${response.body}');
                  if (response.statusCode == 201) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage()),
                    );
                  } else {
                    final error = jsonDecode(response.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error['detail'] ?? 'Signup failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
            )
          ],
        ),
      ),
    );
  }

  Widget _dataBox({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            style: GoogleFonts.montserrat(fontSize: 14),
          ),
        )
      ],
    );
  }
}
