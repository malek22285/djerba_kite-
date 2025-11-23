import 'package:flutter/material.dart';

class StageRepartitionCard extends StatelessWidget {
  final Map<String, int> repartition;

  const StageRepartitionCard({Key? key, required this.repartition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (repartition.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Aucune donnée',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final total = repartition.values.reduce((a, b) => a + b);
    final sortedEntries = repartition.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,  // ← AJOUTÉ: CRITIQUE!
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,  // ← AJOUTÉ
              children: [
                Icon(Icons.pie_chart, color: Color(0xFF2a5298), size: 20),
                SizedBox(width: 8),
                Text(
                  'Répartition par stage',
                  style: TextStyle(
                    fontSize: 16,  // ← Réduit de 18 à 16
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),  // ← Réduit de 20 à 16
            ...sortedEntries.map((entry) {
              final percentage = (entry.value / total * 100).toStringAsFixed(1);
              return Padding(
                padding: EdgeInsets.only(bottom: 12),  // ← Réduit de 16 à 12
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // ← AJOUTÉ
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,  // ← Réduit de 14 à 13
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),  // ← AJOUTÉ: Espace entre nom et pourcentage
                        Text(
                          '${entry.value} ($percentage%)',
                          style: TextStyle(
                            fontSize: 13,  // ← Réduit de 14 à 13
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2a5298),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),  // ← Réduit de 8 à 6
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value / total,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2a5298),
                        ),
                        minHeight: 6,  // ← Réduit de 8 à 6
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}