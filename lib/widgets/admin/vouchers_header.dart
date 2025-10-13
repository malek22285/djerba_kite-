import 'package:flutter/material.dart';

class VouchersHeader extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final int totalCount;

  VouchersHeader({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.totalCount,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Vouchers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalCount',
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tous', 'tous'),
                SizedBox(width: 8),
                _buildFilterChip('Actifs', 'actif'),
                SizedBox(width: 8),
                _buildFilterChip('Utilisés', 'utilise'),
                SizedBox(width: 8),
                _buildFilterChip('Expirés', 'expire'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(value),
      selectedColor: Colors.purple.withOpacity(0.2),
      checkmarkColor: Colors.purple,
    );
  }
}