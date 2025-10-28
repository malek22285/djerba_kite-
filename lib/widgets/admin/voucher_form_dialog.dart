import 'package:flutter/material.dart';
import '../custom_text_field.dart';

class VoucherFormDialog extends StatefulWidget {
  @override
  _VoucherFormDialogState createState() => _VoucherFormDialogState();
}

class _VoucherFormDialogState extends State<VoucherFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _heuresController = TextEditingController();
  
  DateTime _dateExpiration = DateTime.now().add(Duration(days: 365)); // 1 an par défaut

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  void _generateCode() {
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    _codeController.text = 'KITE$random';
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
              // Code voucher
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _codeController,
                      label: 'Code voucher *',
                      icon: Icons.qr_code,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Code requis';
                        if (v.length < 4) return 'Min 4 caractères';
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.purple),
                    onPressed: _generateCode,
                    tooltip: 'Générer un nouveau code',
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Nombre d'heures
              CustomTextField(
                controller: _heuresController,
                label: 'Nombre d\'heures *',
                icon: Icons.access_time,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Heures requises';
                  final heures = int.tryParse(v);
                  if (heures == null || heures <= 0) {
                    return 'Nombre invalide (min: 1)';
                  }
                  if (heures > 100) {
                    return 'Maximum 100 heures';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              // Date d'expiration
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date d\'expiration *',
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.purple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_dateExpiration.day}/${_dateExpiration.month}/${_dateExpiration.year}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.purple),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Le client pourra utiliser ce voucher lors de ses réservations.',
                        style: TextStyle(fontSize: 12, color: Colors.purple[900]),
                      ),
                    ),
                  ],
                ),
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
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text('Créer le voucher'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier que la date d'expiration est dans le futur
    if (_dateExpiration.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La date d\'expiration doit être dans le futur'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('🔵 FORM: Code = ${_codeController.text.trim()}');
    print('🔵 FORM: Heures = ${_heuresController.text.trim()}');
    print('🔵 FORM: Date expiration = $_dateExpiration');
    print('🔵 FORM: Date expiration type = ${_dateExpiration.runtimeType}');

    Navigator.pop(context, {
      'code': _codeController.text.trim().toUpperCase(),
      'heures': int.parse(_heuresController.text.trim()),
      'dateExpiration': _dateExpiration,
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateExpiration,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 1825)), // 5 ans max
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _dateExpiration = picked);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _heuresController.dispose();
    super.dispose();
  }
}