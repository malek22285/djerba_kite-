import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/stage.dart';
import '../../services/firebase_reservation_service.dart';

class CreatePassagerDialog extends StatefulWidget {
  final List<Stage> stages;

  const CreatePassagerDialog({Key? key, required this.stages}) : super(key: key);

  @override
  _CreatePassagerDialogState createState() => _CreatePassagerDialogState();
}

class _CreatePassagerDialogState extends State<CreatePassagerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _phoneController = TextEditingController();

  Stage? _selectedStage;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _paiementEffectue = true;
  String _selectedNiveau = 'Débutant';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Réservation sur place',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nom obligatoire';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Téléphone obligatoire';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Stage>(
                  isExpanded: true,
                  value: _selectedStage,
                  decoration: InputDecoration(
                    labelText: 'Stage',
                    prefixIcon: Icon(Icons.surfing),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  items: widget.stages.map((stage) {
                    return DropdownMenuItem(
                      value: stage,
                      child: Text(
                        '${stage.nom} (${stage.duree}h)', 
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  validator: (value) => 
                    value == null ? 'Sélectionnez un stage' : null,
                  onChanged: (stage) {
                    setState(() {
                      _selectedStage = stage;
                    });
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: _selectedDate == DateTime.now() 
                            ? TextStyle(color: Colors.red) 
                            : null,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _selectedTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                          style: _selectedTime == TimeOfDay.now() 
                            ? TextStyle(color: Colors.red) 
                            : null,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                CheckboxListTile(
                  value: _paiementEffectue,
                  onChanged: (val) => setState(() => _paiementEffectue = val!),
                  title: Text('Paiement effectué'),
                  subtitle: Text(
                    _paiementEffectue 
                      ? 'Confirmera la réservation directement' 
                      : 'Restera en attente de confirmation',
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Annuler'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _createReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _paiementEffectue ? Colors.green : Colors.orange,
                        ),
                        child: Text(
                          _paiementEffectue ? 'Confirmer' : 'Créer demande'
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate() || 
        _selectedStage == null || 
        _selectedDate == DateTime.now() || 
        _selectedTime == TimeOfDay.now()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une date et une heure'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final service = FirebaseReservationService();
      
      await service.createPassagerReservation(
        userName: _nomController.text.trim(),
        userPhone: _phoneController.text.trim(),
        stageId: _selectedStage!.id,
        stageName: _selectedStage!.nom,
        stageDuree: _selectedStage!.duree,
        dateDemande: _selectedDate,
        heureDemande: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        niveauClient: _selectedNiveau,
        prixFinal: _selectedStage!.prixTnd ?? 0,
        confirmerDirectement: _paiementEffectue,
      );

      if (!mounted) return;
      
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _paiementEffectue 
              ? '✓ Réservation confirmée' 
              : '✓ Demande créée (en attente)',
          ),
          backgroundColor: _paiementEffectue ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}