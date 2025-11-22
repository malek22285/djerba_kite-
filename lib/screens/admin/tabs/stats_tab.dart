import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/firebase_reservation_service.dart';
import '../../../widgets/admin/stat_card.dart';
import '../../../widgets/admin/stage_repartition_card.dart';
import '../../../widgets/stats_line_chart.dart'; // Nouveau widget
import '../../../widgets/period_selector.dart'; // Nouveau widget

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
    // Charger les stats du mois par défaut
    _loadStats(DateTime.now(), DateTime.now());
  }

  Future<void> _loadStats(DateTime start, DateTime end, {bool isCustom = false}) async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await _reservationService.getStatsForPeriod(start, end);
      
      setState(() {
        _stats = stats;
        _startDate = start;
        _endDate = end;
        _isCustomPeriod = isCustom;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des stats: $e');
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
        // Nouveau sélecteur de période
        PeriodSelector(
          onPeriodChanged: (start, end, {isCustom = false}) {
            _loadStats(start, end, isCustom: isCustom);
          }
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
        child: Text('Aucune donnée statistique disponible'),
      );
    }

    // Extraction sécurisée des données
    final totalReservations = _stats!['totalReservations'] ?? 0;
    final chiffreAffaires = _stats!['chiffreAffaires'] ?? 0.0;
    final revenuMoyen = _stats!['revenuMoyen'] ?? 0.0;
    final tauxConversion = _stats!['tauxConversion'] ?? '0';
    final weeklyReservations = _stats!['weeklyReservations'] ?? [0, 0, 0, 0];
    final repartitionStages = Map<String, int>.from(_stats!['repartitionStages'] ?? {});

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Métriques clés
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
              value: '$totalReservations',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            StatCard(
              title: 'Chiffre d\'affaires',
              value: '${chiffreAffaires.toStringAsFixed(0)} TND',
              icon: Icons.payments,
              color: Color(0xFF2a5298),
            ),
            StatCard(
              title: 'Revenu moyen',
              value: '${revenuMoyen.toStringAsFixed(0)} TND',
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
            StatCard(
              title: 'Taux réservation confirmée',
              value: '$tauxConversion%',
              icon: Icons.percent,
              color: Colors.purple,
            ),
          ],
        ),
        
        SizedBox(height: 20),
        
        // Graphique de réservations
        Text(
          'Évolution des réservations',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 10),

        
        SizedBox(height: 20),
        
        // Répartition par stage
        StageRepartitionCard(
          repartition: repartitionStages,
        ),
      ],
    );
  }
}