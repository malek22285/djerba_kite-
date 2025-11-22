import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodSelector extends StatefulWidget {
  final Function(DateTime start, DateTime end, {bool isCustom}) onPeriodChanged;

  const PeriodSelector({Key? key, required this.onPeriodChanged}) : super(key: key);

  @override
  _PeriodSelectorState createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  PeriodType _selectedPeriod = PeriodType.thisMonth;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    // Déclencher la période par défaut
    _updatePeriod(_selectedPeriod);
  }

  void _updatePeriod(PeriodType period, {DateTime? start, DateTime? end}) {
    DateTime now = DateTime.now();
    DateTime startDate, endDate;

    switch (period) {
      case PeriodType.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(Duration(days: 6));
        break;
      case PeriodType.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case PeriodType.custom:
        startDate = start ?? _customStartDate ?? now;
        endDate = end ?? _customEndDate ?? now;
        break;
    }

    widget.onPeriodChanged(
      startDate, 
      endDate, 
      isCustom: period == PeriodType.custom
    );
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
        ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
        : null,
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = PeriodType.custom;
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });

      _updatePeriod(
        PeriodType.custom, 
        start: picked.start, 
        end: picked.end
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Onglets prédéfinis
        Expanded(
          child: Row(
            children: [
              _buildPeriodButton(PeriodType.thisMonth, 'Ce mois'),
              _buildPeriodButton(PeriodType.thisWeek, 'Cette semaine'),
            ],
          ),
        ),
        
        // Bouton période personnalisée
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: _showDateRangePicker,
          tooltip: 'Période personnalisée',
        ),
      ],
    );
  }

  Widget _buildPeriodButton(PeriodType type, String label) {
    bool isSelected = _selectedPeriod == type;
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedPeriod = type;
          });
          _updatePeriod(type);
        },
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.blue,
        ),
        child: Text(label),
      ),
    );
  }
}

enum PeriodType {
  thisWeek,
  thisMonth,
  custom
}