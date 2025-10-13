import '../models/voucher.dart';

class VoucherService {
  static final List<Voucher> _vouchers = [];
  static int _nextId = 1;

  // Créer un voucher
  Future<Voucher> createVoucher({
    required String code,
    required int heures,
    String? stageType,
    String? clientAssigne,
    DateTime? dateExpiration,
    String? notes,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    // Vérifier que le code n'existe pas déjà
    if (_vouchers.any((v) => v.code.toLowerCase() == code.toLowerCase())) {
      throw Exception('Ce code voucher existe déjà');
    }

    final voucher = Voucher(
      id: 'VCH${_nextId++}',
      code: code.toUpperCase(),
      heuresInitiales: heures,
      heuresRestantes: heures,
      stageType: stageType,
      clientAssigne: clientAssigne,
      dateExpiration: dateExpiration,
      statut: 'actif',
      notes: notes,
      createdAt: DateTime.now(),
    );

    _vouchers.add(voucher);
    return voucher;
  }

  // Récupérer tous les vouchers
  Future<List<Voucher>> getAllVouchers() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_vouchers)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Récupérer un voucher par code
  Future<Voucher?> getVoucherByCode(String code) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _vouchers.firstWhere(
        (v) => v.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Modifier le solde d'heures
  Future<void> updateHeures({
    required String voucherId,
    required int nouvellesHeures,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    final index = _vouchers.indexWhere((v) => v.id == voucherId);
    if (index == -1) throw Exception('Voucher introuvable');

    final old = _vouchers[index];
    
    String nouveauStatut = old.statut;
    if (nouvellesHeures == 0) {
      nouveauStatut = 'utilise';
    } else if (nouvellesHeures > 0 && old.statut == 'utilise') {
      nouveauStatut = 'actif';
    }

    _vouchers[index] = Voucher(
      id: old.id,
      code: old.code,
      heuresInitiales: old.heuresInitiales,
      heuresRestantes: nouvellesHeures,
      stageType: old.stageType,
      clientAssigne: old.clientAssigne,
      dateExpiration: old.dateExpiration,
      statut: nouveauStatut,
      notes: old.notes,
      createdAt: old.createdAt,
      historique: old.historique,
    );
  }

  // Assigner à un client
  Future<void> assignToClient({
    required String voucherId,
    required String clientEmail,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    final index = _vouchers.indexWhere((v) => v.id == voucherId);
    if (index == -1) throw Exception('Voucher introuvable');

    final old = _vouchers[index];

    _vouchers[index] = Voucher(
      id: old.id,
      code: old.code,
      heuresInitiales: old.heuresInitiales,
      heuresRestantes: old.heuresRestantes,
      stageType: old.stageType,
      clientAssigne: clientEmail,
      dateExpiration: old.dateExpiration,
      statut: old.statut,
      notes: old.notes,
      createdAt: old.createdAt,
      historique: old.historique,
    );
  }

  // Utiliser des heures (lors d'une réservation)
  Future<void> useVoucher({
    required String voucherId,
    required int heuresUtilisees,
    required String reservationId,
    required String clientEmail,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    final index = _vouchers.indexWhere((v) => v.id == voucherId);
    if (index == -1) throw Exception('Voucher introuvable');

    final old = _vouchers[index];

    if (old.heuresRestantes < heuresUtilisees) {
      throw Exception('Heures insuffisantes sur le voucher');
    }

    final nouvellesHeures = old.heuresRestantes - heuresUtilisees;
    final nouveauStatut = nouvellesHeures == 0 ? 'utilise' : 'actif';

    final usage = VoucherUsage(
      date: DateTime.now(),
      heuresUtilisees: heuresUtilisees,
      reservationId: reservationId,
      clientEmail: clientEmail,
    );

    _vouchers[index] = Voucher(
      id: old.id,
      code: old.code,
      heuresInitiales: old.heuresInitiales,
      heuresRestantes: nouvellesHeures,
      stageType: old.stageType,
      clientAssigne: old.clientAssigne,
      dateExpiration: old.dateExpiration,
      statut: nouveauStatut,
      notes: old.notes,
      createdAt: old.createdAt,
      historique: [...old.historique, usage],
    );
  }

  // Vérifier l'expiration (à appeler périodiquement)
  Future<void> checkExpirations() async {
    final now = DateTime.now();

    for (int i = 0; i < _vouchers.length; i++) {
      final voucher = _vouchers[i];
      
      if (voucher.dateExpiration != null &&
          voucher.dateExpiration!.isBefore(now) &&
          voucher.statut == 'actif') {
        _vouchers[i] = Voucher(
          id: voucher.id,
          code: voucher.code,
          heuresInitiales: voucher.heuresInitiales,
          heuresRestantes: voucher.heuresRestantes,
          stageType: voucher.stageType,
          clientAssigne: voucher.clientAssigne,
          dateExpiration: voucher.dateExpiration,
          statut: 'expire',
          notes: voucher.notes,
          createdAt: voucher.createdAt,
          historique: voucher.historique,
        );
      }
    }
  }
}