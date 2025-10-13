import 'package:flutter/material.dart';
import '../../models/voucher.dart';
import '../custom_text_field.dart';

class EditHeuresDialog extends StatelessWidget {
  final Voucher voucher;
  final heuresController = TextEditingController();

  EditHeuresDialog({required this.voucher}) {
    heuresController.text = voucher.heuresRestantes.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.purple),
          SizedBox(width: 8),
          Text('Modifier les heures'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Code: ${voucher.code}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Heures initiales: ${voucher.heuresInitiales}h',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: heuresController,
            label: 'Nouvelles heures restantes *',
            icon: Icons.access_time,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          Text(
            'Note: Mettre à 0 marquera le voucher comme "utilisé"',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            final heures = int.tryParse(heuresController.text);
            if (heures != null && heures >= 0) {
              Navigator.pop(context, heures);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: Text('Modifier'),
        ),
      ],
    );
  }
}