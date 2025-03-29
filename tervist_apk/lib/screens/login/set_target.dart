import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/api/signup_data.dart';

class SetTargetPage extends StatefulWidget {
  final SignupData signupData;
  const SetTargetPage({super.key, required this.signupData});

  @override
  State<SetTargetPage> createState() => _SetTargetPageState();
}

class _SetTargetPageState extends State<SetTargetPage> {
  String? _selectedActivityLevel;
  String? _selectedGoal;

  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
  ];

  final List<String> _goalOptions = [
    'Weight gain',
    'Maintain my current weight',
    'Weight loss'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBFDFA),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(''),
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
                          _stepCircle('2', Color(0xFFe2e8ef)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text('Enter Details',
                          style: GoogleFonts.poppins(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 20),
                      _customDropdown(
                        'Activity Level',
                        _activityLevels,
                        _selectedActivityLevel,
                        (String? newValue) {
                          setState(() {
                            _selectedActivityLevel = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      Text('What is your goal?',
                          style: GoogleFonts.montserrat(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(height: 10),
                      ..._goalOptions.map((goal) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: _goalButton(goal),
                          )),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedActivityLevel != null &&
                              _selectedGoal != null) {
                            // Navigate to next screen or process data
                            print('Activity Level: $_selectedActivityLevel');
                            print('Goal: $_selectedGoal');
                          } else {
                            // Show error or prevent navigation
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Please select all details')),
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
                          'Save',
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
              style: GoogleFonts.poppins(
                  color: color == Colors.black ? Colors.white : Colors.black,
                  fontSize: 13)),
        ),
      );

  Widget _customDropdown(String label, List<String> items,
      String? selectedValue, void Function(String?)? onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
              fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            hintText: 'Choose your activity level',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          isDense: true,
          menuMaxHeight: 250,
          icon: Icon(Icons.arrow_drop_down),
          items: [
            DropdownMenuItem<String>(
              value: 'Sedentary',
              child: _activityLevelItem('Sedentary',
                  'Daily activities require minimal effort such as resting, desk work or driving'),
            ),
            DropdownMenuItem<String>(
              value: 'Low Active',
              child: _activityLevelItem('Low Active',
                  'Daily activities require some effort such as standing, housework or light exercise'),
            ),
            DropdownMenuItem<String>(
              value: 'Active',
              child: _activityLevelItem('Active',
                  'Daily activities require effort such as standing, physical work or regular moderate exercise'),
            ),
            DropdownMenuItem<String>(
              value: 'Very Active',
              child: _activityLevelItem('Very Active',
                  'Daily activities require intense physical effort such as construction or regular vigorous exercise'),
            ),
          ],
          selectedItemBuilder: (context) => _activityLevels.map((level) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                level,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        )
      ],
    );
  }

  Widget _activityLevelItem(String title, String description) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _goalButton(String title) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor:
              _selectedGoal == title ? Colors.grey.shade300 : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Colors.grey),
        ),
        onPressed: () {
          if (title == 'Weight gain' || title == 'Weight loss') {
            _showTargetPopup(title: title);
          } else {
            setState(() {
              _selectedGoal = title;
              widget.signupData.goal = 'Maintain Weight';
              widget.signupData.targetWeight = null;
              widget.signupData.timeline = null;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                  color: Colors.black, fontWeight: FontWeight.w300),
            ),
          ),
        ),
      );

  void _showTargetPopup({required String title}) {
    final TextEditingController weightController = TextEditingController();
    String timelineValue = 'Weeks';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Set your Target',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'How much you want to ${title == "Weight gain" ? "gain" : "lose"}?',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter weight',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('kg',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Timeline',
                      style: GoogleFonts.poppins(fontSize: 13)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: timelineValue,
                      dropdownColor: Colors.white,
                      items: ['Weeks', 'Months'].map((e) {
                        return DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => timelineValue = val);
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final signupData = widget.signupData;
                    signupData.goal =
                        title == "Weight gain" ? "Weight Gain" : "Weight Loss";
                    signupData.targetWeight =
                        double.tryParse(weightController.text);
                    signupData.timeline = timelineValue;

                    Navigator.pop(context);
                    setState(() => _selectedGoal = title);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Set Goal',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.black)),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
