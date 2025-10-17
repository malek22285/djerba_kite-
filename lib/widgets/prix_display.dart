import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../services/firebase_stage_service.dart';

class PrixDisplay extends StatelessWidget {
  final Stage stage;
  final double prixFontSize;
  final double eurFontSize;
  final bool showRemiseBadge;

  PrixDisplay({
    required this.stage,
    this.prixFontSize = 20,
    this.eurFontSize = 12,
    this.showRemiseBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final prixFinal = stage.getPrixFinal();
    final prixEur = stage.getPrixEur(StageService.tauxChangeEur);
    final hasRemise = stage.remisePourcentage > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Prix barré si remise
        if (hasRemise) ...[
          Text(
            '${stage.prixTnd.toStringAsFixed(0)} TND',
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
              fontSize: prixFontSize * 0.6,
            ),
          ),
          SizedBox(height: 2),
        ],
        
        // Prix final + badge remise
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasRemise && showRemiseBadge) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '-${stage.remisePourcentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: prixFontSize * 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
            ],
            Text(
              '${prixFinal.toStringAsFixed(0)} TND',
              style: TextStyle(
                fontSize: prixFontSize,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2a5298),
              ),
            ),
          ],
        ),
        
        // Prix EUR
        Text(
          '≈ ${prixEur.toStringAsFixed(0)} EUR',
          style: TextStyle(
            fontSize: eurFontSize,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}