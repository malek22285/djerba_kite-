import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onTap;
  final bool isDate;

  DateTimePicker({
    required this.label,
    required this.icon,
    this.selectedDate,
    this.selectedTime,
    required this.onTap,
    this.isDate = true,
  });

  @override
  Widget build(BuildContext context) {
    String displayText;
    
    if (isDate) {
      displayText = selectedDate == null
          ? 'Sélectionner une date'
          : DateFormat('dd/MM/yyyy').format(selectedDate!);
    } else {
      displayText = selectedTime == null
          ? 'Sélectionner une heure'
          : selectedTime!.format(context);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF2a5298)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: (isDate ? selectedDate == null : selectedTime == null)
                ? Colors.grey[600]
                : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}