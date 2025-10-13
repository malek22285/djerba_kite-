import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/voucher.dart';

class VoucherDetailsDialog extends StatelessWidget {
  final Voucher voucher;

  VoucherDetailsDialog({required this.voucher});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.purple),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              voucher.code,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Statut', voucher.statut.toUpperCase()),
            _buildInfoRow(
              'Heures',
              '${voucher.heuresRestantes}h / ${voucher.heuresInitiales}h',
            ),
            if (voucher.clientAssigne != null)
              _buildInfoRow('Client', voucher.clientAssigne!),
            if (voucher.dateExpiration != null)
              _buildInfoRow(
                'Expiration',
                DateFormat('dd/MM/yyyy').format(voucher.dateExpiration!),
              ),
            if (voucher.notes != null) ...[
              SizedBox(height: 12),
              Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(voucher.notes!, style: TextStyle(fontSize: 13)),
            ],
            if (voucher.historique.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Historique d\'utilisation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...voucher.historique.map((usage) => _buildUsageItem(usage)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Fermer'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(VoucherUsage usage) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.purple),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${usage.heuresUtilisees}h utilisées',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(usage.date),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}