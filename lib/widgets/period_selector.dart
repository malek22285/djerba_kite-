import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PeriodType {
  thisWeek,
  thisMonth,
  custom
}

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
    // ← CHANGÉ: Appel APRÈS le build initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePeriod(_selectedPeriod);
    });
  }

  void _updatePeriod(PeriodType period, {DateTime? start, DateTime? end}) {
    if (!mounted) return;
    
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

    if (picked != null && mounted) {
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton(PeriodType.thisMonth, 'Ce mois'),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildPeriodButton(PeriodType.thisWeek, 'Cette semaine'),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.calendar_today, size: 20),
            onPressed: _showDateRangePicker,
            tooltip: 'Période personnalisée',
            padding: EdgeInsets.all(8),
            constraints: BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(PeriodType type, String label) {
    bool isSelected = _selectedPeriod == type;
    return Material(
      color: isSelected ? Colors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          setState(() {
            _selectedPeriod = type;
          });
          _updatePeriod(type);
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.blue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}