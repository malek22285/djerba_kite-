import 'package:flutter/material.dart';
import '../../services/local_auth_service.dart';
import '../auth/login_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  final _authService = LocalAuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('DjerbaKite'),
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
            Text('🪁', style: TextStyle(fontSize: 60)),
            SizedBox(height: 20),
            Text(
              'Bienvenue ${user?['prenom']}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Interface Client',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 40),
            Text('TODO: Liste des stages', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}