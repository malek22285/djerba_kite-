import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import '../custom_text_field.dart';

class AdminActionDialogs {
  // Dialog pour ACCEPTER
  static Future<Map<String, dynamic>?> showAcceptDialog(
    BuildContext context,
    Reservation demande,
  ) async {
    DateTime selectedDate = demande.dateDemande;
    TimeOfDay selectedTime = _parseTime(demande.heureDemande);
    final remiseController = TextEditingController(text: '0');

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AcceptDialog(
        demande: demande,
        initialDate: selectedDate,
        initialTime: selectedTime,
        remiseController: remiseController,
      ),
    );
  }

  // Dialog pour PROPOSER autre créneau
  static Future<Map<String, dynamic>?> showProposeDialog(
    BuildContext context,
    Reservation demande,
  ) async {
    DateTime selectedDate = demande.dateDemande;
    TimeOfDay selectedTime = _parseTime(demande.heureDemande);
    final motifController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ProposeDialog(
        demande: demande,
        initialDate: selectedDate,
        initialTime: selectedTime,
        motifController: motifController,
      ),
    );
  }

  // Dialog pour REFUSER
  static Future<String?> showRejectDialog(BuildContext context) async {
    final motifController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Refuser la demande'),
          ],
        ),
        content: CustomTextField(
          controller: motifController,
          label: 'Motif du refus',
          icon: Icons.notes,
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final motif = motifController.text.trim();
              if (motif.isEmpty) {
                return;
              }
              Navigator.pop(context, motif);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Refuser'),
          ),
        ],
      ),
    );
  }

  static TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return TimeOfDay(hour: 9, minute: 0);
    }
  }
}

// Widget séparé pour Accept Dialog avec State
class _AcceptDialog extends StatefulWidget {
  final Reservation demande;
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final TextEditingController remiseController;

  _AcceptDialog({
    required this.demande,
    required this.initialDate,
    required this.initialTime,
    required this.remiseController,
  });

  @override
  _AcceptDialogState createState() => _AcceptDialogState();
}

class _AcceptDialogState extends State<_AcceptDialog> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Accepter la demande'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirmer ${widget.demande.userName} pour:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            _buildDatePicker(),
            SizedBox(height: 12),
            _buildTimePicker(),
            SizedBox(height: 12),
            CustomTextField(
              controller: widget.remiseController,
              label: 'Remise (TND)',
              icon: Icons.discount,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'date': selectedDate,
              'time': selectedTime,
              'remise': double.tryParse(widget.remiseController.text) ?? 0,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Confirmer'),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 90)),
        );
        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date finale',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (picked != null) {
          setState(() => selectedTime = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Heure finale',
          prefixIcon: Icon(Icons.access_time),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(selectedTime.format(context)),
      ),
    );
  }
}

// Widget séparé pour Propose Dialog avec State
class _ProposeDialog extends StatefulWidget {
  final Reservation demande;
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final TextEditingController motifController;

  _ProposeDialog({
    required this.demande,
    required this.initialDate,
    required this.initialTime,
    required this.motifController,
  });

  @override
  _ProposeDialogState createState() => _ProposeDialogState();
}

class _ProposeDialogState extends State<_ProposeDialog> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.schedule, color: Colors.orange),
          SizedBox(width: 8),
          Text('Proposer un créneau'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDatePicker(),
            SizedBox(height: 12),
            _buildTimePicker(),
            SizedBox(height: 12),
            CustomTextField(
              controller: widget.motifController,
              label: 'Motif (optionnel)',
              icon: Icons.notes,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'date': selectedDate,
              'time': selectedTime,
              'motif': widget.motifController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: Text('Envoyer'),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 90)),
        );
        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Nouvelle date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (picked != null) {
          setState(() => selectedTime = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Nouvelle heure',
          prefixIcon: Icon(Icons.access_time),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(selectedTime.format(context)),
      ),
    );
  }
}