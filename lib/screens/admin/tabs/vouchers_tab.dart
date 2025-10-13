import 'package:flutter/material.dart';
import '../../../services/voucher_service.dart';
import '../../../models/voucher.dart';
import '../../../widgets/admin/vouchers_header.dart';
import '../../../widgets/admin/voucher_card.dart';
import '../../../widgets/admin/voucher_form_dialog.dart';
import '../../../widgets/admin/edit_heures_dialog.dart';
import '../../../widgets/admin/voucher_details_dialog.dart';
import '../../../widgets/empty_state.dart';

class VouchersTab extends StatefulWidget {
  @override
  _VouchersTabState createState() => _VouchersTabState();
}

class _VouchersTabState extends State<VouchersTab> {
  final _voucherService = VoucherService();
  List<Voucher> _vouchers = [];
  String _selectedFilter = 'tous';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoading = true);
    await _voucherService.checkExpirations();
    final vouchers = await _voucherService.getAllVouchers();
    setState(() {
      _vouchers = vouchers;
      _isLoading = false;
    });
  }

  List<Voucher> get _filteredVouchers {
    if (_selectedFilter == 'tous') return _vouchers;
    return _vouchers.where((v) => v.statut == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          VouchersHeader(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
            totalCount: _filteredVouchers.length,
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredVouchers.isEmpty
                    ? EmptyState(
                        icon: Icons.confirmation_number_outlined,
                        title: 'Aucun voucher',
                        subtitle: 'Créez votre premier voucher',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadVouchers,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredVouchers.length,
                          itemBuilder: (context, index) {
                            return VoucherCard(
                              voucher: _filteredVouchers[index],
                              onTap: () => _showDetails(_filteredVouchers[index]),
                              onEdit: () => _editHeures(_filteredVouchers[index]),
                            );
                          },
                        ),
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
        stageType: result['stageType'],
        clientAssigne: result['clientAssigne'],
        dateExpiration: result['dateExpiration'],
        notes: result['notes'],
      );

      _showSuccess('Voucher créé');
      _loadVouchers();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _editHeures(Voucher voucher) async {
    final heures = await showDialog<int>(
      context: context,
      builder: (context) => EditHeuresDialog(voucher: voucher),
    );
    if (heures == null) return;

    try {
      await _voucherService.updateHeures(
        voucherId: voucher.id,
        nouvellesHeures: heures,
      );

      _showSuccess('Heures modifiées');
      _loadVouchers();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showDetails(Voucher voucher) {
    showDialog(
      context: context,
      builder: (context) => VoucherDetailsDialog(voucher: voucher),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✓ $message'), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceAll('Exception: ', '')),
        backgroundColor: Colors.red,
      ),
    );
  }
}