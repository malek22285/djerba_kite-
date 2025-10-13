import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/auth_container.dart';
import '../../services/local_auth_service.dart';
import 'login_screen.dart';

// Classe pour définir un champ du formulaire
class _FormFieldConfig {
  final String key;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  _FormFieldConfig({
    required this.key,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = LocalAuthService();
  final _controllers = <String, TextEditingController>{};
  bool _isLoading = false;

  // Configuration des champs du formulaire
  final _fields = [
    _FormFieldConfig(
      key: 'nom',
      label: 'Nom',
      icon: Icons.person_outline,
    ),
    _FormFieldConfig(
      key: 'prenom',
      label: 'Prénom',
      icon: Icons.person,
    ),
    _FormFieldConfig(
      key: 'email',
      label: 'Email',
      icon: Icons.email,
      keyboardType: TextInputType.emailAddress,
    ),
    _FormFieldConfig(
      key: 'telephone',
      label: 'Téléphone',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
    ),
    _FormFieldConfig(
      key: 'password',
      label: 'Mot de passe',
      icon: Icons.lock,
      obscureText: true,
    ),
    _FormFieldConfig(
      key: 'confirmPassword',
      label: 'Confirmer mot de passe',
      icon: Icons.lock_outline,
      obscureText: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser les controllers
    for (var field in _fields) {
      _controllers[field.key] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthContainer(
      title: 'Créer un compte',
      subtitle: 'Rejoignez DjerbaKite',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ..._buildFields(),
            SizedBox(height: 24),
            CustomButton(
              text: 'Créer mon compte',
              onPressed: _handleRegister,
              isLoading: _isLoading,
            ),
            SizedBox(height: 16),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFields() {
    return _fields
        .map((field) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: CustomTextField(
                controller: _controllers[field.key]!,
                label: '${field.label} *',
                icon: field.icon,
                keyboardType: field.keyboardType,
                obscureText: field.obscureText,
                validator: (v) => _validate(field.key, v),
              ),
            ))
        .toList();
  }

  String? _validate(String key, String? value) {
    if (value == null || value.isEmpty) {
      final label = _fields.firstWhere((f) => f.key == key).label;
      return '$label requis';
    }

    switch (key) {
      case 'email':
        return !value.contains('@') ? 'Email invalide' : null;
      case 'telephone':
        return value.length < 8 ? 'Numéro invalide (min 8 chiffres)' : null;
      case 'password':
        return value.length < 8 ? 'Minimum 8 caractères' : null;
      case 'confirmPassword':
        return value != _controllers['password']!.text
            ? 'Les mots de passe ne correspondent pas'
            : null;
      default:
        return null;
    }
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      ),
      child: Text(
        'Déjà un compte ? Se connecter',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _controllers['email']!.text.trim(),
        password: _controllers['password']!.text,
        nom: _controllers['nom']!.text.trim(),
        prenom: _controllers['prenom']!.text.trim(),
        telephone: _controllers['telephone']!.text.trim(),
      );

      if (!mounted) return;
      _showSuccessDialog();
      
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Compte créé !'),
          ],
        ),
        content: Text(
          'Votre compte a été créé avec succès.\n\n'
          'Vous pouvez maintenant vous connecter et réserver vos stages de kitesurf.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2a5298),
              foregroundColor: Colors.white,
            ),
            child: Text('Me connecter'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }
}