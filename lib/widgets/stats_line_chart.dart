import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsLineChart extends StatelessWidget {
  final List<int> reservationData;
  final bool isPersonalized;

  const StatsLineChart({
    Key? key, 
    required this.reservationData, 
    this.isPersonalized = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcul dynamique de la hauteur maximale
    final maxY = reservationData.isNotEmpty 
      ? (reservationData.reduce((a, b) => a > b ? a : b) * 1.5).ceil().toDouble()
      : 7.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        
        titlesData: FlTitlesData(
          // Configuration des titres de l'axe X
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final labels = isPersonalized 
                  ? ['J1', 'J2', 'J3', 'J4'] 
                  : ['S1', 'S2', 'S3', 'S4'];
                
                return Text(
                  value.toInt() < labels.length 
                    ? labels[value.toInt()] 
                    : '', 
                  style: TextStyle(fontSize: 12)
                );
              },
            ),
          ),
          
          // Configuration des titres de l'axe Y
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(), 
                  style: TextStyle(fontSize: 10)
                );
              },
            ),
          ),
          
          // Masquer les titres en haut et à droite
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        
        // Configuration des données de la ligne
        lineBarsData: [
          LineChartBarData(
            // Générer les points de données
            spots: List.generate(reservationData.length, (index) {
              return FlSpot(index.toDouble(), reservationData[index].toDouble());
            }),
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true, 
              color: Colors.blue.withOpacity(0.2)
            ),
          ),
        ],
        
        // Configuration précise des axes
        minX: 0,
        maxX: 3,
        minY: 0,
        maxY: maxY,
        
        // Style général du graphique
        borderData: FlBorderData(show: false),
      ),
    );
  }
}