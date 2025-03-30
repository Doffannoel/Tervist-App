// change_password_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'success_page.dart';

class ChangePasswordPage extends StatelessWidget {
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  ChangePasswordPage({super.key});

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

          // Label for New Password
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'New password',
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: newPassword,
            obscureText: true,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.visibility),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Label for Confirm Password
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Confirm password',
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: confirmPassword,
            obscureText: true,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.visibility),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 70),
          SizedBox(
            width: 270,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SuccessPage()),
                );
              },
              style: _buttonStyle(),
              child: const Text(
                'Save',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
    );
  }
}
