import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stage.dart';

class FirebaseStageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Taux de change (sera remplacé par API plus tard)
  double tauxChangeEur = 3.2;

  // RÉCUPÉRER TOUS LES STAGES ACTIFS (pour client)
  Future<List<Stage>> getAllStages() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('stages')
          .where('actif', isEqualTo: true)
          .orderBy('prixTnd')
          .get();

      return snapshot.docs
          .map((doc) => Stage.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur getAllStages: $e');
      return [];
    }
  }

  // RÉCUPÉRER TOUS LES STAGES (pour admin, actifs + inactifs)
  Future<List<Stage>> getAllStagesForAdmin() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('stages')
          .orderBy('prixTnd')
          .get();

      return snapshot.docs
          .map((doc) => Stage.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur getAllStagesForAdmin: $e');
      return [];
    }
  }

  // RÉCUPÉRER UN STAGE PAR ID
  Future<Stage?> getStageById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('stages')
          .doc(id)
          .get();

      if (!doc.exists) return null;

      return Stage.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Erreur getStageById: $e');
      return null;
    }
  }

  // CRÉER UN STAGE (admin)
  Future<void> createStage({
    required String nom,
    required String description,
    required int duree,
    required double prixTnd,
    required String niveauRequis,
    int remisePourcentage = 0,
  }) async {
    try {
      await _firestore.collection('stages').add({
        'nom': nom,
        'description': description,
        'duree': duree,
        'prixTnd': prixTnd,
        'niveauRequis': niveauRequis,
        'actif': true,
        'remisePourcentage': remisePourcentage,
      });
    } catch (e) {
      throw Exception('Erreur création stage: $e');
    }
  }

  // MODIFIER UN STAGE (admin)
  Future<void> updateStage({
    required String id,
    required String nom,
    required String description,
    required int duree,
    required double prixTnd,
    required String niveauRequis,
    required bool actif,
    required int remisePourcentage,
  }) async {
    try {
      await _firestore.collection('stages').doc(id).update({
        'nom': nom,
        'description': description,
        'duree': duree,
        'prixTnd': prixTnd,
        'niveauRequis': niveauRequis,
        'actif': actif,
        'remisePourcentage': remisePourcentage,
      });
    } catch (e) {
      throw Exception('Erreur modification stage: $e');
    }
  }

  // SUPPRIMER (désactiver) UN STAGE (admin)
  Future<void> deleteStage(String id) async {
    try {
      await _firestore.collection('stages').doc(id).update({
        'actif': false,
      });
    } catch (e) {
      throw Exception('Erreur suppression stage: $e');
    }
  }

  // METTRE À JOUR LE TAUX DE CHANGE
  Future<void> updateTauxChange(double newTaux) async {
    tauxChangeEur = newTaux;
    // TODO: Sauvegarder dans Firestore collection taux_change
  }

  // RÉCUPÉRER LE TAUX DE CHANGE
  double getTauxChange() {
    return tauxChangeEur;
  }
}