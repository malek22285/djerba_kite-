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

 // Ajoute ces méthodes à la fin de la classe ReservationService

// Confirmer une réservation (admin)
Future<void> confirmReservation({
  required String reservationId,
  required DateTime dateConfirmee,
  required String heureConfirmee,
  double remiseIndividuelle = 0,
}) async {
  await Future.delayed(Duration(milliseconds: 500));
  
  final index = _reservations.indexWhere((r) => r.id == reservationId);
  if (index != -1) {
    final old = _reservations[index];
    final prixFinal = old.prixFinal - remiseIndividuelle;
    
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
      dateConfirmee: dateConfirmee,
      heureConfirmee: heureConfirmee,
      statut: 'confirmee',
      niveauClient: old.niveauClient,
      prixFinal: prixFinal,
      voucherCode: old.voucherCode,
      remiseIndividuelle: remiseIndividuelle,
      createdAt: old.createdAt,
    );
  }
}

// Proposer un autre créneau (admin)
Future<void> proposeAlternative({
  required String reservationId,
  required DateTime dateProposee,
  required String heureProposee,
  String? motif,
}) async {
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
      dateConfirmee: dateProposee,
      heureConfirmee: heureProposee,
      statut: 'refusee', // Statut refusée avec proposition
      niveauClient: old.niveauClient,
      prixFinal: old.prixFinal,
      voucherCode: old.voucherCode,
      notesAdmin: motif ?? 'Créneau non disponible. Nouvelle proposition envoyée.',
      createdAt: old.createdAt,
    );
  }
}

// Refuser une réservation (admin)
Future<void> rejectReservation({
  required String reservationId,
  required String motif,
}) async {
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
      statut: 'refusee',
      niveauClient: old.niveauClient,
      prixFinal: old.prixFinal,
      voucherCode: old.voucherCode,
      notesAdmin: motif,
      createdAt: old.createdAt,
    );
  }
}
// Récupérer les réservations confirmées pour un mois
Future<List<Reservation>> getConfirmedReservationsForMonth({
  required int year,
  required int month,
}) async {
  await Future.delayed(Duration(milliseconds: 500));
  
  final startDate = DateTime(year, month, 1);
  final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
  
  return _reservations
      .where((r) => 
          r.statut == 'confirmee' && 
          r.dateConfirmee != null &&
          r.dateConfirmee!.isAfter(startDate.subtract(Duration(days: 1))) &&
          r.dateConfirmee!.isBefore(endDate.add(Duration(days: 1))))
      .toList()
    ..sort((a, b) => a.dateConfirmee!.compareTo(b.dateConfirmee!));
}
// Statistiques pour un mois donné
Future<Map<String, dynamic>> getStatsForMonth({
  required int year,
  required int month,
}) async {
  await Future.delayed(Duration(milliseconds: 500));
  
  final startDate = DateTime(year, month, 1);
  final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
  
  // Réservations confirmées du mois
  final confirmedReservations = _reservations.where((r) =>
      r.statut == 'confirmee' &&
      r.dateConfirmee != null &&
      r.dateConfirmee!.isAfter(startDate.subtract(Duration(days: 1))) &&
      r.dateConfirmee!.isBefore(endDate.add(Duration(days: 1)))).toList();
  
  // Calcul du CA
  double chiffreAffaires = 0;
  for (var r in confirmedReservations) {
    chiffreAffaires += r.prixFinal;
  }
  
  // Répartition par stage
  Map<String, int> repartitionStages = {};
  for (var r in confirmedReservations) {
    repartitionStages[r.stageName] = (repartitionStages[r.stageName] ?? 0) + 1;
  }
  
  // Nombre de vouchers utilisés
  int vouchersUtilises = confirmedReservations
      .where((r) => r.voucherCode != null)
      .length;
  
  return {
    'totalReservations': confirmedReservations.length,
    'chiffreAffaires': chiffreAffaires,
    'repartitionStages': repartitionStages,
    'vouchersUtilises': vouchersUtilises,
  };
}
}