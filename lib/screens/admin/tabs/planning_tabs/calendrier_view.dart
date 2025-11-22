import 'package:flutter/material.dart';
import '../../../../services/firebase_reservation_service.dart';
import '../../../../models/reservation.dart';
import '../../../../widgets/admin/planning_header.dart';
import '../../../../widgets/admin/calendar_grid.dart';
import '../../../../widgets/empty_state.dart';

class CalendrierView extends StatefulWidget {
  @override
  _CalendrierViewState createState() => _CalendrierViewState();
}

class _CalendrierViewState extends State<CalendrierView> {
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
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    final reservations = await _reservationService.getConfirmedReservationsForMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    
    if (!mounted) return;
    
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
        if (_isLoading)
          Expanded(child: Center(child: CircularProgressIndicator()))
        else ...[
          SizedBox(
            height: 380,
            child: CalendarGrid(
              currentMonth: _currentMonth,
              selectedDate: _selectedDate,
              monthReservations: _monthReservations,
              onDateSelected: _selectDate,
            ),
          ),
          if (_selectedDate != null) ...[
            Divider(height: 1),
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 20, color: Colors.blue[700]),
                  SizedBox(width: 8),
                  Text(
                    '${_getDayReservations().length} réservation(s) le ${_selectedDate!.day}/${_selectedDate!.month}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _getDayReservations().isEmpty
                  ? Center(
                      child: Text(
                        'Aucune réservation ce jour',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: _getDayReservations().length,
                      itemBuilder: (context, index) {
                        final reservation = _getDayReservations()[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Icon(Icons.person, color: Colors.blue[700], size: 20),
                            ),
                            title: Text(
                              reservation.userName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              '${reservation.stageName} - ${reservation.heureConfirmee ?? ""}',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        );
                      },
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