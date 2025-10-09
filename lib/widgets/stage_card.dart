import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../screens/client/stage_detail_screen.dart';
import 'niveau_badge.dart';
import 'prix_display.dart';

class StageCard extends StatelessWidget {
  final Stage stage;

  StageCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StageDetailScreen(stage: stage),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom + Badge niveau
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stage.nom,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  NiveauBadge(niveau: stage.niveauRequis),
                ],
              ),
              SizedBox(height: 8),
              
              // Description
              Text(
                stage.description,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              
              // Durée + Prix
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        '${stage.duree}h',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  PrixDisplay(stage: stage),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}