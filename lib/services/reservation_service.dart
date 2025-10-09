import '../models/reservation.dart';

class ReservationService {
  // Stockage en mémoire (sera Firestore plus tard)
  static final List<Reservation> _reservations = [];
  static int _nextId = 1;

  // Créer une réservation
  Future<Reservation> createReservation({
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
    String? voucherCode,
  }) async {
    await Future.delayed(Duration(milliseconds: 800)); // Simule latence

    final reservation = Reservation(
      id: 'RES${_nextId++}',
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      userPhone: userPhone,
      stageId: stageId,
      stageName: stageName,
      dateDemande: dateDemande,
      heureDemande: heureDemande,
      statut: 'en_attente',
      niveauClient: niveauClient,
      prixFinal: prixFinal,
      voucherCode: voucherCode,
      createdAt: DateTime.now(),
    );

    _reservations.add(reservation);
    return reservation;
  }

  // Récupérer les réservations d'un utilisateur
  Future<List<Reservation>> getUserReservations(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _reservations
        .where((res) => res.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Plus récentes d'abord
  }

  // Récupérer toutes les réservations (pour l'admin)
  Future<List<Reservation>> getAllReservations() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_reservations)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Récupérer les réservations en attente (pour l'admin)
  Future<List<Reservation>> getPendingReservations() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _reservations
        .where((res) => res.statut == 'en_attente')
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Plus anciennes d'abord
  }

  // Annuler une réservation (client)
  Future<void> cancelReservation(String reservationId) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    final index = _reservations.indexWhere((r) => r.id == reservationId);
    if (index != -1) {
      final old = _reservations[index];
      _reservations[index] = Reservation(
        id: old.id,
        userId: old.userId,
        userEmail: old.userEmail,
        userName: old.userName,
        userPhone: old.userPhone,
        stageId: old.stageId,
        stageName: old.stageName,
        dateDemande: old.dateDemande,
        heureDemande: old.heureDemande,
        statut: 'annulee',
        niveauClient: old.niveauClient,
        prixFinal: old.prixFinal,
        voucherCode: old.voucherCode,
        createdAt: old.createdAt,
      );
    }
  }

  // Confirmer une réservation (admin) - à implémenter plus tard
  // Refuser une réservation (admin) - à implémenter plus tard
}