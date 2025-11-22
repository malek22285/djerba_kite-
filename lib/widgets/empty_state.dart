import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupère la hauteur disponible
    final availableHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calcule les tailles en fonction de l'écran
    final iconSize = (availableHeight * 0.08).clamp(40.0, 80.0);  // 8% de la hauteur, entre 40 et 80
    final titleSize = (screenWidth * 0.045).clamp(16.0, 20.0);    // 4.5% de la largeur, entre 16 et 20
    final subtitleSize = (screenWidth * 0.035).clamp(13.0, 16.0); // 3.5% de la largeur, entre 13 et 16
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(  // ← Permet scroll si vraiment trop petit
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,  // Prend au moins toute la hauteur
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: constraints.maxHeight > 200 ? 24 : 8,  // Adapte le padding vertical
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: iconSize,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: constraints.maxHeight > 200 ? 16 : 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: constraints.maxHeight > 200 ? 8 : 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}