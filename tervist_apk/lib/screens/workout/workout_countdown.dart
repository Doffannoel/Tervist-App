import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class WorkoutCountdown extends StatefulWidget {
  final VoidCallback onCountdownComplete;
  
  const WorkoutCountdown({
    Key? key,
    required this.onCountdownComplete,
  }) : super(key: key);

  @override
  State<WorkoutCountdown> createState() => _WorkoutCountdownState();
}

class _WorkoutCountdownState extends State<WorkoutCountdown> with SingleTickerProviderStateMixin {
  int _currentCount = 3;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    
    // Setup animation
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Start countdown
    _startCountdown();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  void _startCountdown() {
    // Start animation for the initial number
    _animationController.forward();
    
    // Setup timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCount > 1) {
        setState(() {
          _currentCount--;
          // Reset and restart animation for each number
          _animationController.reset();
          _animationController.forward();
        });
      } else {
        // Countdown complete
        _timer?.cancel();
        widget.onCountdownComplete();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Removed the AppBar completely to eliminate the back button
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Text(
                '$_currentCount',
                style: GoogleFonts.poppins(
                  fontSize: 150,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}