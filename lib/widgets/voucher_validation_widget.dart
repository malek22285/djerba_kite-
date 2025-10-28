import 'package:flutter/material.dart';
import '../models/voucher.dart';
import '../models/stage.dart';
import '../services/firebase_voucher_service.dart';

class VoucherValidationWidget extends StatefulWidget {
  final Stage stage;
  final TextEditingController controller;
  final Function(Voucher?) onVoucherValidated;

  VoucherValidationWidget({
    required this.stage,
    required this.controller,
    required this.onVoucherValidated,
  });

  @override
  _VoucherValidationWidgetState createState() => _VoucherValidationWidgetState();
}

class _VoucherValidationWidgetState extends State<VoucherValidationWidget> {
  final _voucherService = FirebaseVoucherService();
  
  bool _hasVoucher = false;
  Voucher? _validatedVoucher;
  bool _isValidating = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: _hasVoucher,
          onChanged: (value) {
            setState(() {
              _hasVoucher = value!;
              if (!_hasVoucher) {
                widget.controller.clear();
                _validatedVoucher = null;
                _error = null;
                widget.onVoucherValidated(null);
              }
            });
          },
          title: Text('J\'ai un code voucher'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        
       
          if (_hasVoucher) ...[
  SizedBox(height: 8),
  TextField(
    controller: widget.controller,
    decoration: InputDecoration(
      labelText: 'Code voucher',
      hintText: 'Ex: KITE2025',
      prefixIcon: Icon(Icons.confirmation_number, color: Colors.purple),
      // ← SUPPRIME la ligne suffixIcon
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
    textCapitalization: TextCapitalization.characters,
    onChanged: (_) => _resetValidation(),
  ),
  
  SizedBox(height: 8),
  
  // ← AJOUTE LE BOUTON ICI
  ValueListenableBuilder<TextEditingValue>(
    valueListenable: widget.controller,
    builder: (context, value, child) {
      final hasText = value.text.trim().isNotEmpty;
      
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: !hasText || _isValidating
              ? null
              : _validateVoucher,
          icon: _isValidating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.check_circle_outline),
          label: Text(_isValidating ? 'Vérification...' : 'Vérifier le code'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[400],
            disabledForegroundColor: Colors.grey[600],
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    },
  ),
  
  // Après continuent les box d'erreur et de succès...
          
          
          if (_error != null) _buildErrorBox(),
          if (_validatedVoucher != null) _buildSuccessBox(),
        ],
      ],
    );
  }

  Widget _buildSuffixIcon() {
    if (_isValidating) {
      return Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_validatedVoucher != null) {
      return Icon(Icons.check_circle, color: Colors.green);
    }
    if (_error != null) {
      return Icon(Icons.error, color: Colors.red);
    }
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: _validateVoucher,
    );
  }

  Widget _buildErrorBox() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red[900], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBox() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voucher valide: ${_validatedVoucher!.code}',
                  style: TextStyle(
                    color: Colors.green[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_validatedVoucher!.heuresRestantes}h disponibles',
                  style: TextStyle(color: Colors.green[800], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resetValidation() {
    if (_validatedVoucher != null || _error != null) {
      setState(() {
        _validatedVoucher = null;
        _error = null;
        widget.onVoucherValidated(null);
      });
    }
  }

  Future<void> _validateVoucher() async {
    final code = widget.controller.text.trim();
    
    if (code.isEmpty) {
      _resetValidation();
      return;
    }

    setState(() {
      _isValidating = true;
      _error = null;
    });

    try {
      final voucher = await _voucherService.validateVoucherCode(code);

      if (!mounted) return;

      if (voucher == null) {
        setState(() {
          _validatedVoucher = null;
          _error = 'Code voucher introuvable';
          _isValidating = false;
        });
        widget.onVoucherValidated(null);
        return;
      }

      // Vérifier validité
      if (!voucher.isValid) {
        String error;
        if (voucher.isExpired) {
          error = 'Expiré le ${voucher.dateExpiration.day}/${voucher.dateExpiration.month}/${voucher.dateExpiration.year}';
        } else if (voucher.isExhausted) {
          error = 'Plus d\'heures disponibles';
        } else if (!voucher.actif) {
          error = 'Voucher désactivé';
        } else {
          error = 'Voucher non valide';
        }
        
        setState(() {
          _validatedVoucher = null;
          _error = error;
          _isValidating = false;
        });
        widget.onVoucherValidated(null);
        return;
      }

      // Vérifier heures suffisantes
      if (voucher.heuresRestantes < widget.stage.duree) {
        setState(() {
          _validatedVoucher = null;
          _error = 'Heures insuffisantes (${voucher.heuresRestantes}h disponibles, ${widget.stage.duree}h nécessaires)';
          _isValidating = false;
        });
        widget.onVoucherValidated(null);
        return;
      }

      // Voucher valide!
      setState(() {
        _validatedVoucher = voucher;
        _error = null;
        _isValidating = false;
      });
      print('🔵 WIDGET: Voucher validé, appel callback');
print('🔵 WIDGET: voucher.id = ${voucher.id}');
print('🔵 WIDGET: voucher.code = ${voucher.code}');
      widget.onVoucherValidated(voucher);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Voucher valide: ${voucher.heuresRestantes}h disponibles'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _validatedVoucher = null;
        _error = 'Erreur validation';
        _isValidating = false;
      });
      widget.onVoucherValidated(null);
    }
  }
}