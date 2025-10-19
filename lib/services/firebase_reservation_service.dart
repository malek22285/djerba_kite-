import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';

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
        // Convertir Timestamp vers DateTime
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
  // ADMIN: Accepter une demande
  // ========================================
  Future<void> acceptReservation(String id, DateTime date, String heure) async {
    try {
      print('🔵 RESERVATION: Acceptation $id pour $date à $heure');
      
      await _firestore.collection(_collection).doc(id).update({
        'statut': 'confirmee',
        'date_confirmee': Timestamp.fromDate(date),
        'heure_confirmee': heure,
      });

      print('✅ RESERVATION: Acceptée');
    } catch (e) {
      print('❌ RESERVATION ERROR: $e');
      throw Exception('Erreur acceptation: $e');
    }
  }

  // ========================================
  // ADMIN: Proposer une autre date
  // ========================================
  Future<void> proposeReservation(
    String id,
    DateTime date,
    String heure,
    String notes,
  ) async {
    try {
      print('🔵 RESERVATION: Proposition $id pour $date à $heure');
      
      await _firestore.collection(_collection).doc(id).update({
        'date_confirmee': Timestamp.fromDate(date),
        'heure_confirmee': heure,
        'notes_admin': notes,
        // On garde statut en_attente pour que le client puisse accepter/refuser
      });

      print('✅ RESERVATION: Proposition envoyée');
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
  // CLIENT: Accepter une proposition admin
  // ========================================
  Future<void> acceptProposal(String reservationId) async {
    try {
      print('🔵 RESERVATION: Acceptation proposition $reservationId');
      
      await _firestore.collection(_collection).doc(reservationId).update({
        'statut': 'confirmee',
      });

      print('✅ RESERVATION: Proposition acceptée');
    } catch (e) {
      print('❌ RESERVATION ERROR: $e');
      throw Exception('Erreur acceptation proposition: $e');
    }
  }

  // ========================================
  // LEGACY: Récupérer réservations par email (déprécié, utiliser getMyReservations)
  // ========================================
  Future<List<Reservation>> getUserReservations(String userEmail) async {
    try {
      print('⚠️ RESERVATION: getUserReservations est déprécié, utiliser getMyReservations()');
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