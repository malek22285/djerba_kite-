import 'package:flutter/material.dart';
//import '../../../services/reservation_service.dart';
import '../../../services/firebase_reservation_service.dart';
import '../../../services/whatsapp_service.dart';
import '../../../models/reservation.dart';
import '../../../widgets/admin/demande_card.dart';
import '../../../widgets/admin/admin_action_dialogs.dart';

class DemandesTab extends StatefulWidget {
  @override
  _DemandesTabState createState() => _DemandesTabState();
}

class _DemandesTabState extends State<DemandesTab> {
 final FirebaseReservationService _reservationService = FirebaseReservationService();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
  }

  Future<void> _loadDemandes() async {
    setState(() => _isLoading = true);
    
    try {
      final demandes = await _reservationService.getPendingReservations();
      setState(() {
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  @override
Widget build(BuildContext context) {
  return StreamBuilder<List<Reservation>>(
    stream: _reservationService.getPendingReservations(),
    builder: (context, snapshot) {
      // État de chargement
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      // Erreur
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Erreur: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        );
      }

      // Récupérer les demandes
      final demandes = snapshot.data ?? [];

      // Aucune demande
      if (demandes.isEmpty) {
        return _buildEmptyState();
      }

      // Afficher les demandes
      return RefreshIndicator(
        onRefresh: () async {
          // Le stream se rafraîchit automatiquement
          await Future.delayed(Duration(milliseconds: 500));
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: demandes.length,
          itemBuilder: (context, index) {
            final demande = demandes[index];
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
    },
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
    demande.id,
    result['date'],
    result['time'].format(context),
    remiseIndividuelle: result['remise'] ?? 0,
  );

   await WhatsAppService.sendConfirmationMessage(
      phoneNumber: demande.userPhone,
      reservation: demande.copyWith(
        dateConfirmee: result['date'],
        heureConfirmee: result['time'].format(context),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Réservation confirmée'),
        backgroundColor: Colors.green,
      ),
    );
    
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
        demande.id,
        result['date'],
        result['time'].format(context),
        result['motif'],
      );

     await WhatsAppService.sendProposalMessage(
  phoneNumber: demande.userPhone,
  reservation: demande.copyWith(
    dateConfirmee: result['date'],  // ✅ BON
    heureConfirmee: result['heure'],  // ✅ BON
    notesAdmin: result['notes'],
  ),
);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Proposition envoyée'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

Future<void> _handleReject(Reservation demande) async {
  print('🔵 Bouton Refuser cliqué pour réservation: ${demande.id}');
  
  final motif = await AdminActionDialogs.showRejectDialog(context);
  
  print('🔵 Motif de rejet: $motif');
  
  if (motif == null) {
    print('❌ Aucun motif sélectionné');
    return;
  }

  try {
    print('🔵 Tentative de rejet de la réservation');
    await _reservationService.rejectReservation(
      demande.id, motif,
    );

await WhatsAppService.sendRejectionMessage(
  phoneNumber: demande.userPhone,
  reservation: demande,
  reason: motif,  // ✅ BON
);

    print('✅ Réservation rejetée avec succès');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Demande refusée'),
        backgroundColor: Colors.red,
      ),
    );

    _loadDemandes();
  } catch (e) {
    print('❌ Erreur lors du rejet: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
    );
  }
}
}