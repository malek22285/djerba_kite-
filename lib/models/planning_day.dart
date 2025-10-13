import 'reservation.dart';

class PlanningDay {
  final DateTime date;
  final List<Reservation> reservations;

  PlanningDay({
    required this.date,
    required this.reservations,
  });

  bool get hasReservations => reservations.isNotEmpty;
  
  int get totalReservations => reservations.length;
}