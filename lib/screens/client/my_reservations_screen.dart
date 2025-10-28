import 'package:flutter/material.dart';
import '../../services/firebase_reservation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/reservation.dart';
import '../../widgets/reservation_card.dart';

class MyReservationsScreen extends StatefulWidget {
  @override
  _MyReservationsScreenState createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final FirebaseReservationService _reservationService = FirebaseReservationService();

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    print('🔵 MY RESERVATIONS: Current user UID = ${firebaseUser?.uid}');
    
    if (firebaseUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mes réservations'),
          backgroundColor: Color(0xFF2a5298),
        ),
        body: Center(child: Text('Non connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes réservations'),
        backgroundColor: Color(0xFF2a5298),
      ),
      body: StreamBuilder<List<Reservation>>(
        stream: _reservationService.getMyReservations(firebaseUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Erreur de chargement'),
                ],
              ),
            );
          }

          final reservations = snapshot.data ?? [];

          if (reservations.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                
                // PRINTS DE DEBUG
                print('🔵 RESERVATION ${reservation.id}:');
                print('   - Statut: ${reservation.statut}');
                print('   - isEnAttente: ${reservation.isEnAttente}');
                print('   - isPropositionEnvoyee: ${reservation.isPropositionEnvoyee}');
                print('   - dateConfirmee: ${reservation.dateConfirmee}');
                print('   - heureConfirmee: ${reservation.heureConfirmee}');
                print('   - Show Accept Button: ${reservation.isPropositionEnvoyee}');
                
                return ReservationCard(
                  reservation: reservation,
                  onCancel: (reservation.isEnAttente || reservation.isPropositionEnvoyee)
                      ? () => _handleCancel(reservation)
                      : null,
                  onAcceptProposal: reservation.isPropositionEnvoyee
                      ? () => _handleAcceptProposal(reservation)
                      : null,
                );
              },
            ),
          );
        },
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(reservation.isPropositionEnvoyee 
            ? 'Refuser la proposition ?' 
            : 'Annuler la réservation ?'),
        content: Text(reservation.isPropositionEnvoyee
            ? 'Êtes-vous sûr de refuser la proposition de l\'admin ?'
            : 'Êtes-vous sûr de vouloir annuler cette demande ?'),
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
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reservation.isPropositionEnvoyee 
              ? 'Proposition refusée' 
              : 'Réservation annulée'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
            Expanded(child: Text('Accepter la proposition ?')),
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
            _buildProposalInfo(reservation),
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
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Réservation confirmée'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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