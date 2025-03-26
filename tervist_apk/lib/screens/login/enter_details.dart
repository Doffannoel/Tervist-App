import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'set_target.dart'; // Ensure this import is present

class EnterDetails extends StatefulWidget {
  const EnterDetails({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBFDFA),
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                          SizedBox(width: 8),
                          Image.asset('assets/images/logotervist.png',
                              height: 40, width: 129, fit: BoxFit.contain),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _stepCircle('1', Color(0xFFe2e8ef)),
                          SizedBox(width: 10),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Flex(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  direction: Axis.horizontal,
                                  children: List.generate(
                                    (constraints.constrainWidth() / 10).floor(),
                                    (index) => SizedBox(
                                      width: 5,
                                      height: 1,
                                      child: DecoratedBox(
                                        decoration:
                                            BoxDecoration(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          _stepCircle('2', Colors.white),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text('Enter Details',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      _customField("Username", usernameController),
                      SizedBox(height: 10),
                      Text('Gender',
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Expanded(child: _genderButton('MALE', Icons.male)),
                          SizedBox(width: 10),
                          Expanded(
                              child: _genderButton('FEMALE', Icons.female)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child:
                                  _labelWithField("Weight", weightController)),
                          SizedBox(width: 10),
                          Expanded(
                              child:
                                  _labelWithField("Height", heightController)),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: _labelWithField("Age", ageController),
                      ),
                      SizedBox(height: 10),
                      if (_errorMessage != null)
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 16),
                            SizedBox(width: 4),
                            Text(_errorMessage!,
                                style: GoogleFonts.poppins(color: Colors.red)),
                          ],
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Validate fields
                          if (usernameController.text.isEmpty ||
                              weightController.text.isEmpty ||
                              heightController.text.isEmpty ||
                              ageController.text.isEmpty) {
                            setState(() {
                              _errorMessage =
                                  'Fill in your data'; // Set error message
                            });
                          } else {
                            setState(() {
                              _errorMessage =
                                  null; // Clear error message if all fields are filled
                            });
                            // Navigate to Set Target page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetTargetPage()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
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
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 13)),
        ),
      );

  Widget _customField(String hint, TextEditingController controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hint,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      );

  Widget _labelWithField(String label, TextEditingController controller) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
          side: BorderSide(color: Colors.grey),
        ),
        onPressed: () => setState(() => gender = title),
      );
}
