import 'package:flutter/material.dart';
import '../../services/local_auth_service.dart';
//import '../../services/stage_service.dart';
import '../../services/firebase_stage_service.dart';
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
  final _stageService = FirebaseStageService();
  
  List<Stage> _stages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStages();
  }

 Future<void> _loadStages() async {
  print('🔵 CLIENT: Début chargement stages...');
  setState(() => _isLoading = true);
  
  try {
    print('🔵 CLIENT: Appel getAllStages()...');
    final stages = await _stageService.getAllStages();
    print('✅ CLIENT: Stages récupérés: ${stages.length}');
    
    for (var stage in stages) {
      print('  - ${stage.nom} (actif: ${stage.actif})');
    }
    
    setState(() {
      _stages = stages;
      _isLoading = false;
    });
    print('✅ CLIENT: setState terminé, affichage: ${_stages.length} stages');
  } catch (e, stackTrace) {
    print('❌ CLIENT ERREUR: $e');
    print('Stack: $stackTrace');
    setState(() => _isLoading = false);
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