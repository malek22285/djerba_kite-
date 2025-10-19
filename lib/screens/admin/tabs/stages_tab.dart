import 'package:flutter/material.dart';
//import '../../../services/stage_service.dart';
import '../../../services/firebase_stage_service.dart';
import '../../../models/stage.dart';
import '../../../widgets/admin/admin_stage_card.dart';
import '../../../widgets/admin/stage_form_dialog.dart';
import '../../../widgets/admin/stages_header.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/confirmation_dialog.dart';

class StagesTab extends StatefulWidget {
  @override
  _StagesTabState createState() => _StagesTabState();
}

class _StagesTabState extends State<StagesTab> {
  final _stageService = FirebaseStageService();
  List<Stage> _stages = [];
  bool _isLoading = true;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadStages();
  }

Future<void> _loadStages() async {
  print('🔵 ADMIN: Début chargement stages...');
  setState(() => _isLoading = true);
  
  try {
    print('🔵 ADMIN: Appel getAllStagesForAdmin()...');
    final stages = await _stageService.getAllStagesForAdmin();
    print('✅ ADMIN: Stages récupérés: ${stages.length}');
    
    for (var stage in stages) {
      print('  - ${stage.nom} (actif: ${stage.actif})');
    }
    
    setState(() {
      _stages = stages;
      _isLoading = false;
    });
    print('✅ ADMIN: setState terminé, affichage: ${_stages.length} stages');
  } catch (e, stackTrace) {
    print('❌ ADMIN ERREUR: $e');
    print('Stack: $stackTrace');
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final displayedStages = _showInactive
        ? _stages
        : _stages.where((s) => s.actif).toList();

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                StagesHeader(
                  showInactive: _showInactive,
                  onToggle: (value) => setState(() => _showInactive = value),
                ),
                Expanded(
                  child: displayedStages.isEmpty
                      ? EmptyState(
                          icon: Icons.water_drop_outlined,
                          title: 'Aucun stage',
                          subtitle: 'Créez votre premier stage',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadStages,
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedStages.length,
                            itemBuilder: (context, index) {
                              return AdminStageCard(
                                stage: displayedStages[index],
                                onEdit: () => _handleEdit(displayedStages[index]),
                                onDelete: () => _handleDelete(displayedStages[index]),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreate,
        backgroundColor: Color(0xFF2a5298),
        icon: Icon(Icons.add),
        label: Text('Nouveau stage'),
      ),
    );
  }

  Future<void> _handleCreate() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StageFormDialog(),
    );
    if (result == null) return;

    await _stageService.createStage(
      nom: result['nom'],
      description: result['description'],
      duree: result['duree'],
      prixTnd: result['prix'],
      niveauRequis: result['niveau'],
      remisePourcentage: (result['remise'] as num).toInt(),
    );

    _showSuccess('Stage créé');
    _loadStages();
  }

  Future<void> _handleEdit(Stage stage) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StageFormDialog(stage: stage),
    );
    if (result == null) return;

    await _stageService.updateStage(
      id: stage.id,
      nom: result['nom'],
      description: result['description'],
      duree: result['duree'],
      prixTnd: result['prix'],
      niveauRequis: result['niveau'],
      remisePourcentage: (result['remise'] as num).toInt(),
      actif: stage.actif,
    );

    _showSuccess('Stage modifié');
    _loadStages();
  }

  Future<void> _handleDelete(Stage stage) async {
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: '${stage.actif ? "Désactiver" : "Réactiver"} ce stage ?',
      content: stage.actif
          ? 'Le stage ne sera plus visible pour les clients.'
          : 'Le stage redeviendra visible pour les clients.',
      actionText: stage.actif ? 'Désactiver' : 'Réactiver',
      actionColor: stage.actif ? Colors.red : Colors.green,
    );

    if (confirm != true) return;

    if (stage.actif) {
      await _stageService.deleteStage(stage.id);
    } else {
      await _stageService.updateStage(
        id: stage.id,
        nom: stage.nom,
        description: stage.description,
        duree: stage.duree,
        prixTnd: stage.prixTnd,
        niveauRequis: stage.niveauRequis,
        remisePourcentage: stage.remisePourcentage,
        actif: true,
      );
    }

    _showSuccess(stage.actif ? 'Stage désactivé' : 'Stage réactivé');
    _loadStages();
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✓ $message'), backgroundColor: Colors.green),
    );
  }
}