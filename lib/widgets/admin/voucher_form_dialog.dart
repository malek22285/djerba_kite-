import 'package:flutter/material.dart';
import '../../services/firebase_stage_service.dart';
import '../../models/stage.dart';
import '../custom_text_field.dart';

class VoucherFormDialog extends StatefulWidget {
  @override
  _VoucherFormDialogState createState() => _VoucherFormDialogState();
}

class _VoucherFormDialogState extends State<VoucherFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _heuresController = TextEditingController();
  final _clientController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedStage;
  DateTime? _dateExpiration;
  List<Stage> _stages = [];
  bool _isLoadingStages = true;

  @override
  void initState() {
    super.initState();
    _loadStages();
    _generateCode();
  }

  Future<void> _loadStages() async {
    final stages = await FirebaseStageService().getAllStages();
    setState(() {
      _stages = stages;
      _isLoadingStages = false;
    });
  }

  void _generateCode() {
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    _codeController.text = 'VCH$random';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.confirmation_number, color: Colors.purple),
          SizedBox(width: 8),
          Text('Créer un voucher'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _codeController,
                      label: 'Code voucher *',
                      icon: Icons.qr_code,
                      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _generateCode,
                    tooltip: 'Générer un code',
                  ),
                ],
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _heuresController,
                label: 'Nombre d\'heures *',
                icon: Icons.access_time,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              _isLoadingStages
                  ? CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedStage,
                      decoration: InputDecoration(
                        labelText: 'Stage autorisé',
                        prefixIcon: Icon(Icons.water_drop),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      hint: Text('Tous les stages'),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Tous les stages'),
                        ),
                        ..._stages.map((stage) {
                          return DropdownMenuItem(
                            value: stage.id,
                            child: Text(stage.nom),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStage = value);
                      },
                    ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _clientController,
                label: 'Email client (optionnel)',
                icon: Icons.person,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date d\'expiration (optionnel)',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _dateExpiration == null
                        ? 'Aucune expiration'
                        : '${_dateExpiration!.day}/${_dateExpiration!.month}/${_dateExpiration!.year}',
                  ),
                ),
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _notesController,
                label: 'Notes',
                icon: Icons.notes,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'code': _codeController.text.trim(),
                'heures': int.parse(_heuresController.text),
                'stageType': _selectedStage,
                'clientAssigne': _clientController.text.trim().isEmpty
                    ? null
                    : _clientController.text.trim(),
                'dateExpiration': _dateExpiration,
                'notes': _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: Text('Créer'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dateExpiration = picked);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _heuresController.dispose();
    _clientController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}