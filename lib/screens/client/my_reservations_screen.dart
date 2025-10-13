import 'package:flutter/material.dart';
import '../../services/local_auth_service.dart';
import '../../services/reservation_service.dart';
import '../../models/reservation.dart';
import '../../widgets/reservation_card.dart';

class MyReservationsScreen extends StatefulWidget {
  @override
  _MyReservationsScreenState createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final _authService = LocalAuthService();
  final _reservationService = ReservationService();
  
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _authService.getCurrentUser();
      final reservations = await _reservationService.getUserReservations(user!['email']);
      
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes réservations'),
        backgroundColor: Color(0xFF2a5298),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReservations,
              child: _reservations.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _reservations.length,
                      itemBuilder: (context, index) {
                        return ReservationCard(
                        reservation: _reservations[index],
                        onCancel: (_reservations[index].isEnAttente || 
                        (_reservations[index].isRefusee && _reservations[index].dateConfirmee != null))
                        ? () => _handleCancel(_reservations[index])
                        : null,
                       onAcceptProposal: (_reservations[index].isRefusee && 
                       _reservations[index].dateConfirmee != null)
                       ? () => _handleAcceptProposal(_reservations[index])
                       : null,
                       );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🪁', style: TextStyle(fontSize: 80)),
          SizedBox(height: 16),
          Text(
            'Aucune réservation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Réservez votre premier stage !',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
void _handleCancel(Reservation reservation) async {
  String title = reservation.isEnAttente 
      ? 'Annuler la réservation ?' 
      : 'Refuser la proposition ?';
  
  String content = reservation.isEnAttente
      ? 'Êtes-vous sûr de vouloir annuler cette demande ?'
      : 'Êtes-vous sûr de refuser la proposition de l\'admin ?';

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Non'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('Oui, refuser'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    await _reservationService.cancelReservation(reservation.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reservation.isEnAttente 
            ? 'Réservation annulée' 
            : 'Proposition refusée'),
        backgroundColor: Colors.green,
      ),
    );
    
    _loadReservations();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _handleAcceptProposal(Reservation reservation) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Accepter la proposition ?'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vous allez confirmer la réservation pour:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          _buildProposalInfo(reservation), // ← Widget pour afficher les détails
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Accepter'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    await _reservationService.acceptProposal(reservation.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Réservation confirmée'),
        backgroundColor: Colors.green,
      ),
    );
    
    _loadReservations();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Ajoute ce widget helper dans la même classe
Widget _buildProposalInfo(Reservation reservation) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.green.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('📅', 'Date', 
          '${reservation.dateConfirmee!.day}/${reservation.dateConfirmee!.month}/${reservation.dateConfirmee!.year}'),
        SizedBox(height: 6),
        _buildInfoRow('🕒', 'Heure', reservation.heureConfirmee!),
        SizedBox(height: 6),
        _buildInfoRow('🪁', 'Stage', reservation.stageName),
        SizedBox(height: 6),
        _buildInfoRow('💰', 'Prix', '${reservation.prixFinal.toStringAsFixed(0)} TND'),
      ],
    ),
  );
}

Widget _buildInfoRow(String emoji, String label, String value) {
  return Row(
    children: [
      Text(emoji, style: TextStyle(fontSize: 16)),
      SizedBox(width: 8),
      Text(
        '$label: ',
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
}