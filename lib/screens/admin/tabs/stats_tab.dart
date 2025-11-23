import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/firebase_reservation_service.dart';
import '../../../widgets/admin/stat_card.dart';
import '../../../widgets/admin/stage_repartition_card.dart';
import '../../../widgets/stats_line_chart.dart';
import '../../../widgets/period_selector.dart';

class StatsTab extends StatefulWidget {
  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  final _reservationService = FirebaseReservationService();
  
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCustomPeriod = false;

@override
void initState() {
  super.initState();

}

  Future<void> _loadStats(DateTime start, DateTime end, {bool isCustom = false}) async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final stats = await _reservationService.getStatsForPeriod(start, end);
      
      if (!mounted) return;
      
      setState(() {
        _stats = stats;
        _startDate = start;
        _endDate = end;
        _isCustomPeriod = isCustom;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ STATS ERROR: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _stats = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PeriodSelector(
          onPeriodChanged: (start, end, {isCustom = false}) {
            _loadStats(start, end, isCustom: isCustom);
          },
        ),
        
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildStatsContent(),
        ),
      ],
    );
  }

 Widget _buildStatsContent() {
  if (_stats == null || _stats!.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Aucune donnée statistique disponible',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  final totalReservations = _stats!['totalReservations'] ?? 0;
  final chiffreAffaires = _stats!['chiffreAffaires'] ?? 0.0;
  final revenuMoyen = _stats!['revenuMoyen'] ?? 0.0;
  final tauxConversion = _stats!['tauxConversion'] ?? 0;
  final repartitionStages = Map<String, int>.from(_stats!['repartitionStages'] ?? {});

  return SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Première ligne: 2 cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Réservations',
                value: '$totalReservations',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Chiffre d\'affaires',
                value: '${chiffreAffaires.toStringAsFixed(0)} TND',
                icon: Icons.payments,
                color: Color(0xFF2a5298),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12),
        
        // Deuxième ligne: 2 cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Revenu moyen',
                value: '${revenuMoyen.toStringAsFixed(0)} TND',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Taux confirmation',
                value: '$tauxConversion%',
                icon: Icons.percent,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 24),
        
        StageRepartitionCard(
          repartition: repartitionStages,
        ),
      ],
    ),
  );
}
}