import 'package:flutter/material.dart';
import '../../services/local_auth_service.dart';
import '../auth/login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final _authService = LocalAuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin DjerbaKite'),
        backgroundColor: Color(0xFF2a5298),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('👨‍💼', style: TextStyle(fontSize: 60)),
            SizedBox(height: 20),
            Text(
              'Bienvenue Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Text('TODO: Onglets Admin', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}