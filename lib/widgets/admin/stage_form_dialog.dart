import 'package:flutter/material.dart';
import '../../models/stage.dart';
import '../custom_text_field.dart';

class StageFormDialog extends StatefulWidget {
  final Stage? stage; // null = création, non-null = modification

  StageFormDialog({this.stage});

  @override
  _StageFormDialogState createState() => _StageFormDialogState();
}

class _StageFormDialogState extends State<StageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _dureeController;
  late TextEditingController _prixController;
  late TextEditingController _remiseController;
  String _selectedNiveau = 'Débutant';

  final List<String> _niveaux = [
    'Débutant',
    'Intermédiaire',
    'Confirmé',
    'Tous niveaux',
  ];

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.stage?.nom ?? '');
    _descriptionController = TextEditingController(text: widget.stage?.description ?? '');
    _dureeController = TextEditingController(text: widget.stage?.duree.toString() ?? '');
    _prixController = TextEditingController(text: widget.stage?.prixTnd.toString() ?? '');
    _remiseController = TextEditingController(text: widget.stage?.remisePourcentage.toString() ?? '0');
    _selectedNiveau = widget.stage?.niveauRequis ?? 'Débutant';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.stage != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(isEdit ? Icons.edit : Icons.add_circle, color: Color(0xFF2a5298)),
          SizedBox(width: 8),
          Text(isEdit ? 'Modifier le stage' : 'Nouveau stage'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nomController,
                label: 'Nom du stage *',
                icon: Icons.title,
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description *',
                icon: Icons.description,
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _dureeController,
                      label: 'Durée (heures) *',
                      icon: Icons.access_time,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (int.tryParse(v) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      controller: _prixController,
                      label: 'Prix (TND) *',
                      icon: Icons.payments,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (double.tryParse(v) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedNiveau,
                decoration: InputDecoration(
                  labelText: 'Niveau requis *',
                  prefixIcon: Icon(Icons.show_chart),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _niveaux.map((niveau) {
                  return DropdownMenuItem(value: niveau, child: Text(niveau));
                }).toList(),
                onChanged: (value) => setState(() => _selectedNiveau = value!),
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _remiseController,
                label: 'Remise globale (%)',
                icon: Icons.discount,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final val = double.tryParse(v);
                    if (val == null || val < 0 || val > 100) {
                      return 'Entre 0 et 100';
                    }
                  }
                  return null;
                },
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
                'nom': _nomController.text.trim(),
                'description': _descriptionController.text.trim(),
                'duree': int.parse(_dureeController.text),
                'prix': double.parse(_prixController.text),
                'niveau': _selectedNiveau,
                'remise': double.tryParse(_remiseController.text) ?? 0,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2a5298),
            foregroundColor: Colors.white,
          ),
          child: Text(isEdit ? 'Modifier' : 'Créer'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _dureeController.dispose();
    _prixController.dispose();
    _remiseController.dispose();
    super.dispose();
  }
}