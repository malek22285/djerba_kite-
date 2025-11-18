import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            Icon(Icons.cancel, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Expanded(child: Text('Refuser la demande', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: SingleChildScrollView(  // ← AJOUTÉ
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: motifController,
                label: 'Motif du refus (optionnel)',
                icon: Icons.notes,
                maxLines: 3,  // ← RÉDUIT de 4 à 3
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
              final motif = motifController.text.trim().isEmpty 
                ? 'Demande refusée par l\'administrateur' 
                : motifController.text.trim();
              
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
          Icon(Icons.check_circle, color: Colors.green, size: 24),
          SizedBox(width: 8),
          Expanded(child: Text('Accepter la demande', style: TextStyle(fontSize: 18))),
        ],
      ),
      content: SingleChildScrollView(  // ← AJOUTÉ
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirmer ${widget.demande.userName} pour:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            SizedBox(height: 12),
            _buildDatePicker(),
            SizedBox(height: 10),
            _buildTimePicker(),
            SizedBox(height: 10),
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
          prefixIcon: Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(selectedDate),
          style: TextStyle(fontSize: 14),
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
          prefixIcon: Icon(Icons.access_time, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Text(
          selectedTime.format(context),
          style: TextStyle(fontSize: 14),
        ),
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
  final remiseController = TextEditingController(text: '0');

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
          Icon(Icons.event_available, color: Colors.orange, size: 24),
          SizedBox(width: 8),
          Expanded(child: Text('Proposer un créneau', style: TextStyle(fontSize: 18))),
        ],
      ),
      content: SingleChildScrollView(  // ← AJOUTÉ
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDatePicker(),
            SizedBox(height: 10),
            _buildTimePicker(),
            SizedBox(height: 10),
            CustomTextField(
              controller: widget.motifController,
              label: 'Motif (optionnel)',
              icon: Icons.notes,
              maxLines: 2,  // ← RÉDUIT de 3 à 2
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: remiseController,
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
              'motif': widget.motifController.text.trim(),
              'remise': double.tryParse(remiseController.text) ?? 0,
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
          prefixIcon: Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(selectedDate),
          style: TextStyle(fontSize: 14),
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
          prefixIcon: Icon(Icons.access_time, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Text(
          selectedTime.format(context),
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    remiseController.dispose();
    super.dispose();
  }
}