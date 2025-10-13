import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation.dart';
import '../empty_state.dart';
import 'planning_reservation_card.dart';

class DayReservationsList extends StatelessWidget {
  final DateTime selectedDate;
  final List<Reservation> reservations;

  DayReservationsList({
    required this.selectedDate,
    required this.reservations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: reservations.isEmpty
              ? EmptyState(
                  icon: Icons.event_busy,
                  title: 'Aucune réservation',
                  subtitle: 'Pas de réservation ce jour',
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    return PlanningReservationCard(
                      reservation: reservations[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Color(0xFF2a5298).withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Color(0xFF2a5298)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '${reservations.length} réservation${reservations.length > 1 ? 's' : ''}',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}