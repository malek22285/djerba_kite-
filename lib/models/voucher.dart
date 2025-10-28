class Voucher {
  final String id;
  final String code;
  final int heuresTotales;
  final int heuresRestantes;
  final DateTime dateExpiration;
  final bool actif;
  final DateTime createdAt;

  Voucher({
    required this.id,
    required this.code,
    required this.heuresTotales,
    required this.heuresRestantes,
    required this.dateExpiration,
    required this.actif,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(dateExpiration);
  bool get isValid => actif && !isExpired && heuresRestantes > 0;
  bool get isExhausted => heuresRestantes <= 0;

  factory Voucher.fromMap(Map<String, dynamic> map, String id) {
    return Voucher(
      id: id,
      code: map['code'] ?? '',
      heuresTotales: map['heures_totales'] ?? 0,
      heuresRestantes: map['heures_restantes'] ?? 0,
      dateExpiration: DateTime.parse(map['date_expiration']),
      actif: map['actif'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'heures_totales': heuresTotales,
      'heures_restantes': heuresRestantes,
      'date_expiration': dateExpiration.toIso8601String(),
      'actif': actif,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Voucher copyWith({
    String? id,
    String? code,
    int? heuresTotales,
    int? heuresRestantes,
    DateTime? dateExpiration,
    bool? actif,
    DateTime? createdAt,
  }) {
    return Voucher(
      id: id ?? this.id,
      code: code ?? this.code,
      heuresTotales: heuresTotales ?? this.heuresTotales,
      heuresRestantes: heuresRestantes ?? this.heuresRestantes,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}