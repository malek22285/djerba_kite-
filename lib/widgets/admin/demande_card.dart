import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation.dart';
import '../reservation_status_badge.dart';

class DemandeCard extends StatelessWidget {
  final Reservation demande;
  final VoidCallback onAccept;
  final VoidCallback onPropose;
  final VoidCallback onReject;
  final bool isOld; // Plus de 24h

  DemandeCard({
    required this.demande,
    required this.onAccept,
    required this.onPropose,
    required this.onReject,
    this.isOld = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: isOld ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOld
            ? BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Divider(height: 24),
            _buildClientInfo(),
            SizedBox(height: 12),
            _buildReservationInfo(),
            SizedBox(height: 16),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (isOld)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '⚠️ +24h',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (isOld) SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                demande.userName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                demande.userPhone,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        ReservationStatusBadge(statut: demande.statut),
      ],
    );
  }

  Widget _buildClientInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, demande.userEmail),
          SizedBox(height: 6),
          _buildInfoRow(Icons.show_chart, 'Niveau: ${demande.niveauClient}'),
        ],
      ),
    );
  }

  Widget _buildReservationInfo() {
    return Column(
      children: [
        _buildDetailRow('Stage', demande.stageName, Icons.water_drop),
        SizedBox(height: 8),
        _buildDetailRow(
          'Date souhaitée',
          DateFormat('dd/MM/yyyy').format(demande.dateDemande),
          Icons.calendar_today,
        ),
        SizedBox(height: 8),
        _buildDetailRow(
          'Heure souhaitée',
          demande.heureDemande,
          Icons.access_time,
        ),
        SizedBox(height: 8),
        _buildDetailRow(
          'Prix',
          '${demande.prixFinal.toStringAsFixed(0)} TND',
          Icons.payments,
          color: Colors.green,
        ),
        if (demande.voucherCode != null) ...[
          SizedBox(height: 8),
          _buildDetailRow(
            'Voucher',
            demande.voucherCode!,
            Icons.confirmation_number,
            color: Colors.purple,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blue[700]),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.blue[900]),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReject,
            icon: Icon(Icons.close, size: 18),
            label: Text('Refuser'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPropose,
            icon: Icon(Icons.schedule, size: 18),
            label: Text('Proposer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: BorderSide(color: Colors.orange),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAccept,
            icon: Icon(Icons.check, size: 18),
            label: Text('Accepter'),
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
}