import 'package:flutter/material.dart';

class WarningFoodDialog extends StatelessWidget {
  final VoidCallback onLeave;
  final VoidCallback onBack;

  const WarningFoodDialog({
    Key? key,
    required this.onLeave,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App logo
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 2),
                const Text(
                  'ervist',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Warning icon
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC107),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.priority_high,
                color: Colors.black,
                size: 30,
                weight: 900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Warning title
          const Text(
            'Warning!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          
          // Warning message
          const Text(
            'You haven\'t saved your food log yet! Are you sure you want to leave? Any unsaved data will be lost.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Poppins',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Leave button
              Expanded(
                child: OutlinedButton(
                  onPressed: onLeave,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    side: const BorderSide(color: Colors.black, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Leave',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Back button
              Expanded(
                child: ElevatedButton(
                  onPressed: onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'Poppins',
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

// Example of how to use this dialog in your app:
void showWarningFoodDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return WarningFoodDialog(
        onLeave: () {
          // Handle leaving without saving
          Navigator.of(context).pop(); // Close the dialog
          Navigator.of(context).pop(); // Go back to previous screen
        },
        onBack: () {
          // Go back to food log to continue editing
          Navigator.of(context).pop(); // Close the dialog only
        },
      );
    },
  );
}

// Example of how to trigger this dialog when user attempts to leave a food logging screen
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if there are unsaved changes
        bool hasUnsavedChanges = true; // Replace with your actual logic
        
        if (hasUnsavedChanges) {
          showWarningFoodDialog(context);
          return false; // Prevent default back behavior
        }
        return true; // Allow back if no unsaved changes
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Food Log'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Check if there are unsaved changes
              bool hasUnsavedChanges = true; // Replace with your actual logic
              
              if (hasUnsavedChanges) {
                showWarningFoodDialog(context);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: const Center(
          child: Text('Your food logging form goes here'),
        ),
      ),
    );
  }
}