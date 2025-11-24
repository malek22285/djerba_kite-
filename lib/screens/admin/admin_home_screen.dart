import 'package:flutter/material.dart';
import '../../services/local_auth_service.dart';
import '../../services/currency_service.dart'; 
import '../auth/login_screen.dart';
import 'tabs/demandes_tab.dart';
import 'tabs/propositions_tab.dart';
import 'tabs/stages_tab.dart';
import 'tabs/vouchers_tab.dart';
import 'tabs/stats_tab.dart';
import 'tabs/settings_tab.dart';
import 'planning_screen.dart'; 
import '../../widgets/app_logo.dart';
class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _authService = LocalAuthService();
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    DemandesTab(),
    PropositionsTab(),
    PlanningScreen(),
    StagesTab(),
    VouchersTab(),
    StatsTab(),
    SettingsTab(),

  ];

  @override
  void initState() {
    super.initState();
    
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: AppLogo(height: 40),
  backgroundColor: Color(0xFF2a5298),
  centerTitle: false,
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
            icon: Icon(Icons.schedule_send),
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
              BottomNavigationBarItem(  // ← NOUVEAU
              icon: Icon(Icons.settings),
             label: 'Paramètres',
        ),
        ],
      ),
    );
  }
}