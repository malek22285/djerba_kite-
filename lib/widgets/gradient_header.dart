import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final String emoji;

  GradientHeader({
    required this.title,
    this.emoji = '🪁',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2a5298), Color(0xFF1e3c72)],
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 80)),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}