import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import 'calendar_day_cell.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final List<Reservation> monthReservations;
  final Function(DateTime) onDateSelected;

  CalendarGrid({
    required this.currentMonth,
    required this.selectedDate,
    required this.monthReservations,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    final today = DateTime.now();
    final isCurrentMonth = currentMonth.year == today.year && 
                          currentMonth.month == today.month;

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          _buildWeekdayLabels(),
          SizedBox(height: 8),
          _buildDaysGrid(
            daysInMonth,
            firstWeekday,
            today,
            isCurrentMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    return Row(
      children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid(
    int daysInMonth,
    int firstWeekday,
    DateTime today,
    bool isCurrentMonth,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 2;
        
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return CalendarDayCell();
        }
        
        final date = DateTime(currentMonth.year, currentMonth.month, dayNumber);
        final isToday = isCurrentMonth && dayNumber == today.day;
        final isSelected = _isDateSelected(date);
        final dayReservations = _getReservationsCount(date);
        
        return CalendarDayCell(
          day: dayNumber,
          isToday: isToday,
          isSelected: isSelected,
          reservationCount: dayReservations,
          onTap: () => onDateSelected(date),
        );
      },
    );
  }

  bool _isDateSelected(DateTime date) {
    return selectedDate != null &&
        selectedDate!.year == date.year &&
        selectedDate!.month == date.month &&
        selectedDate!.day == date.day;
  }

  int _getReservationsCount(DateTime date) {
    return monthReservations.where((r) =>
        r.dateConfirmee!.year == date.year &&
        r.dateConfirmee!.month == date.month &&
        r.dateConfirmee!.day == date.day).length;
  }
}