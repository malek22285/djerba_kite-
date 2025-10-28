import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/voucher.dart';

class VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  VoucherCard({
    required this.voucher,
    required this.onTap,
    required this.onEdit,
    this.onToggle,
    this.onDelete,
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
              if (onToggle != null || onDelete != null) ...[
                SizedBox(height: 12),
                _buildActions(),
              ],
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

    if (!voucher.actif) {
      color = Colors.grey;
      icon = Icons.block;
      text = 'Inactif';
    } else if (voucher.isExpired) {
      color = Colors.red;
      icon = Icons.cancel;
      text = 'Expiré';
    } else if (voucher.isExhausted) {
      color = Colors.orange;
      icon = Icons.warning;
      text = 'Épuisé';
    } else {
      color = Colors.green;
      icon = Icons.check_circle;
      text = 'Actif';
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
    final progress = voucher.heuresTotales > 0
        ? voucher.heuresRestantes / voucher.heuresTotales
        : 0.0;

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
              '${voucher.heuresRestantes}h / ${voucher.heuresTotales}h',
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
            value: progress,
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
        _buildChip(
          Icons.calendar_today,
          'Exp: ${DateFormat('dd/MM/yyyy').format(voucher.dateExpiration)}',
          voucher.isExpired ? Colors.red : Colors.grey,
        ),
        _buildChip(
          Icons.access_time,
          'Créé: ${DateFormat('dd/MM/yyyy').format(voucher.createdAt)}',
          Colors.blue,
        ),
        if (voucher.heuresRestantes != voucher.heuresTotales)
          _buildChip(
            Icons.history,
            '${voucher.heuresTotales - voucher.heuresRestantes}h utilisées',
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

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onToggle != null)
          TextButton.icon(
            onPressed: onToggle,
            icon: Icon(
              voucher.actif ? Icons.toggle_on : Icons.toggle_off,
              size: 20,
            ),
            label: Text(voucher.actif ? 'Désactiver' : 'Activer'),
            style: TextButton.styleFrom(
              foregroundColor: voucher.actif ? Colors.orange : Colors.green,
            ),
          ),
        if (onDelete != null) ...[
          SizedBox(width: 8),
          TextButton.icon(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 20),
            label: Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ],
    );
  }
}