import 'package:flutter/material.dart';
import '../../models/stage.dart';
import '../../widgets/niveau_badge.dart';
import '../../widgets/prix_display.dart';
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
            _buildHeader(),
            _buildContent(),
          ],
        ),
      ),
      bottomNavigationBar: _buildReserverButton(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2a5298), Color(0xFF1e3c72)],
        ),
      ),
      child: Column(
        children: [
          Text('🪁', style: TextStyle(fontSize: 80)),
          SizedBox(height: 16),
          Text(
            stage.nom,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NiveauBadge(niveau: stage.niveauRequis, fontSize: 14),
              SizedBox(width: 12),
              Icon(Icons.access_time, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                '${stage.duree} heure${stage.duree > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            stage.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),
          
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarif',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                PrixDisplay(
                  stage: stage,
                  prixFontSize: 32,
                  eurFontSize: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 
Widget _buildReserverButton(BuildContext context) {
  return SafeArea(
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReservationScreen(stage: stage),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2a5298),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Réserver ce stage',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
}