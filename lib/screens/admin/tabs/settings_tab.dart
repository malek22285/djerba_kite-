import 'package:flutter/material.dart';
import '../../../services/currency_service.dart';
import '../../../services/settings_service.dart';

class SettingsTab extends StatefulWidget {
  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _currencyService = CurrencyService();
  final _settingsService = SettingsService();
  
  bool _useManual = false;
  double _manualRate = 3.30;
  double? _apiRate;
  String _lastUpdate = 'Chargement...';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    
    try {
      // Charger settings
      final settings = await _settingsService.getCurrencySettings();
      
      // Charger taux API
      final info = await _currencyService.getCurrentRateInfo();
      
      if (mounted) {
        setState(() {
          _useManual = settings['use_manual'] as bool? ?? false;
          _manualRate = (settings['manual_rate'] as num?)?.toDouble() ?? 3.30;
          _apiRate = info['rate'] as double?;
          _lastUpdate = info['lastUpdate'] as String? ?? 'Inconnu';
          _loading = false;
        });
      }
    } catch (e) {
      print('❌ SETTINGS TAB ERROR: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrencyCard(),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard() {
    final currentRate = _useManual ? _manualRate : (_apiRate ?? 3.30);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.euro, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  'Gestion des devises',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Taux actuel
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taux actuel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1 EUR = ${currentRate.toStringAsFixed(3)} TND',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  if (!_useManual) ...[
                    SizedBox(height: 4),
                    Text(
                      'Dernière MAJ: $_lastUpdate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24),
            
            Divider(),
            SizedBox(height: 16),
            
            // Mode de taux
            Text(
              'Mode de taux',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Option API automatique
            _buildModeOption(
              title: 'API automatique',
              subtitle: 'Mise à jour toutes les 6 heures',
              icon: Icons.cloud_sync,
              isSelected: !_useManual,
              onTap: () => _switchToAutoMode(),
            ),
            SizedBox(height: 12),
            
            // Option Manuel
            _buildModeOption(
              title: 'Taux manuel',
              subtitle: _useManual 
                  ? '1 EUR = ${_manualRate.toStringAsFixed(3)} TND'
                  : 'Définir un taux fixe',
              icon: Icons.edit,
              isSelected: _useManual,
              onTap: () => _showManualRateDialog(),
              trailing: _useManual
                  ? IconButton(
                      icon: Icon(Icons.edit, size: 20),
                      onPressed: _showManualRateDialog,
                    )
                  : null,
            ),
            
            if (!_useManual) ...[
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _refreshRate, // Maintenant défini
                  icon: Icon(Icons.refresh),
                  label: Text('Rafraîchir le taux maintenant'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue[50] : Colors.white,
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: Colors.blue,
            ),
            SizedBox(width: 12),
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey[600]),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue[900] : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Future<void> _switchToAutoMode() async {
    try {
      await _settingsService.enableAutoRate();
      _currencyService.clearCache(); // Force refresh
      await _loadSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Mode API automatique activé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showManualRateDialog() async {
    final controller = TextEditingController(
      text: _manualRate.toStringAsFixed(3),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Taux manuel', style: TextStyle(fontSize: 18)),
        content: SingleChildScrollView( 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Définir le taux EUR → TND', style: TextStyle(fontSize: 14)),
              SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '1 EUR =',
                  suffixText: 'TND',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                autofocus: true,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ce taux sera utilisé jusqu\'à réactivation de l\'API',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[900],
                          height: 1.2,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final rate = double.tryParse(controller.text);
              if (rate != null && rate > 0) {
                Navigator.pop(context, rate);
              }
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _settingsService.setManualRate(result);
        await _loadSettings();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Taux enregistré: ${result.toStringAsFixed(3)} TND'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // Implementation de _refreshRate qui manquait
  Future<void> _refreshRate() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rafraîchissement du taux...')),
      );
    }
    
    // On force le rechargement des paramètres et du taux API
    await _loadSettings(); 
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Taux mis à jour'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}