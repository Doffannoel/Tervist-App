import 'package:flutter/material.dart';

class ScanNowPopupPage extends StatelessWidget {
  const ScanNowPopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // kalau klik di luar, close
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            EdgeInsets.zero, // supaya dialognya gak ada padding pinggir
        child: GestureDetector(
          onTap: () {}, // supaya klik di gambar gak nutup
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/groupscan.png',
              fit: BoxFit.cover, // Bikin gambar nge-cover seluruh layar
            ),
          ),
        ),
      ),
    );
  }
}
