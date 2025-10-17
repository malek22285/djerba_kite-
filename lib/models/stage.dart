class Stage {
  final String id;
  final String nom;
  final String description;
  final int duree; // en heures
  final double prixTnd;
  final String niveauRequis;
  final bool actif;
  final int remisePourcentage;

  Stage({
    required this.id,
    required this.nom,
    required this.description,
    required this.duree,
    required this.prixTnd,
    required this.niveauRequis,
    this.actif = true,
    this.remisePourcentage = 0,
  });

  // Prix en EUR (conversion avec taux actuel)
  double getPrixEur(double tauxChange) {
    return prixTnd / tauxChange;
  }

  // Prix après remise
  double getPrixFinal() {
    if (remisePourcentage > 0) {
      return prixTnd * (1 - remisePourcentage / 100);
    }
    return prixTnd;
  }

  // Conversion depuis Map Firestore - CORRIGÉ
  factory Stage.fromMap(String id, Map<String, dynamic> map) {
    return Stage(
      id: id,
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      duree: map['duree'] ?? 0,
      prixTnd: (map['prixTnd'] ?? 0).toDouble(), // ← CORRIGÉ
      niveauRequis: map['niveauRequis'] ?? '',    // ← CORRIGÉ
      actif: map['actif'] ?? true,
      remisePourcentage: (map['remisePourcentage'] ?? 0).toInt(), // ← CORRIGÉ
    );
  }

  // Conversion vers Map Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'duree': duree,
      'prixTnd': prixTnd,
      'niveauRequis': niveauRequis,
      'actif': actif,
      'remisePourcentage': remisePourcentage,
    };
  }
}