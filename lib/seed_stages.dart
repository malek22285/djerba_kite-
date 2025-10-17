import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(SeedStagesApp());
}

class SeedStagesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SeedStagesScreen(),
    );
  }
}

class SeedStagesScreen extends StatefulWidget {
  @override
  _SeedStagesScreenState createState() => _SeedStagesScreenState();
}

class _SeedStagesScreenState extends State<SeedStagesScreen> {
  String _status = 'Prêt à créer les stages...';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _stages = [
    {
      'nom': 'Stage Débutant - 3h',
      'description': 'Découverte du kitesurf pour débutants. Apprentissage des bases : sécurité, montage/démontage, pilotage du cerf-volant.',
      'duree': 3,
      'prixTnd': 150,
      'niveauRequis': 'Débutant',
      'actif': true,
      'remisePourcentage': 0,
    },
    {
      'nom': 'Stage Intermédiaire - 5h',
      'description': 'Perfectionnement pour kitesurfeurs ayant les bases. Travail du waterstart, premières navigations, transitions.',
      'duree': 5,
      'prixTnd': 250,
      'niveauRequis': 'Intermédiaire',
      'actif': true,
      'remisePourcentage': 0,
    },
    {
      'nom': 'Stage Avancé - 8h',
      'description': 'Stage intensif pour riders confirmés. Perfectionnement des sauts, tricks, navigation upwind.',
      'duree': 8,
      'prixTnd': 380,
      'niveauRequis': 'Avancé',
      'actif': true,
      'remisePourcentage': 0,
    },
    {
      'nom': 'Stage Confirmé - 10h',
      'description': 'Programme complet pour riders confirmés souhaitant maîtriser les tricks avancés et le freestyle.',
      'duree': 10,
      'prixTnd': 450,
      'niveauRequis': 'Confirmé',
      'actif': true,
      'remisePourcentage': 10,
    },
  ];

  Future<void> _seedStages() async {
    setState(() {
      _isLoading = true;
      _status = 'Création des stages...';
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Supprimer les stages existants
      QuerySnapshot existingStages = await firestore.collection('stages').get();
      for (var doc in existingStages.docs) {
        await doc.reference.delete();
      }

      // Créer les nouveaux stages
      for (var stage in _stages) {
        await firestore.collection('stages').add(stage);
      }

      setState(() {
        _status = '✅ SUCCÈS!\n\n${_stages.length} stages créés dans Firestore.\n\nVous pouvez fermer cette fenêtre.';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status = '❌ ERREUR:\n$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seed Stages'),
        backgroundColor: Color(0xFF2a5298),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 40),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _seedStages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2a5298),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: Text(
                        'CRÉER LES STAGES',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}