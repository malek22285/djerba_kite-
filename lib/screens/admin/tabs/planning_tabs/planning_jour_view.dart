import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/firebase_reservation_service.dart';
import '../../../../models/reservation.dart';
import '../../../../widgets/admin/end_session_button.dart';

class PlanningJourView extends StatefulWidget {
  @override
  _PlanningJourViewState createState() => _PlanningJourViewState();
}

class _PlanningJourViewState extends State<PlanningJourView> {
  final FirebaseReservationService _reservationService = FirebaseReservationService();
  
  List<Reservation> _todayReservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayReservations();
  }

  Future<void> _loadTodayReservations() async {
    if (!mounted) return;  // ← Protection 1
    
    setState(() => _isLoading = true);
    
    try {
      final today = DateTime.now();
      final reservations = await _reservationService.getConfirmedReservationsForDay(
        today.year,
        today.month,
        today.day,
      );
      
      if (!mounted) return;  // ← Protection 2
      
      // Trier par heure
      reservations.sort((a, b) {
        final heureA = a.heureConfirmee ?? '00:00';
        final heureB = b.heureConfirmee ?? '00:00';
        return heureA.compareTo(heureB);
      });
      
      setState(() {
        _todayReservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ PLANNING JOUR ERROR: $e');
      
      if (!mounted) return;  // ← Protection 3
      
      setState(() {
        _todayReservations = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  return Column(
    children: [
      _buildDayHeader(), 
      Expanded(
        child: RefreshIndicator(
          onRefresh: _loadTodayReservations,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _todayReservations.isEmpty
                  ? _buildEmptyState()
                  : _buildReservationsList(),
        ),
      ),
    ],
  );
}

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucune réservation aujourd\'hui',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _todayReservations.length,
      itemBuilder: (context, index) {
        final reservation = _todayReservations[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reservation.userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                
                // Infos
                _buildInfoRow(Icons.surfing, reservation.stageName),
                SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, reservation.heureConfirmee ?? 'Non spécifiée'),
                SizedBox(height: 8),
                _buildInfoRow(Icons.phone, reservation.userPhone),
                
                if (reservation.voucherCode != null) ...[
                  SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.confirmation_number,
                    'Voucher: ${reservation.voucherCode}',
                    color: Colors.purple,
                  ),
                ],
                
                SizedBox(height: 16),
                
                // Bouton
                EndSessionButton(reservation: reservation),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
Widget _buildDayHeader() {
  return Container(
    padding: EdgeInsets.all(16),
    color: Color(0xFF2a5298).withOpacity(0.1),
    child: Row(
      children: [
        Icon(Icons.calendar_today, color: Color(0xFF2a5298)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now()),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          '${_todayReservations.length} réservation${_todayReservations.length > 1 ? 's' : ''}',
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    ),
  );
}
}