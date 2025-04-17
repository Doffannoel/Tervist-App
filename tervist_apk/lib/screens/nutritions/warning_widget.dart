import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fooddatabase_page.dart';


class WarningWidget extends StatelessWidget {
  final VoidCallback onLeave;
  final VoidCallback onBack;
  final String warningTitle;
  final String warningMessage;

  const WarningWidget({
    Key? key,
    required this.onLeave,
    required this.onBack,
    this.warningTitle = 'Warning!',
    this.warningMessage = 'You haven\'t saved your food log yet! Are you sure you want to leave? Any unsaved data will be lost.',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: ContentBox(
        warningTitle: warningTitle,
        warningMessage: warningMessage,
        onLeave: onLeave,
        onBack: onBack,
      ),
    );
  }
}

class ContentBox extends StatelessWidget {
  final String warningTitle;
  final String warningMessage;
  final VoidCallback onLeave;
  final VoidCallback onBack;

  const ContentBox({
    Key? key,
    required this.warningTitle,
    required this.warningMessage,
    required this.onLeave,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/nervist_logo.png',
                  height: 24,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Warning Icon
          Image.asset(
            'assets/images/warning.jpg',
            width: 60,
            height: 60,
          ),
          
          const SizedBox(height: 16),
          
          // Warning Title
          Text(
            warningTitle,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Warning Message
          Text(
            warningMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF666666),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Buttons Row
          Row(
            children: [
              // Leave Button
              Expanded(
                child: OutlinedButton(
                  onPressed: onLeave,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Leave',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Back Button
              Expanded(
                child: ElevatedButton(
                  onPressed: onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Extension method to show the warning dialog
extension WarningDialogExtension on BuildContext {
  Future<void> showWarningDialog({
    required VoidCallback onLeave,
    required VoidCallback onBack,
    String warningTitle = 'Warning!',
    String warningMessage = 'You haven\'t saved your food log yet! Are you sure you want to leave? Any unsaved data will be lost.',
  }) async {
    return showDialog(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WarningWidget(
          onLeave: onLeave,
          onBack: onBack,
          warningTitle: warningTitle,
          warningMessage: warningMessage,
        );
      },
    );
  }
}

// Usage example that integrates with your EditNutritionPage and FoodDatabasePage
class WarningHelper {
  static void showUnsavedChangesWarning(BuildContext context) {
    context.showWarningDialog(
      onLeave: () {
        // Navigate to FoodDatabasePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const FoodDatabasePage(),
          ),
        );
      },
      onBack: () {
        // Simply close the dialog and stay on current page
        Navigator.of(context).pop();
      },
    );
  }
}

// Import for usage example (remove in actual implementation)
