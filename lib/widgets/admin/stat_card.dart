import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // ← IMPORTANT
          mainAxisSize: MainAxisSize.min,  // ← AJOUTÉ: Ajuste automatiquement
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Spacer(),  // ← Pousse le texte vers le bas
            Text(
              value,
              style: TextStyle(
                fontSize: 28,  // ← Réduit de 32 à 28
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,  // ← AJOUTÉ: Force sur 1 ligne
              overflow: TextOverflow.ellipsis,  // ← AJOUTÉ: Coupe si trop long
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,  // ← Réduit de 14 à 12
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,  // ← AJOUTÉ: Max 2 lignes
              overflow: TextOverflow.ellipsis,  // ← AJOUTÉ
            ),
          ],
        ),
      ),
    );
  }
}