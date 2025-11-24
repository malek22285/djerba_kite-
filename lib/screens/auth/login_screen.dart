import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/auth_container.dart';
//import '../../services/local_auth_service.dart';
import '../../services/firebase_auth_service.dart';
import '../client/client_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'register_screen.dart';
import '../../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //final _authService = LocalAuthService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // On met title et subtitle à vide car on va les afficher DANS le child.
    return AuthContainer(
      title: '', // <--- Mis à vide
      subtitle: '', // <--- Mis à vide
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 1. LE LOGO
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2a5298).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF2a5298).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: AppLogo(height: 100),
            ),
            
            // Espace pour séparer le logo du texte
            SizedBox(height: 24), 

            // 2. LE TITRE "DjerbaKite"
            Text(
              'DjerbaKite',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),

            // 3. LE SOUS-TITRE "Réservez vos stages de kitesurf"
            Text(
              'Réservez vos stages de kitesurf',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Espace pour séparer le sous-titre du formulaire
            SizedBox(height: 32), 
            
            // Formulaire (Email, Mot de passe, etc.)
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

    print('🔵 Début connexion...');
    print('📧 Email: ${_emailController.text.trim()}');

    try {
      print('🔵 Appel signIn()...');
      
      final user = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('✅ signIn() réussi!');
      print('👤 User data: $user');
      print('🎭 Role: ${user['role']}');

      if (!mounted) return;

      print('🔵 Navigation vers écran ${user['role']}...');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => user['role'] == 'admin'
              ? AdminHomeScreen()
              : ClientHomeScreen(),
        ),
      );

      print('✅ Navigation réussie!');

    } catch (e, stackTrace) {
      print('❌ ERREUR ATTRAPÉE:');
      print('Type: ${e.runtimeType}');
      print('Message: $e');
      print('Stack trace:');
      print(stackTrace);

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