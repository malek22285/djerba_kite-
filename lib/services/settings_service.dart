import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _settingsDoc = 'settings';
  static const String _currencyDoc = 'currency';

  /// Obtenir les paramètres de devise
  Future<Map<String, dynamic>> getCurrencySettings() async {
    try {
      final doc = await _firestore
          .collection(_settingsDoc)
          .doc(_currencyDoc)
          .get();

      if (doc.exists) {
        return doc.data() ?? _getDefaultSettings();
      }
      return _getDefaultSettings();
    } catch (e) {
      print('❌ SETTINGS ERROR: $e');
      return _getDefaultSettings();
    }
  }

  /// Paramètres par défaut
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'use_manual': false,
      'manual_rate': 3.30,
      'manual_rate_date': null,
    };
  }

  /// Activer le taux manuel
  Future<void> setManualRate(double rate) async {
    try {
      await _firestore
          .collection(_settingsDoc)
          .doc(_currencyDoc)
          .set({
        'use_manual': true,
        'manual_rate': rate,
        'manual_rate_date': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ SETTINGS: Taux manuel activé: $rate TND');
    } catch (e) {
      print('❌ SETTINGS ERROR: $e');
      throw e;
    }
  }

  /// Activer le mode API automatique
  Future<void> enableAutoRate() async {
    try {
      await _firestore
          .collection(_settingsDoc)
          .doc(_currencyDoc)
          .set({
        'use_manual': false,
      }, SetOptions(merge: true));

      print('✅ SETTINGS: Mode API automatique activé');
    } catch (e) {
      print('❌ SETTINGS ERROR: $e');
      throw e;
    }
  }

  /// Stream des paramètres (pour écouter les changements en temps réel)
  Stream<Map<String, dynamic>> watchCurrencySettings() {
    return _firestore
        .collection(_settingsDoc)
        .doc(_currencyDoc)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() ?? _getDefaultSettings();
      }
      return _getDefaultSettings();
    });
  }
}