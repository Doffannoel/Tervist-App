// change_password_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './success_page.dart';
import '/../api/api_config.dart';

class ChangePasswordPage extends StatefulWidget {
  final String otp;
  const ChangePasswordPage({super.key, required this.otp});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  bool isLoading = false;
  bool _obscureNewPassword = true;
  final bool _obscureConfirmPassword = true;

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      minimumSize: const Size(100, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _scaffoldCardTemplate({required Widget child}) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBFDFA),
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    final newPass = newPassword.text.trim();
    final confirmPass = confirmPassword.text.trim();

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      ApiConfig.resetPassword,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'otp': widget.otp,
        'new_password': newPass,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPage()),
      );
    } else {
      final detail = jsonDecode(response.body)['detail'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail ?? 'Failed to reset password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _scaffoldCardTemplate(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Image.asset('assets/images/logotervist.png'),
          ),
          const SizedBox(height: 41),
          const Icon(Icons.lock_outline, size: 48),
          const SizedBox(height: 16),
          Text(
            'Change Password',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please enter your new password',
            style: GoogleFonts.montserrat(fontSize: 15),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'New password',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: newPassword,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Confirm password',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: newPassword,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 70),
          SizedBox(
            width: 270,
            child: ElevatedButton(
              onPressed: isLoading ? null : _resetPassword,
              style: _buttonStyle(),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
