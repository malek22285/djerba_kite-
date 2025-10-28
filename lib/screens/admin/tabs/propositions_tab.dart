import 'package:flutter/material.dart';
import '../../../models/reservation.dart';
import '../../../services/firebase_reservation_service.dart';
import '../../../widgets/admin/demande_card.dart';

class PropositionsTab extends StatefulWidget {
  @override
  _PropositionsTabState createState() => _PropositionsTabState();
}

class _PropositionsTabState extends State<PropositionsTab> {
  final FirebaseReservationService _reservationService = FirebaseReservationService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Reservation>>(
      stream: _reservationService.getProposedReservations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        final propositions = snapshot.data ?? [];

        if (propositions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_send, size: 80, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  'Aucune proposition en attente',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Les propositions envoyées aux clients apparaîtront ici',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: propositions.length,
            itemBuilder: (context, index) {
              final proposition = propositions[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proposition.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    proposition.userEmail,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    proposition.userPhone,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                'En attente',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        Divider(height: 24),
        
        // Informations stage
        Row(
          children: [
            Icon(Icons.water_drop, size: 16, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                proposition.stageName,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        
        // Date et heure proposées
        if (proposition.dateConfirmee != null) ...[
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Date proposée: ${proposition.dateConfirmee!.day}/${proposition.dateConfirmee!.month}/${proposition.dateConfirmee!.year}',
                style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Heure proposée: ${proposition.heureConfirmee}',
                style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
        
        if (proposition.notesAdmin != null && proposition.notesAdmin!.isNotEmpty) ...[
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.note, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  proposition.notesAdmin!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ],
        
        SizedBox(height: 8),
        
        // Informations supplémentaires
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Niveau: ${proposition.niveauClient}',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
        
        if (proposition.voucherCode != null) ...[
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.confirmation_number, size: 16, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Voucher: ${proposition.voucherCode}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
        
        SizedBox(height: 12),
        
        // Message d'information
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'En attente de la réponse du client',
                  style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),
              );
            },
          ),
        );
      },
    );
  }
}