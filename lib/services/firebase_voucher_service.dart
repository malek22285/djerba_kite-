import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voucher.dart';

class FirebaseVoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vouchers';

  // ========================================
  // ADMIN: Créer un voucher
  // ========================================
 Future<String> createVoucher({
  required String code,
  required int heures,
  required DateTime dateExpiration,
}) async {
  try {
    print('🔵 VOUCHER: Création code $code...');

    // Vérifier que le code n'existe pas déjà
    final existing = await _firestore
        .collection(_collection)
        .where('code', isEqualTo: code.toUpperCase())
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Ce code voucher existe déjà');
    }

    // Utiliser DateTime.now() au lieu de serverTimestamp
    final now = DateTime.now();
    
    final docRef = await _firestore.collection(_collection).add({
      'code': code.toUpperCase(),
      'heures_totales': heures,
      'heures_restantes': heures,
      'date_expiration': Timestamp.fromDate(dateExpiration),
      'actif': true,
      'created_at': Timestamp.fromDate(now),  // ← CORRIGÉ
    });

    print('✅ VOUCHER: Créé avec ID ${docRef.id}');
    return docRef.id;
  } catch (e) {
    print('❌ VOUCHER ERROR: $e');
    throw Exception('Erreur création voucher: $e');
  }
}
  // ========================================
  // ADMIN: Liste tous les vouchers
  // ========================================
  Stream<List<Voucher>> getAllVouchers() {
    print('🔵 VOUCHER: Stream tous les vouchers');

    return _firestore
        .collection(_collection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      print('✅ VOUCHER: ${snapshot.docs.length} vouchers');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Voucher.fromMap({
          ...data,
          'date_expiration': (data['date_expiration'] as Timestamp)
              .toDate()
              .toIso8601String(),
          'created_at': data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        }, doc.id);
      }).toList();
    });
  }

  // ========================================
  // ADMIN: Modifier heures restantes
  // ========================================
  Future<void> updateVoucherHeures(String id, int nouvellesHeures) async {
    try {
      print('🔵 VOUCHER: Mise à jour heures $id → $nouvellesHeures');

      await _firestore.collection(_collection).doc(id).update({
        'heures_restantes': nouvellesHeures,
        'actif': nouvellesHeures > 0,
      });

      print('✅ VOUCHER: Heures mises à jour');
    } catch (e) {
      print('❌ VOUCHER ERROR: $e');
      throw Exception('Erreur mise à jour: $e');
    }
  }

  // ========================================
  // ADMIN: Activer/Désactiver un voucher
  // ========================================
  Future<void> toggleVoucherStatus(String id, bool actif) async {
    try {
      print('🔵 VOUCHER: Toggle status $id → $actif');

      await _firestore.collection(_collection).doc(id).update({
        'actif': actif,
      });

      print('✅ VOUCHER: Statut changé');
    } catch (e) {
      print('❌ VOUCHER ERROR: $e');
      throw Exception('Erreur changement statut: $e');
    }
  }

  // ========================================
  // ADMIN: Supprimer un voucher
  // ========================================
  Future<void> deleteVoucher(String id) async {
    try {
      print('🔵 VOUCHER: Suppression $id');

      await _firestore.collection(_collection).doc(id).delete();

      print('✅ VOUCHER: Supprimé');
    } catch (e) {
      print('❌ VOUCHER ERROR: $e');
      throw Exception('Erreur suppression: $e');
    }
  }

  // ========================================
  // CLIENT: Valider un code voucher
  // ========================================
  Future<Voucher?> validateVoucherCode(String code) async {
    try {
      print('🔵 VOUCHER: Validation code $code');

      final snapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ VOUCHER: Code introuvable');
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();

      final voucher = Voucher.fromMap({
        ...data,
        'date_expiration':
            (data['date_expiration'] as Timestamp).toDate().toIso8601String(),
        'created_at': data['created_at'] != null
            ? (data['created_at'] as Timestamp).toDate().toIso8601String()
            : DateTime.now().toIso8601String(),
      }, doc.id);

      print('✅ VOUCHER: Trouvé - ${voucher.heuresRestantes}h restantes');
      return voucher;
    } catch (e) {
      print('❌ VOUCHER ERROR: $e');
      return null;
    }
  }

// ========================================
  // SYSTEM: Décrémenter heures (appelé lors confirmation réservation)
  // ========================================
  Future<void> useVoucherHours(String voucherId, int heures) async {
    try {
      print('🔵 VOUCHER: Utilisation $heures heures du voucher $voucherId');

      final doc = await _firestore.collection(_collection).doc(voucherId).get();

      if (!doc.exists) {
        print('❌ VOUCHER: Document $voucherId introuvable');
        throw Exception('Voucher introuvable');
      }

      print('🔵 VOUCHER: Document trouvé');
      
      final data = doc.data()!;
      final currentHeures = data['heures_restantes'] as int;
      
      print('🔵 VOUCHER: Heures actuelles = $currentHeures');
      print('🔵 VOUCHER: Heures à déduire = $heures');
      
      final newHeures = currentHeures - heures;
      
      print('🔵 VOUCHER: Nouvelles heures = $newHeures');

      if (newHeures < 0) {
        print('⚠️ VOUCHER: Heures insuffisantes ($currentHeures - $heures = $newHeures)');
        throw Exception('Heures insuffisantes sur le voucher');
      }

      print('🔵 VOUCHER: Mise à jour Firestore...');
      
      await _firestore.collection(_collection).doc(voucherId).update({
        'heures_restantes': newHeures,
        'actif': newHeures > 0,
      });

      print('✅ VOUCHER: $heures heures utilisées, reste $newHeures heures');
    } catch (e) {
      print('❌ VOUCHER ERROR: $e');
      throw Exception('Erreur utilisation voucher: $e');
    }
  }
}
