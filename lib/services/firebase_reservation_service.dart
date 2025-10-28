import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';
import 'firebase_voucher_service.dart';

class FirebaseReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reservations';

  // ========================================
  // CLIENT: Créer une demande de réservation
  // ========================================
  Future<String> createReservation({
    required String userId,
    required String userEmail,
    required String userName,
    required String userPhone,
    required String stageId,
    required String stageName,
    required int stageDuree,
    required DateTime dateDemande,
    required String heureDemande,
    required String niveauClient,
    required double prixFinal,
    String? voucherId,
    String? voucherCode,
    double remiseIndividuelle = 0,
  }) async {
    try {
      print('🔵 RESERVATION: Création demande...');
      
      final docRef = await _firestore.collection(_collection).add({
        'user_id': userId,
        'user_email': userEmail,
        'user_name': userName,
        'user_phone': userPhone,
        'stage_id': stageId,
        'stage_name': stageName,
        'stage_duree': stageDuree,
        'date_demande': Timestamp.fromDate(dateDemande),
        'heure_demande': heureDemande,
        'date_confirmee': null,
        'heure_confirmee': null,
        'statut': 'en_attente',
        'niveau_client': niveauClient,
        'prix_final': prixFinal,
        'voucher_id': voucherId,
        'voucher_code': voucherCode,
        'notes_admin': null,
        'remise_individuelle': remiseIndividuelle,
        'created_at': FieldValue.serverTimestamp(),
      });

      print('✅ RESERVATION: Créée avec ID ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ RESERVATION ERROR: $e');
      throw Exception('Erreur création réservation: $e');
    }
  }

  // ========================================
  // CLIENT: Mes réservations
  // ========================================
  Stream<List<Reservation>> getMyReservations(String userId) {
    print('🔵 RESERVATION: Stream pour user $userId');
    
    return _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      print('✅ RESERVATION: ${snapshot.docs.length} réservations');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Reservation.fromMap({
          ...data,
          'date_demande': (data['date_demande'] as Timestamp).toDate().toIso8601String(),
          'date_confirmee': data['date_confirmee'] != null 
              ? (data['date_confirmee'] as Timestamp).toDate().toIso8601String()
              : null,
          'created_at': data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        }, doc.id);
      }).toList();
    });
  }

  // ========================================
  // ADMIN: Toutes les demandes en attente
  // ========================================
  Stream<List<Reservation>> getPendingReservations() {
    print('🔵 RESERVATION: Stream demandes en attente');
    
    return _firestore
        .collection(_collection)
        .where('statut', isEqualTo: 'en_attente')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      print('✅ RESERVATION: ${snapshot.docs.length} demandes en attente');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Reservation.fromMap({
          ...data,
          'date_demande': (data['date_demande'] as Timestamp).toDate().toIso8601String(),
          'date_confirmee': data['date_confirmee'] != null 
              ? (data['date_confirmee'] as Timestamp).toDate().toIso8601String()
              : null,
          'created_at': data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        }, doc.id);
      }).toList();
    });
  }
  // ========================================
// ADMIN: Propositions en attente de réponse client
// ========================================
Stream<List<Reservation>> getProposedReservations() {
  print('🔵 RESERVATION: Stream propositions en attente');
  
  return _firestore
      .collection(_collection)
      .where('statut', isEqualTo: 'proposition_envoyee')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    print('✅ RESERVATION: ${snapshot.docs.length} propositions en attente');
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Reservation.fromMap({
        ...data,
        'date_demande': (data['date_demande'] as Timestamp).toDate().toIso8601String(),
        'date_confirmee': data['date_confirmee'] != null 
            ? (data['date_confirmee'] as Timestamp).toDate().toIso8601String()
            : null,
        'created_at': data['created_at'] != null
            ? (data['created_at'] as Timestamp).toDate().toIso8601String()
            : DateTime.now().toIso8601String(),
      }, doc.id);
    }).toList();
  });
}

  // ========================================
  // ADMIN: Toutes les réservations
  // ========================================
  Stream<List<Reservation>> getAllReservations() {
    print('🔵 RESERVATION: Stream toutes réservations');
    
    return _firestore
        .collection(_collection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      print('✅ RESERVATION: ${snapshot.docs.length} réservations totales');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Reservation.fromMap({
          ...data,
          'date_demande': (data['date_demande'] as Timestamp).toDate().toIso8601String(),
          'date_confirmee': data['date_confirmee'] != null 
              ? (data['date_confirmee'] as Timestamp).toDate().toIso8601String()
              : null,
          'created_at': data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        }, doc.id);
      }).toList();
    });
  }

  // ========================================
  // ADMIN: Réservations pour un mois
  // ========================================
  Stream<List<Reservation>> getReservationsForMonth(int year, int month) {
    print('🔵 RESERVATION: Stream pour $year-$month');
    
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return _firestore
        .collection(_collection)
        .where('date_confirmee', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date_confirmee', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('statut', isEqualTo: 'confirmee')
        .snapshots()
        .map((snapshot) {
      print('✅ RESERVATION: ${snapshot.docs.length} réservations ce mois');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Reservation.fromMap({
          ...data,
          'date_demande': (data['date_demande'] as Timestamp).toDate().toIso8601String(),
          'date_confirmee': data['date_confirmee'] != null 
              ? (data['date_confirmee'] as Timestamp).toDate().toIso8601String()
              : null,
          'created_at': data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        }, doc.id);
      }).toList();
    });
  }

  // ========================================
  // ADMIN: Accepter une demande (AVEC AUTO-DÉCRÉMENT VOUCHER)
  // ========================================
  Future<void> confirmReservation(
    String id,
    DateTime date,
    String heure, {
    double remiseIndividuelle = 0,
  }) async {
    try {
      print('🔵 RESERVATION: Acceptation $id pour $date à $heure');
      
      // 1. Récupérer la réservation
      final reservationDoc = await _firestore.collection(_collection).doc(id).get();
      
      if (!reservationDoc.exists) {
        throw Exception('Réservation introuvable');
      }
      
      final reservationData = reservationDoc.data()!;
      // AJOUTE CES PRINTS ↓
print('🔵 DEBUG: reservationData = $reservationData');
print('🔵 DEBUG: voucher_id = ${reservationData['voucher_id']}');
print('🔵 DEBUG: voucher_code = ${reservationData['voucher_code']}');
print('🔵 DEBUG: stage_duree = ${reservationData['stage_duree']}');
      
      // 2. Mettre à jour la réservation
      await _firestore.collection(_collection).doc(id).update({
        'statut': 'confirmee',
        'date_confirmee': Timestamp.fromDate(date),
        'heure_confirmee': heure,
        'remise_individuelle': remiseIndividuelle,
      });

      print('✅ RESERVATION: Acceptée');

      // 3. Si voucher utilisé, décrémenter automatiquement
      if (reservationData['voucher_id'] != null) {
        final voucherId = reservationData['voucher_id'] as String;
        final stageDuree = reservationData['stage_duree'] as int? ?? 3;
        
        print('🔵 VOUCHER: Décrémenter $voucherId de ${stageDuree}h');
        
        try {
          final voucherService = FirebaseVoucherService();
          await voucherService.useVoucherHours(voucherId, stageDuree);
          print('✅ VOUCHER: Décrémenté automatiquement');
        } catch (e) {
          print('⚠️ VOUCHER: Erreur décrémention: $e');
        }
      }
    } catch (e) {
      print('❌ RESERVATION ERROR: $e');
      throw Exception('Erreur acceptation: $e');
    }
  }

  // ========================================
  // ADMIN: Proposer une autre date
  // ========================================
 Future<void> proposeAlternative(
  String id,
  DateTime date,
  String heure,
  String notes,
) async {
  try {
    print('🔵 RESERVATION: Proposition $id pour $date à $heure');
    
    await _firestore.collection(_collection).doc(id).update({
      'statut': 'proposition_envoyee',  // ← AJOUTÉ
      'date_confirmee': Timestamp.fromDate(date),
      'heure_confirmee': heure,
      'notes_admin': notes,
    });

    print('✅ RESERVATION: Proposition envoyée (statut = proposition_envoyee)');
  } catch (e) {
    print('❌ RESERVATION ERROR: $e');
    throw Exception('Erreur proposition: $e');
  }
}

  // ========================================
  // ADMIN: Refuser une demande
  // ========================================
  Future<void> rejectReservation(String id, String notes) async {
    try {
      print('🔵 RESERVATION: Refus $id');
      
      await _firestore.collection(_collection).doc(id).update({
        'statut': 'refusee',
        'notes_admin': notes,
      });

      print('✅ RESERVATION: Refusée');
    } catch (e) {
      print('❌ RESERVATION ERROR: $e');
      throw Exception('Erreur refus: $e');
    }
  }

  // ========================================
  // CLIENT: Annuler ma réservation
  // ========================================
  Future<void> cancelReservation(String id) async {
    try {
      print('🔵 RESERVATION: Annulation $id');
      
      await _firestore.collection(_collection).doc(id).update({
        'statut': 'annulee',
      });

      print('✅ RESERVATION: Annulée');
    } catch (e) {
      print('❌ RESERVATION ERROR: $e');
      throw Exception('Erreur annulation: $e');
    }
  }

  // ========================================
  // CLIENT: Accepter une proposition admin (AVEC AUTO-DÉCRÉMENT VOUCHER)
  // ========================================
  Future<void> acceptProposal(String reservationId) async {
    try {
      print('🔵 RESERVATION: Acceptation proposition $reservationId');
      
      // 1. Récupérer la réservation
      final reservationDoc = await _firestore.collection(_collection).doc(reservationId).get();
      
      if (!reservationDoc.exists) {
        throw Exception('Réservation introuvable');
      }
      
      final reservationData = reservationDoc.data()!;
      
      // 2. Mettre à jour le statut
      await _firestore.collection(_collection).doc(reservationId).update({
        'statut': 'confirmee',
      });

      print('✅ RESERVATION: Proposition acceptée');

      // 3. Si voucher utilisé, décrémenter automatiquement
      if (reservationData['voucher_id'] != null) {
        final voucherId = reservationData['voucher_id'] as String;
        final stageDuree = reservationData['stage_duree'] as int? ?? 3;
        
        print('🔵 VOUCHER: Décrémenter $voucherId de ${stageDuree}h');
        
        try {
          final voucherService = FirebaseVoucherService();
          await voucherService.useVoucherHours(voucherId, stageDuree);
          print('✅ VOUCHER: Décrémenté automatiquement');
        } catch (e) {
          print('⚠️ VOUCHER: Erreur décrémention: $e');
        }
      }
    } catch (e) {
      print('❌ RESERVATION ERROR: $e');
      throw Exception('Erreur acceptation proposition: $e');
    }
  }

  // ========================================
  // ADMIN: Réservations confirmées pour un mois (version Future)
  // ========================================
  Future<List<Reservation>> getConfirmedReservationsForMonth(int year, int month) async {
    try {
      print('🔵 RESERVATION: Récupération confirmées $year-$month');
      
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _firestore
          .collection(_collection)
          .where('date_confirmee', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date_confirmee', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('statut', isEqualTo: 'confirmee')
          .get();

      print('✅ RESERVATION: ${snapshot.docs.length} confirmées');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Reservation.fromMap({
          ...data,
          'date_demande': (data['date_demande'] as Timestamp).toDate().toIso8601String(),
          'date_confirmee': data['date_confirmee'] != null 
              ? (data['date_confirmee'] as Timestamp).toDate().toIso8601String()
              : null,
          'created_at': data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        }, doc.id);
      }).toList();
    } catch (e) {
      print('❌ RESERVATION ERROR: $e');
      return [];
    }
  }

  // ========================================
  // ADMIN: Stats pour un mois
  // ========================================
  Future<Map<String, dynamic>> getStatsForMonth(int year, int month) async {
    try {
      print('🔵 RESERVATION: Stats pour $year-$month');
      
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      final confirmeesSnapshot = await _firestore
          .collection(_collection)
          .where('date_confirmee', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date_confirmee', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('statut', isEqualTo: 'confirmee')
          .get();

      final enAttenteSnapshot = await _firestore
          .collection(_collection)
          .where('statut', isEqualTo: 'en_attente')
          .get();

      double chiffreAffaires = 0;
      int vouchersUtilises = 0;
      Map<String, int> repartitionStages = {};
      
      for (var doc in confirmeesSnapshot.docs) {
        final data = doc.data();
        
        chiffreAffaires += (data['prix_final'] ?? 0).toDouble();
        
        if (data['voucher_code'] != null && data['voucher_code'] != '') {
          vouchersUtilises++;
        }
        
        final stageName = data['stage_name'] ?? 'Inconnu';
        repartitionStages[stageName] = (repartitionStages[stageName] ?? 0) + 1;
      }
      
      final stats = {
        'totalReservations': confirmeesSnapshot.docs.length,
        'en_attente': enAttenteSnapshot.docs.length,
        'chiffreAffaires': chiffreAffaires,
        'vouchersUtilises': vouchersUtilises,
        'repartitionStages': repartitionStages,
      };
      
      print('✅ STATS: $stats');
      return stats;
    } catch (e) {
      print('❌ STATS ERROR: $e');
      return {
        'totalReservations': 0,
        'chiffreAffaires': 0.0,
        'vouchersUtilises': 0,
        'repartitionStages': {},
      };
    }
  }

  // ========================================
  // LEGACY: Récupérer réservations par email
  // ========================================
  Future<List<Reservation>> getUserReservations(String userEmail) async {
    try {
      print('⚠️ getUserReservations déprécié');
      print('🔵 RESERVATION: Récupération pour email $userEmail');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('user_email', isEqualTo: userEmail)
          .orderBy('created_at', descending: true)
          .get();

      print('✅ RESERVATION: ${snapshot.docs.length} réservations');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Reservation.fromMap({
          ...data,
          'date_demande': (data['date_demande'] as Timestamp).toDate().toIso8601String(),
          'date_confirmee': data['date_confirmee'] != null 
              ? (data['date_confirmee'] as Timestamp).toDate().toIso8601String()
              : null,
          'created_at': data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        }, doc.id);
      }).toList();
    } catch (e) {
      print('❌ RESERVATION ERROR: $e');
      return [];
    }
  }
}