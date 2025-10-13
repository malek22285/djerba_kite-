import 'package:flutter/material.dart';
import '../../models/stage.dart';
import '../../services/local_auth_service.dart';
import '../../services/reservation_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/date_time_picker.dart';
import '../../widgets/voucher_section.dart';
import '../../widgets/reservation_button.dart';
import '../../widgets/stage_info_card.dart';

class ReservationScreen extends StatefulWidget {
  final Stage stage;

  ReservationScreen({required this.stage});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = LocalAuthService();
  final _reservationService = ReservationService();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedNiveau = 'Débutant';
  final _phoneController = TextEditingController();
  final _voucherController = TextEditingController();
  bool _hasVoucher = false;
  bool _isLoading = false;

  final List<String> _niveaux = [
    'Débutant',
    'Quelques bases',
    'Intermédiaire',
    'Confirmé',
  ];

  @override
  void initState() {
    super.initState();
    final user = _authService.getCurrentUser();
    _phoneController.text = user?['telephone'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réserver un stage'),
        backgroundColor: Color(0xFF2a5298),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StageInfoCard(stage: widget.stage),
              SizedBox(height: 24),
              
              Text(
                'Informations de réservation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              DateTimePicker(
                label: 'Date souhaitée *',
                icon: Icons.calendar_today,
                selectedDate: _selectedDate,
                onTap: _pickDate,
                isDate: true,
              ),
              SizedBox(height: 16),
              
              DateTimePicker(
                label: 'Heure souhaitée *',
                icon: Icons.access_time,
                selectedTime: _selectedTime,
                onTap: _pickTime,
                isDate: false,
              ),
              SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedNiveau,
                decoration: InputDecoration(
                  labelText: 'Votre niveau *',
                  prefixIcon: Icon(Icons.show_chart, color: Color(0xFF2a5298)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: _niveaux.map((niveau) {
                  return DropdownMenuItem(value: niveau, child: Text(niveau));
                }).toList(),
                onChanged: (value) => setState(() => _selectedNiveau = value!),
              ),
              SizedBox(height: 16),
              
              CustomTextField(
                controller: _phoneController,
                label: 'Numéro de téléphone *',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Téléphone requis';
                  if (value.length < 8) return 'Numéro invalide';
                  return null;
                },
              ),
              SizedBox(height: 24),
              
              VoucherSection(
                hasVoucher: _hasVoucher,
                onChanged: (value) => setState(() => _hasVoucher = value!),
                controller: _voucherController,
                validator: _hasVoucher
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Code voucher requis';
                        }
                        return null;
                      }
                    : null,
              ),
              SizedBox(height: 32),
              
              ReservationButton(
                text: 'Envoyer la demande',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF2a5298)),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF2a5298)),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _handleSubmit() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une date et une heure'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser()!;
      
      await _reservationService.createReservation(
        userId: user['email'],
        userEmail: user['email'],
        userName: '${user['prenom']} ${user['nom']}',
        userPhone: _phoneController.text.trim(),
        stageId: widget.stage.id,
        stageName: widget.stage.nom,
        dateDemande: _selectedDate!,
        heureDemande: _selectedTime!.format(context),
        niveauClient: _selectedNiveau,
        prixFinal: widget.stage.getPrixFinal(),
        voucherCode: _hasVoucher ? _voucherController.text.trim() : null,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Demande envoyée'),
            ],
          ),
          content: Text(
            'Votre demande de réservation a été envoyée avec succès.\n\n'
            'Vous recevrez une notification WhatsApp dès validation par notre équipe.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF2a5298),
              ),
              child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _voucherController.dispose();
    super.dispose();
  }
}