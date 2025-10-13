import 'package:flutter/material.dart';

class CalendarDayCell extends StatelessWidget {
  final int? day;
  final bool isToday;
  final bool isSelected;
  final int reservationCount;
  final VoidCallback? onTap;

  CalendarDayCell({
    this.day,
    this.isToday = false,
    this.isSelected = false,
    this.reservationCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return SizedBox.shrink(); // Cellule vide
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: isToday ? Border.all(color: Color(0xFF2a5298), width: 2) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: _getTextColor(),
              ),
            ),
            if (reservationCount > 0) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF2a5298),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$reservationCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) return Color(0xFF2a5298).withOpacity(0.2);
    if (reservationCount > 0) return Colors.blue[50]!;
    return Colors.transparent;
  }

  Color _getTextColor() {
    if (isSelected) return Color(0xFF2a5298);
    return Colors.black87;
  }
}