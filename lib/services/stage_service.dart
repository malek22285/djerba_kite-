import '../models/stage.dart';

class StageService {
  // Taux de change TND -> EUR (sera automatique plus tard avec l'API)
  static double tauxChangeEur = 3.2; // 1 EUR = 3.2 TND environ

  // Data en dur pour l'instant (sera Firestore plus tard)
  static final List<Stage> _stages = [
    Stage(
      id: '1',
      nom: 'Stage Débutant - 3h',
      description: 'Découverte du kitesurf pour les débutants. Apprentissage des bases : gréement, sécurité, premiers bords.',
      duree: 3,
      prixTnd: 150,
      niveauRequis: 'Débutant',
    ),
    Stage(
      id: '2',
      nom: 'Stage Intermédiaire - 5h',
      description: 'Perfectionnement : remontée au vent, transitions, sauts. Pour riders ayant déjà les bases.',
      duree: 5,
      prixTnd: 250,
      niveauRequis: 'Intermédiaire',
    ),
    Stage(
      id: '3',
      nom: 'Stage Confirmé - 10h',
      description: 'Stage intensif pour riders confirmés. Tricks avancés, freestyle, navigation en toute autonomie.',
      duree: 10,
      prixTnd: 450,
      niveauRequis: 'Confirmé',
      remisePourcentage: 10, // -10% sur ce stage
    ),
    Stage(
      id: '4',
      nom: 'Cours Particulier - 1h',
      description: 'Cours privé adapté à votre niveau. Progression rapide avec moniteur dédié.',
      duree: 1,
      prixTnd: 80,
      niveauRequis: 'Tous niveaux',
    ),
  ];

  // Récupère tous les stages actifs
  Future<List<Stage>> getAllStages() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simule latence
    return _stages.where((stage) => stage.actif).toList();
  }

  // Récupère un stage par ID
  Future<Stage?> getStageById(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _stages.firstWhere((stage) => stage.id == id);
    } catch (e) {
      return null;
    }
  }
  // Créer un stage
Future<Stage> createStage({
  required String nom,
  required String description,
  required int duree,
  required double prixTnd,
  required String niveauRequis,
  double remisePourcentage = 0,
}) async {
  await Future.delayed(Duration(milliseconds: 500));
  
  final newStage = Stage(
    id: 'STAGE${_stages.length + 1}',
    nom: nom,
    description: description,
    duree: duree,
    prixTnd: prixTnd,
    niveauRequis: niveauRequis,
    actif: true,
    remisePourcentage: remisePourcentage,
  );
  
  _stages.add(newStage);
  return newStage;
}

// Modifier un stage
Future<void> updateStage({
  required String id,
  required String nom,
  required String description,
  required int duree,
  required double prixTnd,
  required String niveauRequis,
  required double remisePourcentage,
  required bool actif,
}) async {
  await Future.delayed(Duration(milliseconds: 500));
  
  final index = _stages.indexWhere((s) => s.id == id);
  if (index != -1) {
    _stages[index] = Stage(
      id: id,
      nom: nom,
      description: description,
      duree: duree,
      prixTnd: prixTnd,
      niveauRequis: niveauRequis,
      actif: actif,
      remisePourcentage: remisePourcentage,
    );
  }
}

// Supprimer un stage (désactivation plutôt que suppression réelle)
Future<void> deleteStage(String id) async {
  await Future.delayed(Duration(milliseconds: 500));
  
  final index = _stages.indexWhere((s) => s.id == id);
  if (index != -1) {
    final old = _stages[index];
    _stages[index] = Stage(
      id: old.id,
      nom: old.nom,
      description: old.description,
      duree: old.duree,
      prixTnd: old.prixTnd,
      niveauRequis: old.niveauRequis,
      actif: false, // Désactivé
      remisePourcentage: old.remisePourcentage,
    );
  }
}

// Récupérer TOUS les stages (même inactifs) pour l'admin
Future<List<Stage>> getAllStagesForAdmin() async {
  await Future.delayed(Duration(milliseconds: 500));
  return List.from(_stages);
}
}