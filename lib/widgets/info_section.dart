import 'package:flutter/material.dart';

class InfoSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  InfoSection({
    required this.title,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: child,
        ),
      ],
    );
  }
}