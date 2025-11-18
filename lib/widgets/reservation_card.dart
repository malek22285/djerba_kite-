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
        // Afficher date/heure demandée SEULEMENT si pas de proposition
        if (!reservation.isPropositionEnvoyee) ...[
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
        ],
        
        // Si confirmée, afficher date confirmée
        if (reservation.isConfirmee && reservation.dateConfirmee != null) ...[
          if (!reservation.isPropositionEnvoyee) Divider(height: 24),
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
        
        // Si proposition envoyée, afficher la proposition
        if (reservation.isPropositionEnvoyee && reservation.dateConfirmee != null) ...[
          Container(
            padding: EdgeInsets.all(12),
            constraints: BoxConstraints(minHeight: 80),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_available, color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Text(
                      '📅 Proposition de l\'admin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.orange[700]),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(reservation.dateConfirmee!),
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.orange[700]),
                    SizedBox(width: 8),
                    Text(
                      reservation.heureConfirmee ?? '',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
    // En attente sans proposition → Annuler
    if (reservation.isEnAttente && reservation.dateConfirmee == null) {
      return onCancel != null;
    }
    
    // Proposition envoyée → Accepter ET Refuser
    if (reservation.isPropositionEnvoyee) {
      return onAcceptProposal != null || onCancel != null;
    }
    
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

    // CAS 2: Proposition envoyée → Accepter ET Refuser
    if (reservation.isPropositionEnvoyee) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: Icon(Icons.close, size: 18),
              label: Text('Refuser'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onAcceptProposal,
              icon: Icon(Icons.check_circle, size: 18),
              label: Text('Accepter la proposition'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox.shrink();
  }
}