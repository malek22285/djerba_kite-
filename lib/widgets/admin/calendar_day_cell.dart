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
      return SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: _getTextColor(),
                  fontSize: 14,
                ),
              ),
            ),
            if (reservationCount > 0)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  constraints: BoxConstraints(minWidth: 18, minHeight: 18),  // ← CORRIGÉ
                  padding: EdgeInsets.all(3),  // ← CORRIGÉ
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$reservationCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,  // ← RÉDUIT
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isToday) return Colors.blue.withOpacity(0.2);
    if (isSelected) return Colors.blue.withOpacity(0.1);
    if (reservationCount > 0) return Colors.green.withOpacity(0.05);
    return Colors.transparent;
  }

  Color _getTextColor() {
    if (isToday) return Colors.blue;
    if (isSelected) return Colors.blue;
    return Colors.black87;
  }
}