import 'package:flutter/material.dart';
import 'package:tervist_apk/screens/nutritions/nutrition_main.dart';

class ScanNowPopupPage extends StatelessWidget {
  const ScanNowPopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pop();
        await Future.delayed(Duration(milliseconds: 100));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NutritionMainPage()),
          (route) => false,
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/groupscan.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
