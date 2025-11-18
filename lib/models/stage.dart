class Stage {
  final String id;
  final String nom;
  final String description;
  final int duree; // en heures
  final double? prixTnd; // Optionnel (pour backward compatibility)
  final double? prixEur; // Nouveau champ
  final String niveauRequis;
  final bool actif;
  final int remisePourcentage;

  Stage({
    required this.id,
    required this.nom,
    required this.description,
    required this.duree,
    this.prixTnd,
    this.prixEur,
    required this.niveauRequis,
    this.actif = true,
    this.remisePourcentage = 0,
  });

  /// Obtenir prix en EUR (priorité: prixEur, sinon conversion depuis TND)
  double getPrixEur(double tauxChange) {
    if (prixEur != null) {
      return prixEur!;
    }
    if (prixTnd != null) {
      return prixTnd! / tauxChange;
    }
    return 0;
  }

  /// Obtenir prix en TND (priorité: prixTnd, sinon conversion depuis EUR)
  double getPrixTnd(double tauxChange) {
    if (prixTnd != null) {
      return prixTnd!;
    }
    if (prixEur != null) {
      return prixEur! * tauxChange;
    }
    return 0;
  }

  /// Prix final en TND après remise
  double getPrixFinal({double? tauxChange}) {
    final prixBase = tauxChange != null 
        ? getPrixTnd(tauxChange) 
        : (prixTnd ?? 0);
    
    if (remisePourcentage > 0) {
      return prixBase * (1 - remisePourcentage / 100);
    }
    return prixBase;
  }

  /// Prix final en EUR après remise
  double getPrixFinalEur(double tauxChange) {
    final prixBase = getPrixEur(tauxChange);
    
    if (remisePourcentage > 0) {
      return prixBase * (1 - remisePourcentage / 100);
    }
    return prixBase;
  }

  /// Format d'affichage: "50 EUR (≈ 171 TND)"
  String formatPrix(double tauxChange) {
    final eur = getPrixEur(tauxChange);
    final tnd = getPrixTnd(tauxChange);
    return '${eur.toStringAsFixed(0)} EUR (≈ ${tnd.toStringAsFixed(0)} TND)';
  }

  /// Conversion depuis Map Firestore
  factory Stage.fromMap(String id, Map<String, dynamic> map) {
    return Stage(
      id: id,
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      duree: map['duree'] ?? 0,
      prixTnd: map['prixTnd'] != null ? (map['prixTnd'] as num).toDouble() : null,
      prixEur: map['prixEur'] != null ? (map['prixEur'] as num).toDouble() : null,
      niveauRequis: map['niveauRequis'] ?? '',
      actif: map['actif'] ?? true,
      remisePourcentage: map['remisePourcentage'] != null 
          ? (map['remisePourcentage'] as num).toInt() 
          : 0,
    );
  }

  /// Conversion vers Map Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'duree': duree,
      if (prixTnd != null) 'prixTnd': prixTnd,
      if (prixEur != null) 'prixEur': prixEur,
      'niveauRequis': niveauRequis,
      'actif': actif,
      'remisePourcentage': remisePourcentage,
    };
  }

  /// Créer une copie avec modifications
  Stage copyWith({
    String? id,
    String? nom,
    String? description,
    int? duree,
    double? prixTnd,
    double? prixEur,
    String? niveauRequis,
    bool? actif,
    int? remisePourcentage,
  }) {
    return Stage(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      duree: duree ?? this.duree,
      prixTnd: prixTnd ?? this.prixTnd,
      prixEur: prixEur ?? this.prixEur,
      niveauRequis: niveauRequis ?? this.niveauRequis,
      actif: actif ?? this.actif,
      remisePourcentage: remisePourcentage ?? this.remisePourcentage,
    );
  }
}