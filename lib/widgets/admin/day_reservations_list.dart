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
  return LayoutBuilder(
    builder: (context, constraints) {
      return Column(
        children: [
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
    },
  );
}

 
}