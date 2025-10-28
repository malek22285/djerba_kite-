import 'package:flutter/material.dart';
import '../../../services/firebase_voucher_service.dart';
import '../../../models/voucher.dart';
import '../../../widgets/admin/voucher_card.dart';
import '../../../widgets/admin/voucher_form_dialog.dart';
import '../../../widgets/empty_state.dart';

class VouchersTab extends StatefulWidget {
  @override
  _VouchersTabState createState() => _VouchersTabState();
}

class _VouchersTabState extends State<VouchersTab> {
  final _voucherService = FirebaseVoucherService();
  String _selectedFilter = 'tous';

  List<Voucher> _filterVouchers(List<Voucher> vouchers) {
    switch (_selectedFilter) {
      case 'actifs':
        return vouchers.where((v) => v.actif && !v.isExpired && v.heuresRestantes > 0).toList();
      case 'expires':
        return vouchers.where((v) => v.isExpired).toList();
      case 'epuises':
        return vouchers.where((v) => v.heuresRestantes <= 0).toList();
      case 'inactifs':
        return vouchers.where((v) => !v.actif).toList();
      default:
        return vouchers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<Voucher>>(
              stream: _voucherService.getAllVouchers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Erreur de chargement'),
                      ],
                    ),
                  );
                }

                final allVouchers = snapshot.data ?? [];
                final filteredVouchers = _filterVouchers(allVouchers);

                if (filteredVouchers.isEmpty) {
                  return EmptyState(
                    icon: Icons.confirmation_number_outlined,
                    title: _selectedFilter == 'tous' 
                        ? 'Aucun voucher'
                        : 'Aucun voucher $_selectedFilter',
                    subtitle: 'Créez votre premier voucher',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredVouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = filteredVouchers[index];
                      return VoucherCard(
                        voucher: voucher,
                        onTap: () => _showDetails(voucher),
                        onEdit: () => _editHeures(voucher),
                        onToggle: () => _toggleStatus(voucher),
                        onDelete: () => _deleteVoucher(voucher),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createVoucher,
        backgroundColor: Colors.purple,
        icon: Icon(Icons.add),
        label: Text('Nouveau voucher'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vouchers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tous', 'tous'),
                SizedBox(width: 8),
                _buildFilterChip('Actifs', 'actifs'),
                SizedBox(width: 8),
                _buildFilterChip('Expirés', 'expires'),
                SizedBox(width: 8),
                _buildFilterChip('Épuisés', 'epuises'),
                SizedBox(width: 8),
                _buildFilterChip('Inactifs', 'inactifs'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      selectedColor: Colors.purple[100],
      checkmarkColor: Colors.purple,
    );
  }

  Future<void> _createVoucher() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => VoucherFormDialog(),
    );
    
    if (result == null) return;

    try {
      await _voucherService.createVoucher(
        code: result['code'],
        heures: result['heures'],
        dateExpiration: result['dateExpiration'],
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ Voucher créé'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editHeures(Voucher voucher) async {
    final controller = TextEditingController(
      text: voucher.heuresRestantes.toString(),
    );

    final heures = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Modifier les heures'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Code: ${voucher.code}'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nouvelles heures restantes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Modifier'),
          ),
        ],
      ),
    );

    if (heures == null) return;

    try {
      await _voucherService.updateVoucherHeures(voucher.id, heures);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ Heures modifiées'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleStatus(Voucher voucher) async {
    try {
      await _voucherService.toggleVoucherStatus(voucher.id, !voucher.actif);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(voucher.actif ? '✓ Voucher désactivé' : '✓ Voucher activé'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteVoucher(Voucher voucher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('⚠️ Supprimer le voucher'),
        content: Text(
          'Voulez-vous vraiment supprimer le voucher "${voucher.code}"?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _voucherService.deleteVoucher(voucher.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ Voucher supprimé'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDetails(Voucher voucher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.confirmation_number, color: Colors.purple),
            SizedBox(width: 8),
            Expanded(child: Text(voucher.code)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Heures totales', '${voucher.heuresTotales}h'),
            _buildDetailRow('Heures restantes', '${voucher.heuresRestantes}h'),
            _buildDetailRow(
              'Expiration',
              '${voucher.dateExpiration.day}/${voucher.dateExpiration.month}/${voucher.dateExpiration.year}',
            ),
            _buildDetailRow('Statut', voucher.actif ? 'Actif' : 'Inactif'),
            _buildDetailRow(
              'État',
              voucher.isExpired
                  ? 'Expiré'
                  : voucher.isExhausted
                      ? 'Épuisé'
                      : 'Valide',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}