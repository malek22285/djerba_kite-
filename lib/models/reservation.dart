class Reservation {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String userPhone;
  final String stageId;
  final String stageName;
  final DateTime dateDemande;
  final String heureDemande;
  final DateTime? dateConfirmee;
  final String? heureConfirmee;
  final String statut; // en_attente, confirmee, refusee, annulee
  final String niveauClient;
  final double prixFinal;
  final String? voucherId;
  final String? voucherCode;
  final String? notesAdmin;
  final double remiseIndividuelle;
  final DateTime createdAt;
  final int stageDuree;

  Reservation({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.userPhone,
    required this.stageId,
    required this.stageName,
    required this.dateDemande,
    required this.heureDemande,
    this.dateConfirmee,
    this.heureConfirmee,
    required this.statut,
    required this.niveauClient,
    required this.prixFinal,
    this.voucherId,
    this.voucherCode,
    this.notesAdmin,
    this.remiseIndividuelle = 0,
    required this.createdAt,
    required this.stageDuree,
  });

  bool get isEnAttente => statut == 'en_attente';
  bool get isConfirmee => statut == 'confirmee';
  bool get isRefusee => statut == 'refusee';
  bool get isAnnulee => statut == 'annulee';
  bool get isPropositionEnvoyee => statut == 'proposition_envoyee';
 bool get isTerminee => statut == 'terminee';
  factory Reservation.fromMap(Map<String, dynamic> map, String id) {
    return Reservation(
      id: id,
      userId: map['user_id'] ?? '',
      userEmail: map['user_email'] ?? '',
      userName: map['user_name'] ?? '',
      userPhone: map['user_phone'] ?? '',
      stageId: map['stage_id'] ?? '',
      stageName: map['stage_name'] ?? '',
      dateDemande: DateTime.parse(map['date_demande']),
      heureDemande: map['heure_demande'] ?? '',
      dateConfirmee: map['date_confirmee'] != null 
          ? DateTime.parse(map['date_confirmee']) 
          : null,
      heureConfirmee: map['heure_confirmee'],
      statut: map['statut'] ?? 'en_attente',
      niveauClient: map['niveau_client'] ?? '',
      prixFinal: (map['prix_final'] ?? 0).toDouble(),
      voucherId: map['voucher_id'],
      voucherCode: map['voucher_code'],
      notesAdmin: map['notes_admin'],
      remiseIndividuelle: (map['remise_individuelle'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      stageDuree: map['stage_duree'] ?? 3, // défaut 3 heures
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_email': userEmail,
      'user_name': userName,
      'user_phone': userPhone,
      'stage_id': stageId,
      'stage_name': stageName,
      'date_demande': dateDemande.toIso8601String(),
      'heure_demande': heureDemande,
      'date_confirmee': dateConfirmee?.toIso8601String(),
      'heure_confirmee': heureConfirmee,
      'statut': statut,
      'niveau_client': niveauClient,
      'prix_final': prixFinal,
      'voucher_id': voucherId,
      'voucher_code': voucherCode,
      'notes_admin': notesAdmin,
      'remise_individuelle': remiseIndividuelle,
      'created_at': createdAt.toIso8601String(),
      'stage_duree': stageDuree,
    };
  }
  Reservation copyWith({
  String? id,
  String? userId,
  String? userEmail,
  String? userName,
  String? userPhone,
  String? stageId,
  String? stageName,
  DateTime? dateDemande,
  String? heureDemande,
  DateTime? dateConfirmee,
  String? heureConfirmee,
  String? statut,
  String? niveauClient,
  double? prixFinal,
  String? voucherId,
  String? voucherCode,
  String? notesAdmin,
  double? remiseIndividuelle,
  DateTime? createdAt,
  int? stageDuree,
}) {
  return Reservation(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userEmail: userEmail ?? this.userEmail,
    userName: userName ?? this.userName,
    userPhone: userPhone ?? this.userPhone,
    stageId: stageId ?? this.stageId,
    stageName: stageName ?? this.stageName,
    dateDemande: dateDemande ?? this.dateDemande,
    heureDemande: heureDemande ?? this.heureDemande,
    dateConfirmee: dateConfirmee ?? this.dateConfirmee,
    heureConfirmee: heureConfirmee ?? this.heureConfirmee,
    statut: statut ?? this.statut,
    niveauClient: niveauClient ?? this.niveauClient,
    prixFinal: prixFinal ?? this.prixFinal,
    voucherId: voucherId ?? this.voucherId,
    voucherCode: voucherCode ?? this.voucherCode,
    notesAdmin: notesAdmin ?? this.notesAdmin,
    remiseIndividuelle: remiseIndividuelle ?? this.remiseIndividuelle,
    createdAt: createdAt ?? this.createdAt,
    stageDuree: stageDuree ?? this.stageDuree,
  );
}
}