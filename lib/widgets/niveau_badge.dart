import 'package:flutter/material.dart';

class NiveauBadge extends StatelessWidget {
  final String niveau;
  final double fontSize;

  NiveauBadge({
    required this.niveau,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.7,
        vertical: fontSize * 0.3,
      ),
      decoration: BoxDecoration(
        color: _getNiveauColor(niveau),
        borderRadius: BorderRadius.circular(fontSize),
      ),
      child: Text(
        niveau,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getNiveauColor(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'débutant':
        return Colors.green;
      case 'intermédiaire':
        return Colors.orange;
      case 'confirmé':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}