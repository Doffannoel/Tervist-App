import 'package:flutter/material.dart';

class FollowMeButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onPressed;
  final Color activeColor;
  
  const FollowMeButton({
    super.key,
    required this.isFollowing,
    required this.onPressed,
    this.activeColor = const Color.fromARGB(255, 0, 0, 0),
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Center(
            child: Icon(
              isFollowing ? Icons.my_location : Icons.location_searching,
              color: isFollowing ? activeColor : Colors.grey,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}