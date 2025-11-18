import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class CurrencyPriceDisplay extends StatefulWidget {
  final double? prixEur;
  final double? prixTnd;
  final TextStyle? style;
  final bool showBothCurrencies;
  final bool bold;

  const CurrencyPriceDisplay({
    Key? key,
    this.prixEur,
    this.prixTnd,
    this.style,
    this.showBothCurrencies = true,
    this.bold = false,
  }) : super(key: key);

  @override
  State<CurrencyPriceDisplay> createState() => _CurrencyPriceDisplayState();
}

class _CurrencyPriceDisplayState extends State<CurrencyPriceDisplay> {
  final _currencyService = CurrencyService();
  double? _tauxChange;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTaux();
  }

  Future<void> _loadTaux() async {
    try {
      final taux = await _currencyService.getEurToTndRate();
      if (mounted) {
        setState(() {
          _tauxChange = taux;
          _loading = false;
        });
      }
    } catch (e) {
      print('❌ CURRENCY DISPLAY ERROR: $e');
      if (mounted) {
        setState(() {
          _tauxChange = 3.30; // Fallback
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Text(
        'Chargement...',
        style: widget.style,
      );
    }

    // Calculer les deux prix
    double eur = 0;
    double tnd = 0;

    if (widget.prixEur != null) {
      eur = widget.prixEur!;
      tnd = eur * (_tauxChange ?? 3.30);
    } else if (widget.prixTnd != null) {
      tnd = widget.prixTnd!;
      eur = tnd / (_tauxChange ?? 3.30);
    }

    // Affichage
    if (widget.showBothCurrencies) {
      return Text(
        '${tnd.toStringAsFixed(0)} TND (≈ ${eur.toStringAsFixed(0)} EUR)',
        style: widget.style?.copyWith(
          fontWeight: widget.bold ? FontWeight.bold : null,
        ),
      );
    } else {
      // Afficher seulement TND
      return Text(
        '${tnd.toStringAsFixed(0)} TND',
        style: widget.style?.copyWith(
          fontWeight: widget.bold ? FontWeight.bold : null,
        ),
      );
    }
  }
}

/// Version compacte pour les cards
class CompactPriceDisplay extends StatelessWidget {
  final double? prixEur;
  final double? prixTnd;
  final Color? color;
  final double fontSize;

  const CompactPriceDisplay({
    Key? key,
    this.prixEur,
    this.prixTnd,
    this.color,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurrencyPriceDisplay(
      prixEur: prixEur,
      prixTnd: prixTnd,
      showBothCurrencies: true,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.black87,
      ),
    );
  }
}

/// Version pour affichage grand (ex: détails stage)
class LargePriceDisplay extends StatelessWidget {
  final double? prixEur;
  final double? prixTnd;

  const LargePriceDisplay({
    Key? key,
    this.prixEur,
    this.prixTnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurrencyPriceDisplay(
      prixEur: prixEur,
      prixTnd: prixTnd,
      showBothCurrencies: true,
      bold: true,
      style: TextStyle(
        fontSize: 24,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}