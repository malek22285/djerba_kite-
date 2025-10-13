import 'package:flutter/material.dart';

class StagesHeader extends StatelessWidget {
  final bool showInactive;
  final ValueChanged<bool> onToggle;

  StagesHeader({
    required this.showInactive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Gestion des stages',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          FilterChip(
            label: Text('Afficher inactifs'),
            selected: showInactive,
            onSelected: onToggle,
            selectedColor: Color(0xFF2a5298).withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}