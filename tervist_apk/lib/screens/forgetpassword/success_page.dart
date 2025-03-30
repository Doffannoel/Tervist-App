// success_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/screens/login/signup_screen.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      minimumSize: const Size(double.infinity, 50),
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
      // Removed invalid parameter 'sizedBox'
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
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
          Image.asset('assets/images/succes.png', height: 100),
          const SizedBox(height: 16),
          Text(
            'Success!',
            style:
                GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 50),
          Text(
            'You have successfully confirmed your new password.Please, use your new password when logging in',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          const SizedBox(height: 70),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AuthPage()),
                );
              },
              style: _buttonStyle(),
              child: Text(
                'Done',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
    );
  }
}
