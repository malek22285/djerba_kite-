import 'package:flutter/material.dart';
import '../../models/stage.dart';
import '../../widgets/niveau_badge.dart';
import '../../widgets/prix_display.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/info_section.dart';
import '../../widgets/bottom_action_button.dart';
import 'reservation_screen.dart';

class StageDetailScreen extends StatelessWidget {
  final Stage stage;

  StageDetailScreen({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail du stage'),
        backgroundColor: Color(0xFF2a5298),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientHeader(title: stage.nom),
            _buildContent(),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionButton(
        text: 'Réserver ce stage',
        icon: Icons.calendar_today,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReservationScreen(stage: stage),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges info
          Row(
            children: [
              NiveauBadge(niveau: stage.niveauRequis, fontSize: 14),
              SizedBox(width: 12),
              Icon(Icons.access_time, color: Colors.grey[600], size: 18),
              SizedBox(width: 4),
              Text(
                '${stage.duree}h',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Description
          InfoSection(
            title: 'Description',
            padding: EdgeInsets.all(16),
            backgroundColor: Colors.white,
            child: Text(
              stage.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24),
          
          // Prix
          InfoSection(
            title: 'Tarif',
            child: PrixDisplay(
              stage: stage,
              prixFontSize: 32,
              eurFontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}