class Voucher {
  final String id;
  final String code;
  final int heuresInitiales;
  final int heuresRestantes;
  final String? stageType; // null = tous stages
  final String? clientAssigne; // Email du client
  final DateTime? dateExpiration;
  final String statut; // actif, utilise, expire
  final String? notes;
  final DateTime createdAt;
  final List<VoucherUsage> historique;

  Voucher({
    required this.id,
    required this.code,
    required this.heuresInitiales,
    required this.heuresRestantes,
    this.stageType,
    this.clientAssigne,
    this.dateExpiration,
    required this.statut,
    this.notes,
    required this.createdAt,
    this.historique = const [],
  });

  bool get isActif => statut == 'actif';
  bool get isUtilise => statut == 'utilise';
  bool get isExpire => statut == 'expire';
  
  double get pourcentageUtilise => 
      heuresInitiales > 0 ? (heuresInitiales - heuresRestantes) / heuresInitiales * 100 : 0;

  factory Voucher.fromMap(Map<String, dynamic> map, String id) {
    return Voucher(
      id: id,
      code: map['code'] ?? '',
      heuresInitiales: map['heures_initiales'] ?? 0,
      heuresRestantes: map['heures_restantes'] ?? 0,
      stageType: map['stage_type'],
      clientAssigne: map['client_assigne'],
      dateExpiration: map['date_expiration'] != null
          ? DateTime.parse(map['date_expiration'])
          : null,
      statut: map['statut'] ?? 'actif',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      historique: (map['historique'] as List?)
              ?.map((h) => VoucherUsage.fromMap(h))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'heures_initiales': heuresInitiales,
      'heures_restantes': heuresRestantes,
      'stage_type': stageType,
      'client_assigne': clientAssigne,
      'date_expiration': dateExpiration?.toIso8601String(),
      'statut': statut,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'historique': historique.map((h) => h.toMap()).toList(),
    };
  }
}

// Historique d'utilisation d'un voucher
class VoucherUsage {
  final DateTime date;
  final int heuresUtilisees;
  final String reservationId;
  final String clientEmail;

  VoucherUsage({
    required this.date,
    required this.heuresUtilisees,
    required this.reservationId,
    required this.clientEmail,
  });

  factory VoucherUsage.fromMap(Map<String, dynamic> map) {
    return VoucherUsage(
      date: DateTime.parse(map['date']),
      heuresUtilisees: map['heures_utilisees'] ?? 0,
      reservationId: map['reservation_id'] ?? '',
      clientEmail: map['client_email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'heures_utilisees': heuresUtilisees,
      'reservation_id': reservationId,
      'client_email': clientEmail,
    };
  }
}