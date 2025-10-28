import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import 'reservation_status_badge.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;
  final VoidCallback? onAcceptProposal;

  ReservationCard({
    required this.reservation,
    this.onCancel,
    this.onAcceptProposal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 12),
            _buildInfo(),
            if (reservation.notesAdmin != null) ...[
              SizedBox(height: 12),
              _buildAdminNotes(),
            ],
            if (_shouldShowActions()) ...[
              SizedBox(height: 16),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            reservation.stageName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ReservationStatusBadge(statut: reservation.statut),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          Icons.calendar_today,
          'Date demandée',
          DateFormat('dd/MM/yyyy').format(reservation.dateDemande),
        ),
        SizedBox(height: 8),
        _buildInfoRow(
          Icons.access_time,
          'Heure demandée',
          reservation.heureDemande,
        ),
        if (reservation.isConfirmee && reservation.dateConfirmee != null) ...[
          Divider(height: 24),
          _buildInfoRow(
            Icons.check_circle,
            'Date confirmée',
            DateFormat('dd/MM/yyyy').format(reservation.dateConfirmee!),
            color: Colors.green,
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            'Heure confirmée',
            reservation.heureConfirmee ?? '',
            color: Colors.green,
          ),
        ],
        SizedBox(height: 8),
        _buildInfoRow(
          Icons.payments,
          'Prix',
          '${reservation.prixFinal.toStringAsFixed(0)} TND',
        ),
        if (reservation.voucherCode != null) ...[
          SizedBox(height: 8),
          _buildInfoRow(
            Icons.confirmation_number,
            'Voucher',
            reservation.voucherCode!,
            color: Colors.purple,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminNotes() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.amber[800]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              reservation.notesAdmin!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

bool _shouldShowActions() {
  // Si en attente sans proposition → bouton Annuler
  if (reservation.isEnAttente && reservation.dateConfirmee == null) return true;
  
  // Si en attente AVEC proposition → boutons Accepter ET Refuser
  if (reservation.isEnAttente && reservation.dateConfirmee != null) return true;
  
  // Si refusée AVEC proposition → boutons Accepter ET Refuser
  if (reservation.isRefusee && reservation.dateConfirmee != null) return true;
  
  return false;
}

Widget _buildActions(BuildContext context) {
  // CAS 1: En attente SANS proposition → Annuler seulement
  if (reservation.isEnAttente && reservation.dateConfirmee == null) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onCancel,
        icon: Icon(Icons.cancel_outlined),
        label: Text('Annuler la demande'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // CAS 2: En attente AVEC proposition OU Refusée avec proposition → 2 boutons
  if ((reservation.isEnAttente || reservation.isRefusee) && 
      reservation.dateConfirmee != null) {
    return Column(
      children: [
        // Afficher la proposition
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event_available, color: Colors.green[700], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Proposition de l\'admin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('dd/MM/yyyy').format(reservation.dateConfirmee!)}',
                style: TextStyle(color: Colors.green[900]),
              ),
              Text(
                'Heure: ${reservation.heureConfirmee}',
                style: TextStyle(color: Colors.green[900]),
              ),
            ],
          ),
        ),
        // Boutons Accepter / Refuser
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: Icon(Icons.close, size: 18),
                label: Text('Refuser'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAcceptProposal,
                icon: Icon(Icons.check, size: 18),
                label: Text('Accepter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  return SizedBox.shrink();
}
}