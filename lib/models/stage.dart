class Stage {
  final String id;
  final String nom;
  final String description;
  final int duree; // en heures
  final double prixTnd;
  final String niveauRequis;
  final bool actif;
  final double remisePourcentage;

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

  // Conversion depuis Map (pour Firestore plus tard)
  factory Stage.fromMap(Map<String, dynamic> map, String id) {
    return Stage(
      id: id,
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      duree: map['duree'] ?? 0,
      prixTnd: (map['prix_tnd'] ?? 0).toDouble(),
      niveauRequis: map['niveau_requis'] ?? '',
      actif: map['actif'] ?? true,
      remisePourcentage: (map['remise_pourcentage'] ?? 0).toDouble(),
    );
  }

  // Conversion vers Map (pour Firestore plus tard)
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'duree': duree,
      'prix_tnd': prixTnd,
      'niveau_requis': niveauRequis,
      'actif': actif,
      'remise_pourcentage': remisePourcentage,
    };
  }
}