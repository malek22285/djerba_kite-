import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/stage.dart';
import '../../services/local_auth_service.dart';
import '../../services/reservation_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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
    // Pré-remplir le téléphone avec celui du profil
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
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStageInfo(),
              SizedBox(height: 32),
              _buildDatePicker(),
              SizedBox(height: 16),
              _buildTimePicker(),
              SizedBox(height: 16),
              _buildNiveauDropdown(),
              SizedBox(height: 16),
              _buildPhoneField(),
              SizedBox(height: 24),
              _buildVoucherSection(),
              SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.stage.nom,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2a5298),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text('${widget.stage.duree}h'),
              SizedBox(width: 16),
              Icon(Icons.payments, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text('${widget.stage.getPrixFinal().toStringAsFixed(0)} TND'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date souhaitée *',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _selectedDate == null
              ? 'Sélectionner une date'
              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
          style: TextStyle(
            color: _selectedDate == null ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _pickTime,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Heure souhaitée *',
          prefixIcon: Icon(Icons.access_time),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _selectedTime == null
              ? 'Sélectionner une heure'
              : _selectedTime!.format(context),
          style: TextStyle(
            color: _selectedTime == null ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildNiveauDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedNiveau,
      decoration: InputDecoration(
        labelText: 'Votre niveau *',
        prefixIcon: Icon(Icons.show_chart),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _niveaux.map((niveau) {
        return DropdownMenuItem(
          value: niveau,
          child: Text(niveau),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedNiveau = value!);
      },
    );
  }

  Widget _buildPhoneField() {
    return CustomTextField(
      controller: _phoneController,
      label: 'Numéro de téléphone *',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Téléphone requis';
        }
        if (value.length < 8) {
          return 'Numéro invalide';
        }
        return null;
      },
    );
  }

  Widget _buildVoucherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _hasVoucher,
              onChanged: (value) {
                setState(() => _hasVoucher = value!);
              },
            ),
            Text('J\'ai un voucher'),
          ],
        ),
        if (_hasVoucher) ...[
          SizedBox(height: 8),
          CustomTextField(
            controller: _voucherController,
            label: 'Code voucher',
            icon: Icons.confirmation_number,
            validator: _hasVoucher
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Code voucher requis';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: 'Envoyer la demande',
      onPressed: _handleSubmit,
      isLoading: _isLoading,
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
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
    
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _handleSubmit() async {
    // Validation des champs obligatoires
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une heure'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser()!;
      
      final reservation = await _reservationService.createReservation(
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

      // Succès
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('✓ Demande envoyée'),
          content: Text(
            'Votre demande de réservation a été envoyée avec succès.\n\n'
            'Vous recevrez une notification WhatsApp dès validation par notre équipe.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme dialog
                Navigator.of(context).pop(); // Retour à la liste des stages
              },
              child: Text('OK'),
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