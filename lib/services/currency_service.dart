import 'dart:convert';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

class CurrencyService {
  // API gratuite pour taux de change
  static const String _apiUrl = 'https://api.exchangerate-api.com/v4/latest/EUR';
  
  final _settingsService = SettingsService();
  // Cache du taux (pour éviter trop d'appels API)
  static double? _cachedRate;
  static DateTime? _lastFetch;
  
  // Durée de validité du cache: 6 heures (4 requêtes/jour)
  static const Duration _cacheDuration = Duration(hours: 6);

  /// Récupérer le taux EUR → TND
 /// Récupérer le taux EUR → TND
Future<double> getEurToTndRate() async {
  // 1. Vérifier si taux manuel activé
  final settings = await _settingsService.getCurrencySettings();
  final useManual = settings['use_manual'] as bool? ?? false;
  
  if (useManual) {
    final manualRate = (settings['manual_rate'] as num?)?.toDouble() ?? 3.30;
    print('💶 CURRENCY: Mode MANUEL - 1 EUR = $manualRate TND');
    return manualRate;
  }
  
  // 2. Mode automatique - utiliser cache si valide
  if (_cachedRate != null && 
      _lastFetch != null && 
      DateTime.now().difference(_lastFetch!) < _cacheDuration) {
    
    final age = DateTime.now().difference(_lastFetch!);
    final hoursAgo = age.inHours;
    final minutesAgo = age.inMinutes % 60;
    
    print('💶 CURRENCY: Cache utilisé (MAJ il y a ${hoursAgo}h${minutesAgo}min)');
    print('💶 CURRENCY: 1 EUR = $_cachedRate TND');
    return _cachedRate!;
  }

  // 3. Appel API
  try {
    print('💶 CURRENCY: Appel API Exchange Rate...');
    
    final response = await http.get(
      Uri.parse(_apiUrl),
      headers: {'Accept': 'application/json'},
    ).timeout(Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rate = (data['rates']['TND'] as num).toDouble();
      
      _cachedRate = rate;
      _lastFetch = DateTime.now();
      
      print('✅ CURRENCY: 1 EUR = $rate TND (API)');
      print('💶 CURRENCY: Cache valide pour 6h');
      return rate;
    } else {
      throw Exception('API HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('❌ CURRENCY ERROR: $e');
    
    if (_cachedRate != null) {
      print('⚠️ CURRENCY: Utilisation cache expiré: $_cachedRate TND');
      return _cachedRate!;
    }
    
    const fallbackRate = 3.30;
    print('⚠️ CURRENCY: Utilisation taux de secours: $fallbackRate TND');
    return fallbackRate;
  }
}

  /// Convertir EUR → TND
  Future<double> convertEurToTnd(double amountEur) async {
    final rate = await getEurToTndRate();
    return amountEur * rate;
  }

  /// Convertir TND → EUR
  Future<double> convertTndToEur(double amountTnd) async {
    final rate = await getEurToTndRate();
    return amountTnd / rate;
  }

  /// Obtenir infos sur le taux actuel
  Future<Map<String, dynamic>> getCurrentRateInfo() async {
    final rate = await getEurToTndRate();
    
    String lastUpdate = 'Jamais';
    String source = 'Secours';
    
    if (_lastFetch != null) {
      final age = DateTime.now().difference(_lastFetch!);
      
      if (age.inHours > 0) {
        lastUpdate = 'Il y a ${age.inHours}h';
      } else if (age.inMinutes > 0) {
        lastUpdate = 'Il y a ${age.inMinutes} min';
      } else {
        lastUpdate = 'À l\'instant';
      }
      
      if (age < _cacheDuration) {
        source = 'Cache (${6 - age.inHours}h restantes)';
      } else {
        source = 'Cache expiré';
      }
    }
    
    return {
      'rate': rate,
      'rateFormatted': rate.toStringAsFixed(3),
      'lastUpdate': lastUpdate,
      'source': source,
      'cacheValid': _lastFetch != null && 
                    DateTime.now().difference(_lastFetch!) < _cacheDuration,
    };
  }

  /// Forcer le rafraîchissement du taux
  void clearCache() {
    _cachedRate = null;
    _lastFetch = null;
    print('💶 CURRENCY: Cache effacé');
  }

  /// Format d'affichage: "50 EUR (≈ 165 TND)"
  Future<String> formatPrice(double amountEur) async {
    final amountTnd = await convertEurToTnd(amountEur);
    return '${amountEur.toStringAsFixed(0)} EUR (≈ ${amountTnd.toStringAsFixed(0)} TND)';
  }

  /// Format court: "165 TND"
  Future<String> formatPriceShort(double amountEur) async {
    final amountTnd = await convertEurToTnd(amountEur);
    return '${amountTnd.toStringAsFixed(0)} TND';
  }
}