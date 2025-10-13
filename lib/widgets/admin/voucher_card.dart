import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/voucher.dart';

class VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  VoucherCard({
    required this.voucher,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 12),
              _buildProgressBar(),
              SizedBox(height: 12),
              _buildDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Text(
            voucher.code,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(width: 8),
        _buildStatusBadge(),
        Spacer(),
        IconButton(
          icon: Icon(Icons.edit, size: 20),
          onPressed: onEdit,
          color: Color(0xFF2a5298),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;
    String text;

    switch (voucher.statut) {
      case 'actif':
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Actif';
        break;
      case 'utilise':
        color = Colors.grey;
        icon = Icons.block;
        text = 'Utilisé';
        break;
      case 'expire':
        color = Colors.red;
        icon = Icons.cancel;
        text = 'Expiré';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        text = 'Inconnu';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Heures restantes',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            Text(
              '${voucher.heuresRestantes}h / ${voucher.heuresInitiales}h',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2a5298),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: voucher.heuresRestantes / voucher.heuresInitiales,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              voucher.heuresRestantes > 0 ? Colors.purple : Colors.grey,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (voucher.clientAssigne != null)
          _buildChip(Icons.person, voucher.clientAssigne!, Colors.blue),
        if (voucher.stageType != null)
          _buildChip(Icons.water_drop, 'Stage spécifique', Colors.orange),
        if (voucher.dateExpiration != null)
          _buildChip(
            Icons.calendar_today,
            'Exp: ${DateFormat('dd/MM/yy').format(voucher.dateExpiration!)}',
            voucher.dateExpiration!.isBefore(DateTime.now())
                ? Colors.red
                : Colors.grey,
          ),
        if (voucher.historique.isNotEmpty)
          _buildChip(
            Icons.history,
            '${voucher.historique.length} utilisation${voucher.historique.length > 1 ? 's' : ''}',
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}