import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/firebase_reservation_service.dart';
import '../../../widgets/admin/stat_card.dart';
import '../../../widgets/admin/stage_repartition_card.dart';

class StatsTab extends StatefulWidget {
  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  // 1. Initialisation du service (corrigée)
  final _reservationService = FirebaseReservationService();
  
  DateTime _selectedMonth = DateTime.now();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Assurer que la locale 'fr_FR' est disponible
    Intl.defaultLocale = 'fr_FR'; 
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    // 2. Appel de la méthode avec les deux arguments requis (corrigé)
    try {
      final stats = await _reservationService.getStatsForMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
      
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des stats: $e');
      setState(() {
        _isLoading = false;
        _stats = {}; // Initialise à une map vide en cas d'erreur
      });
      // Optionnel: Afficher un SnackBar ou un dialogue d'erreur
    }
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
              DateFormat('MMMM yyyy').format(_selectedMonth), // 'fr_FR' n'est pas nécessaire si Intl.defaultLocale est défini
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
    if (_stats == null || _stats!.isEmpty) {
      return Center(
        child: Text('Aucune donnée statistique disponible pour ce mois.'),
      );
    }

    // Sécurisation des valeurs pour éviter le NoSuchMethodError (le crash)
    final totalReservations = _stats!['totalReservations'] ?? 0;
    final chiffreAffaires = _stats!['chiffreAffaires'] ?? 0.0;
    final vouchersUtilises = _stats!['vouchersUtilises'] ?? 0;
    final repartitionStages = Map<String, int>.from(_stats!['repartitionStages'] ?? {});
    
    // Calcul sécurisé du revenu moyen
    final revenuMoyen = totalReservations > 0 ? (chiffreAffaires / totalReservations) : 0.0;

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
              value: '$totalReservations',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            StatCard(
              title: 'Chiffre d\'affaires',
              // 3. Utilisation sécurisée de toStringAsFixed(0)
              value: '${chiffreAffaires.toStringAsFixed(0)} TND', 
              icon: Icons.payments,
              color: Color(0xFF2a5298),
            ),
            StatCard(
              title: 'Vouchers utilisés',
              value: '$vouchersUtilises',
              icon: Icons.confirmation_number,
              color: Colors.purple,
            ),
            StatCard(
              title: 'Revenu moyen',
              // 3. Utilisation sécurisée du revenu moyen calculé
              value: '${revenuMoyen.toStringAsFixed(0)} TND',
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
          ],
        ),
        
        SizedBox(height: 20),
        
        // Répartition par stage
        StageRepartitionCard(
          repartition: repartitionStages,
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