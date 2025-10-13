import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/reservation_service.dart';
import '../../../models/reservation.dart';
import '../../../widgets/admin/calendar_day_cell.dart';
import '../../../widgets/admin/planning_reservation_card.dart';
import '../../../widgets/empty_state.dart';

class PlanningTab extends StatefulWidget {
  @override
  _PlanningTabState createState() => _PlanningTabState();
}

class _PlanningTabState extends State<PlanningTab> {
  final _reservationService = ReservationService();
  
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
      year: _currentMonth.year,
      month: _currentMonth.month,
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
        _buildHeader(),
        _buildCalendar(),
        if (_selectedDate != null) ...[
          Divider(height: 1),
          Expanded(child: _buildReservationsList()),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy', 'fr_FR').format(_currentMonth),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    final today = DateTime.now();
    final isCurrentMonth = _currentMonth.year == today.year && _currentMonth.month == today.month;

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          // Jours de la semaine
          Row(
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
          ),
          SizedBox(height: 8),
          
          // Grille du calendrier
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 42, // 6 semaines max
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekday + 2;
              
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return CalendarDayCell(); // Cellule vide
              }
              
              final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
              final isToday = isCurrentMonth && dayNumber == today.day;
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;
              
              final dayReservations = _monthReservations.where((r) =>
                  r.dateConfirmee!.year == date.year &&
                  r.dateConfirmee!.month == date.month &&
                  r.dateConfirmee!.day == date.day).length;
              
              return CalendarDayCell(
                day: dayNumber,
                isToday: isToday,
                isSelected: isSelected,
                reservationCount: dayReservations,
                onTap: () => _selectDate(date),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    final dayReservations = _monthReservations.where((r) =>
        r.dateConfirmee!.year == _selectedDate!.year &&
        r.dateConfirmee!.month == _selectedDate!.month &&
        r.dateConfirmee!.day == _selectedDate!.day).toList();

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          color: Color(0xFF2a5298).withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF2a5298)),
              SizedBox(width: 8),
              Text(
                DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate!),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                '${dayReservations.length} réservation${dayReservations.length > 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        Expanded(
          child: dayReservations.isEmpty
              ? EmptyState(
                  icon: Icons.event_busy,
                  title: 'Aucune réservation',
                  subtitle: 'Pas de réservation ce jour',
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: dayReservations.length,
                  itemBuilder: (context, index) {
                    return PlanningReservationCard(
                      reservation: dayReservations[index],
                    );
                  },
                ),
        ),
      ],
    );
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