import 'package:flutter/material.dart';

class ReservationStatusBadge extends StatelessWidget {
  final String statut;
  final double fontSize;

  ReservationStatusBadge({
    required this.statut,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.8,
        vertical: fontSize * 0.4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(statut),
        borderRadius: BorderRadius.circular(fontSize),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(statut),
            size: fontSize * 1.2,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            _getStatusText(statut),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'en_attente':
        return Colors.orange;
      case 'confirmee':
        return Colors.green;
      case 'refusee':
        return Colors.red;
      case 'proposition_envoyee':
        return Colors.blue;  
      case 'annulee':
        return Colors.grey;
      case 'terminee':  
      return Colors.teal;  
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String statut) {
    switch (statut) {
      case 'en_attente':
        return Icons.schedule;
      case 'confirmee':
        return Icons.check_circle;
      case 'refusee':
        return Icons.cancel;
      case 'proposition_envoyee':
        return Icons.schedule_send;
      case 'annulee':
        return Icons.block;
      case 'terminee':  
      return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String statut) {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'confirmee':
        return 'Confirmée';
      case 'refusee':
        return 'Refusée';
      case 'annulee':
        return 'Annulée';
      case 'proposition_envoyee':
        return 'Proposition';
      case 'terminee': 
      return 'Terminée';
      default:
        return 'Inconnu';
    }
  }
}