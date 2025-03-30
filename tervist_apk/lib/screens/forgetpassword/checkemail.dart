// check_email_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './changepassword.dart';

class CheckEmailPage extends StatelessWidget {
  final List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());

  CheckEmailPage({super.key});

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
          const Icon(Icons.mail_outline, size: 48),
          const SizedBox(height: 16),
          Text(
            'Check Your Email',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We’ve sent the code to your email',
            style: GoogleFonts.poppins(fontSize: 15),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: otpControllers
                .map((ctrl) => SizedBox(
                      width: 60,
                      height: 60,
                      child: TextField(
                        controller: ctrl,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 24),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 40),
          Text('Codes expires in 00:00',
              style: GoogleFonts.montserrat(
                  fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Send again',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChangePasswordPage()),
                    );
                  },
                  style: _buttonStyle(),
                  child: const Text(
                    'Verify',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
