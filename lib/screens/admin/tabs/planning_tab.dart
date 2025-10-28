import 'package:flutter/material.dart';
//import '../../../services/reservation_service.dart';
import '../../../services/firebase_reservation_service.dart';
import '../../../models/reservation.dart';
import '../../../widgets/admin/planning_header.dart';
import '../../../widgets/admin/calendar_grid.dart';
import '../../../widgets/admin/day_reservations_list.dart';
import '../../../widgets/empty_state.dart';

class PlanningTab extends StatefulWidget {
  @override
  _PlanningTabState createState() => _PlanningTabState();
}

class _PlanningTabState extends State<PlanningTab> {
  final FirebaseReservationService _reservationService = FirebaseReservationService();
  
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  List<Reservation> _monthReservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthReservations();
  }

  Future<void> _loadMonthReservations() async {
    setState(() => _isLoading = true);
    
    final reservations = await _reservationService.getConfirmedReservationsForMonth(
       _currentMonth.year,
      _currentMonth.month,
    );
    
    setState(() {
      _monthReservations = reservations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlanningHeader(
          currentMonth: _currentMonth,
          onPrevious: _previousMonth,
          onNext: _nextMonth,
        ),
        _isLoading
            ? Expanded(child: Center(child: CircularProgressIndicator()))
            : CalendarGrid(
                currentMonth: _currentMonth,
                selectedDate: _selectedDate,
                monthReservations: _monthReservations,
                onDateSelected: _selectDate,
              ),
        if (_selectedDate != null) ...[
          Divider(height: 1),
          Expanded(
            child: DayReservationsList(
              selectedDate: _selectedDate!,
              reservations: _getDayReservations(),
            ),
          ),
        ] else
          Expanded(
            child: EmptyState(
              icon: Icons.touch_app,
              title: 'Sélectionnez un jour',
              subtitle: 'Cliquez sur un jour pour voir les réservations',
            ),
          ),
      ],
    );
  }

  List<Reservation> _getDayReservations() {
    return _monthReservations.where((r) =>
        r.dateConfirmee!.year == _selectedDate!.year &&
        r.dateConfirmee!.month == _selectedDate!.month &&
        r.dateConfirmee!.day == _selectedDate!.day).toList();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDate = null;
    });
    _loadMonthReservations();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDate = null;
    });
    _loadMonthReservations();
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
  }
}