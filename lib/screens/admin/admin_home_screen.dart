import 'package:flutter/material.dart';
import '../../services/local_auth_service.dart';
import '../auth/login_screen.dart';
import 'tabs/demandes_tab.dart';
import 'tabs/propositions_tab.dart';
import 'tabs/planning_tab.dart';
import 'tabs/stages_tab.dart';
import 'tabs/vouchers_tab.dart';
import 'tabs/stats_tab.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _authService = LocalAuthService();
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    DemandesTab(),
    PropositionsTab(),  // ← AJOUTÉ
    PlanningTab(),
    StagesTab(),
    VouchersTab(),
    StatsTab(),
  ];

  @override
  Widget build(BuildContext context) {
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
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2a5298),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Demandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_send),  // ← AJOUTÉ
            label: 'Propositions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Stages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Vouchers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}