import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class VoucherSection extends StatelessWidget {
  final bool hasVoucher;
  final ValueChanged<bool?> onChanged;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  VoucherSection({
    required this.hasVoucher,
    required this.onChanged,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => onChanged(!hasVoucher),
            child: Row(
              children: [
                Checkbox(
                  value: hasVoucher,
                  onChanged: onChanged,
                  activeColor: Color(0xFF2a5298),
                ),
                Expanded(
                  child: Text(
                    'J\'ai un voucher',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Animation pour montrer/cacher le champ
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: hasVoucher
                ? Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: CustomTextField(
                      controller: controller,
                      label: 'Code voucher',
                      icon: Icons.confirmation_number,
                      validator: validator,
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}