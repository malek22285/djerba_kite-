import 'package:flutter/material.dart';
import '../../models/stage.dart';
import '../../services/firebase_stage_service.dart';

class AdminStageCard extends StatelessWidget {
  final Stage stage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  AdminStageCard({
    required this.stage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final prixEur = stage.getPrixEur(StageService.tauxChangeEur);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: stage.actif ? Colors.white : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.nom,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: stage.actif ? Colors.black : Colors.grey[600],
                        ),
                      ),
                      if (!stage.actif)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'INACTIF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFF2a5298)),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(
                    stage.actif ? Icons.delete : Icons.restore,
                    color: stage.actif ? Colors.red : Colors.green,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              stage.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildChip(Icons.access_time, '${stage.duree}h'),
                _buildChip(
                  Icons.payments,
                  '${stage.prixTnd.toStringAsFixed(0)} TND (≈${prixEur.toStringAsFixed(0)} EUR)',
                ),
                _buildChip(Icons.show_chart, stage.niveauRequis),
                if (stage.remisePourcentage > 0)
                  _buildChip(
                    Icons.discount,
                    '-${stage.remisePourcentage.toStringAsFixed(0)}%',
                    color: Colors.red,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text, {Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color?.withOpacity(0.3) ?? Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}