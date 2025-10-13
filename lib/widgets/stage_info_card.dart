import 'package:flutter/material.dart';
import '../models/stage.dart';

class StageInfoCard extends StatelessWidget {
  final Stage stage;

  StageInfoCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2a5298).withOpacity(0.1), Color(0xFF1e3c72).withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2a5298).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🪁', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  stage.nom,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2a5298),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                Icons.access_time,
                '${stage.duree}h',
              ),
              SizedBox(width: 12),
              _buildInfoChip(
                Icons.payments,
                '${stage.getPrixFinal().toStringAsFixed(0)} TND',
              ),
              SizedBox(width: 12),
              _buildInfoChip(
                Icons.show_chart,
                stage.niveauRequis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}