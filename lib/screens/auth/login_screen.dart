import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/auth_container.dart';
import '../../services/local_auth_service.dart';
import '../client/client_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = LocalAuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthContainer(
      title: 'DjerbaKite',
      subtitle: 'Réservez vos stages de kitesurf',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              label: 'Email',
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
              controller: _passwordController,
              label: 'Mot de passe',
              icon: Icons.lock,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Mot de passe requis';
                if (v.length < 8) return 'Minimum 8 caractères';
                return null;
              },
            ),
            SizedBox(height: 24),
            CustomButton(
              text: 'Se connecter',
              onPressed: _handleLogin,
              isLoading: _isLoading,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen()),
              ),
              child: Text(
                'Créer un compte',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => user['role'] == 'admin'
              ? AdminHomeScreen()
              : ClientHomeScreen(),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}