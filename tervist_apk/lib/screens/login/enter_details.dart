import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'set_target.dart';
import '/../api/signup_data.dart'; // pastikan path-nya sesuai struktur project kamu

class EnterDetails extends StatefulWidget {
  final SignupData signupData;
  const EnterDetails({super.key, required this.signupData});

  @override
  State<EnterDetails> createState() => _EnterDetailsState();
}

class _EnterDetailsState extends State<EnterDetails> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String gender = '';
  String? _errorMessage;

  // Validation state variables
  bool _isUsernameValid = true;
  bool _isWeightValid = true;
  bool _isHeightValid = true;
  bool _isAgeValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBFDFA),
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Image.asset('assets/images/logotervist.png',
                              height: 40, width: 129, fit: BoxFit.contain),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildProgressIndicator(),
                      const SizedBox(height: 20),
                      Text('Enter Details',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _customField("Username", usernameController,
                          isValid: _isUsernameValid),
                      const SizedBox(height: 10),
                      Text('Gender',
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Expanded(child: _genderButton('Male', Icons.male)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _genderButton('Female', Icons.female)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child: _labelWithField("Weight", weightController,
                                  isValid: _isWeightValid)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _labelWithField("Height", heightController,
                                  isValid: _isHeightValid)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: _labelWithField("Age", ageController,
                            isValid: _isAgeValid),
                      ),
                      const SizedBox(height: 10),
                      if (_errorMessage != null)
                        Row(
                          children: [
                            const Icon(Icons.error,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Text(_errorMessage!,
                                style: GoogleFonts.poppins(color: Colors.red)),
                          ],
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Next',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                      )
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

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle('1', Color(0xFFe2e8ef)),
        const SizedBox(width: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.horizontal,
                children: List.generate(
                  (constraints.constrainWidth() / 10).floor(),
                  (index) => const SizedBox(
                    width: 5,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        _stepCircle('2', Colors.white),
      ],
    );
  }

  Widget _stepCircle(String number, Color color) => Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(number,
              style: GoogleFonts.poppins(
                  color: color == Colors.black ? Colors.white : Colors.black,
                  fontSize: 13)),
        ),
      );

  Widget _customField(String hint, TextEditingController controller,
          {bool isValid = true}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hint,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: isValid ? Colors.black : Colors.red,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isValid ? Colors.grey : Colors.red,
                    width: isValid ? 1 : 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isValid ? Colors.grey : Colors.red,
                    width: isValid ? 1 : 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isValid ? Colors.black : Colors.red, width: 2),
              ),
            ),
          ),
        ],
      );

  Widget _labelWithField(String label, TextEditingController controller,
          {bool isValid = true}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: isValid ? Colors.black : Colors.red,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isValid ? Colors.grey : Colors.red,
                    width: isValid ? 1 : 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isValid ? Colors.grey : Colors.red,
                    width: isValid ? 1 : 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isValid ? Colors.black : Colors.red, width: 2),
              ),
            ),
          ),
        ],
      );

  Widget _genderButton(String title, IconData icon) => OutlinedButton.icon(
        icon: Icon(icon, color: Colors.black),
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(title,
              style: GoogleFonts.montserrat(
                  color: Colors.black, fontWeight: FontWeight.w800)),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              gender == title ? Colors.grey.shade300 : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Colors.grey),
        ),
        onPressed: () => setState(() => gender = title),
      );

  void _handleNext() {
    setState(() {
      _isUsernameValid = usernameController.text.isNotEmpty;
      _isWeightValid = weightController.text.isNotEmpty;
      _isHeightValid = heightController.text.isNotEmpty;
      _isAgeValid = ageController.text.isNotEmpty;

      if (!_isUsernameValid ||
          !_isWeightValid ||
          !_isHeightValid ||
          !_isAgeValid ||
          gender.isEmpty) {
        _errorMessage = 'Please fill in all fields';
        return;
      }

      _errorMessage = null;

      // Simpan ke SignupData
      final signupData = widget.signupData;
      signupData.username = usernameController.text;
      signupData.gender = gender;
      signupData.weight = double.tryParse(weightController.text);
      signupData.height = double.tryParse(heightController.text);
      signupData.age = int.tryParse(ageController.text);

      // Navigasi ke halaman berikut
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SetTargetPage(signupData: signupData),
        ),
      );
    });
  }
}
