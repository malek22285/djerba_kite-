import 'package:flutter/material.dart';
//import '../../../services/reservation_service.dart';
import '../../../services/firebase_reservation_service.dart';

import '../../../models/reservation.dart';
import '../../../widgets/admin/demande_card.dart';
import '../../../widgets/admin/admin_action_dialogs.dart';

class DemandesTab extends StatefulWidget {
  @override
  _DemandesTabState createState() => _DemandesTabState();
}

class _DemandesTabState extends State<DemandesTab> {
 final FirebaseReservationService _reservationService = FirebaseReservationService();
  List<Reservation> _demandes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  Future<void> _loadDemandes() async {
    setState(() => _isLoading = true);
    
    try {
      final demandes = await _reservationService.getPendingReservations();
      setState(() {
        _demandes = demandes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadDemandes,
            child: _demandes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _demandes.length,
                    itemBuilder: (context, index) {
                      final demande = _demandes[index];
                      final isOld = DateTime.now().difference(demande.createdAt).inHours > 24;
                      
                      return DemandeCard(
                        demande: demande,
                        isOld: isOld,
                        onAccept: () => _handleAccept(demande),
                        onPropose: () => _handlePropose(demande),
                        onReject: () => _handleReject(demande),
                      );
                    },
                  ),
          );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
              SizedBox(height: 16),
              Text(
                'Aucune demande en attente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Toutes les demandes sont traitées !',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleAccept(Reservation demande) async {
    final result = await AdminActionDialogs.showAcceptDialog(context, demande);
    if (result == null) return;

    try {
      await _reservationService.confirmReservation(
        reservationId: demande.id,
        dateConfirmee: result['date'],
        heureConfirmee: result['time'].format(context),
        remiseIndividuelle: result['remise'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Réservation confirmée'),
          backgroundColor: Colors.green,
        ),
      );

      _loadDemandes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handlePropose(Reservation demande) async {
    final result = await AdminActionDialogs.showProposeDialog(context, demande);
    if (result == null) return;

    try {
      await _reservationService.proposeAlternative(
        reservationId: demande.id,
        dateProposee: result['date'],
        heureProposee: result['time'].format(context),
        motif: result['motif'],
        remiseIndividuelle: result['remise'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Proposition envoyée'),
          backgroundColor: Colors.orange,
        ),
      );

      _loadDemandes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleReject(Reservation demande) async {
    final motif = await AdminActionDialogs.showRejectDialog(context);
    if (motif == null) return;

    try {
      await _reservationService.rejectReservation(
        reservationId: demande.id,
        motif: motif,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Demande refusée'),
          backgroundColor: Colors.red,
        ),
      );

      _loadDemandes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }
}