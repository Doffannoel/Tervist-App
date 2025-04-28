import 'package:flutter/material.dart';
import 'package:tervist_apk/screens/nutritions/nutrition_main.dart';

class ScanNowPopupPage extends StatelessWidget {
  const ScanNowPopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ketika tap luar gambar, langsung ke NutritionMainPage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NutritionMainPage()),
          (route) => false, // Hapus semua route sebelumnya
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () {}, // Tap di gambar -> tidak menutup
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
