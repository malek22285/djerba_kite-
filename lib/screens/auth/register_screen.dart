import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/auth_container.dart';
import '../../services/firebase_auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = FirebaseAuthService();
  
  // Controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthContainer(
      title: 'Créer un compte',
      subtitle: 'Rejoignez DjerbaKite',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _nomController,
              label: 'Nom *',
              icon: Icons.person_outline,
              validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _prenomController,
              label: 'Prénom *',
              icon: Icons.person,
              validator: (v) => v == null || v.isEmpty ? 'Prénom requis' : null,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              label: 'Email *',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email requis';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              },
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _telephoneController,
              label: 'Téléphone *',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Téléphone requis';
                if (v.length < 8) return 'Numéro invalide (min 8 chiffres)';
                return null;
              },
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              label: 'Mot de passe *',
              icon: Icons.lock,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Mot de passe requis';
                if (v.length < 8) return 'Minimum 8 caractères';
                return null;
              },
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirmer mot de passe *',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirmation requise';
                if (v != _passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            CustomButton(
              text: 'Créer mon compte',
              onPressed: _handleRegister,
              isLoading: _isLoading,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              ),
              child: Text(
                'Déjà un compte ? Se connecter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telephoneController.text.trim(),
      );

      if (!mounted) return;

      // Afficher dialog succès
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

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}