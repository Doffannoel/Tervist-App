import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFDFA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Tervist',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey.shade400,
                          child:
                              Text('1', style: TextStyle(color: Colors.black)),
                        ),
                        Expanded(
                          child: Divider(color: Colors.black26, thickness: 1),
                        ),
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child:
                              Text('2', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('Enter Details',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    _customField("Username", usernameController),
                    SizedBox(height: 10),
                    Text('Gender',
                        style: TextStyle(fontSize: 14, color: Colors.black)),
                    Row(
                      children: [
                        Expanded(child: _genderButton('Male', Icons.male)),
                        SizedBox(width: 10),
                        Expanded(child: _genderButton('Female', Icons.female)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _customField("Weight", weightController)),
                        SizedBox(width: 10),
                        Expanded(
                            child: _customField("Height", heightController)),
                      ],
                    ),
                    SizedBox(height: 10),
                    _customField("Age", ageController),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text('Fill in your data',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child:
                          Text('Next', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _customField(String hint, TextEditingController controller) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  Widget _genderButton(String title, IconData icon) => OutlinedButton.icon(
        icon: Icon(icon, color: Colors.black),
        label: Text(title, style: TextStyle(color: Colors.black)),
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
