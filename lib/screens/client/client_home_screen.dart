import 'package:flutter/material.dart';
import '../../services/local_auth_service.dart';
import '../../services/stage_service.dart';
import '../../models/stage.dart';
import '../../widgets/stage_card.dart';
import '../auth/login_screen.dart';
import 'my_reservations_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final _authService = LocalAuthService();
  final _stageService = StageService();
  
  List<Stage> _stages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStages();
  }

  Future<void> _loadStages() async {
    setState(() => _isLoading = true);
    
    try {
      final stages = await _stageService.getAllStages();
      setState(() {
        _stages = stages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DjerbaKite'),
        backgroundColor: Color(0xFF2a5298),
        actions: [
  IconButton(
    icon: Icon(Icons.history),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MyReservationsScreen()),
      );
    },
  ),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStages,
              child: _stages.isEmpty
                  ? Center(child: Text('Aucun stage disponible'))
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _stages.length,
                      itemBuilder: (context, index) {
                        return StageCard(stage: _stages[index]);
                      },
                    ),
            ),
    );
  }
}