import 'package:flutter/material.dart';

class ReservationButton extends StatelessWidget {
  final String text;
  final Future<void> Function()? onPressed;  // ← CHANGÉ ICI
  final bool isLoading;

  ReservationButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading || onPressed == null
            ? null
            : () async {
                await onPressed!();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2a5298),
          disabledBackgroundColor: Colors.grey[400],
          elevation: isLoading ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,  // ← CHANGÉ EN BLANC
                ),
              ),
      ),
    );
  }
}