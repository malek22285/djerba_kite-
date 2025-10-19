import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import '../../../services/reservation_service.dart';
import '../../../services/firebase_reservation_service.dart';
import '../../../widgets/admin/stat_card.dart';
import '../../../widgets/admin/stage_repartition_card.dart';

class StatsTab extends StatefulWidget {
  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  final _reservationService = ReservationService();
  
  DateTime _selectedMonth = DateTime.now();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    final stats = await _reservationService.getStatsForMonth(
      year: _selectedMonth.year,
      month: _selectedMonth.month,
    );
    
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: _buildContent(),
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
              DateFormat('MMMM yyyy', 'fr_FR').format(_selectedMonth),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildContent() {
    if (_stats == null) return SizedBox.shrink();

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Cartes principales
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            StatCard(
              title: 'Réservations',
              value: '${_stats!['totalReservations']}',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            StatCard(
              title: 'Chiffre d\'affaires',
              value: '${_stats!['chiffreAffaires'].toStringAsFixed(0)} TND',
              icon: Icons.payments,
              color: Color(0xFF2a5298),
            ),
            StatCard(
              title: 'Vouchers utilisés',
              value: '${_stats!['vouchersUtilises']}',
              icon: Icons.confirmation_number,
              color: Colors.purple,
            ),
            StatCard(
              title: 'Revenu moyen',
              value: _stats!['totalReservations'] > 0
                  ? '${(_stats!['chiffreAffaires'] / _stats!['totalReservations']).toStringAsFixed(0)} TND'
                  : '0 TND',
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
          ],
        ),
        
        SizedBox(height: 20),
        
        // Répartition par stage
        StageRepartitionCard(
          repartition: Map<String, int>.from(_stats!['repartitionStages']),
        ),
      ],
    );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadStats();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _loadStats();
  }
}