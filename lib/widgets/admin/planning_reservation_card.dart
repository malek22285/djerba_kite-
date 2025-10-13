import 'package:flutter/material.dart';
import '../../models/reservation.dart';

class PlanningReservationCard extends StatelessWidget {
  final Reservation reservation;

  PlanningReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF2a5298),
          child: Text(
            reservation.heureConfirmee?.substring(0, 2) ?? '??',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          reservation.userName,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.stageName,
              style: TextStyle(fontSize: 12),
            ),
            Text(
              reservation.userPhone,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              reservation.heureConfirmee ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (reservation.voucherCode != null)
              Icon(Icons.confirmation_number, size: 14, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}