import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static final Color primary = Color(0xFF2A5298);        // Bleu principal de l'application
  static final Color primaryLight = Color(0xFF4E7AC7);   // Nuance de bleu plus claire
  static final Color secondary = Color(0xFF4CAF50);      // Vert pour les actions secondaires
  static final Color accent = Color(0xFFFFA500);         // Orange pour les éléments d'accent

  // Couleurs de texte
  static final Color textPrimary = Colors.white;         // Texte principal (sur fond sombre)
  static final Color textSecondary = Colors.black87;     // Texte secondaire
  static final Color textGrey = Colors.grey[600]!;       // Texte gris pour informations secondaires

  // Couleurs de statut
  static final Color success = Color(0xFF4CAF50);        // Vert pour succès
  static final Color error = Color(0xFFF44336);          // Rouge pour erreurs
  static final Color warning = Color(0xFFFFC107);        // Jaune pour avertissements

  // Couleurs de fond
  static final Color background = Colors.white;          // Fond blanc principal
  static final Color backgroundLight = Color(0xFFF5F5F5);// Fond gris très clair
  static final Color backgroundDark = Color(0xFFE0E0E0); // Fond gris foncé

  // Couleurs spécifiques à l'application
  static final Color stageBadgeBackground = Color(0xFFE3F2FD); // Bleu très clair pour badges
  static final Color reservationStatusWaiting = Color(0xFFFFC107); // Jaune pour statut en attente
}