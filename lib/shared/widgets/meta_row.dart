// lib/shared/widgets/meta_row.dart
//
// Reusable row of icon + text metadata chips.
// Used in: history card (date, size), result page (upload date, doctor name),
//          reports page (date, doctor, severity), lab results page (test type, date).
//
// Usage — single item:
//   MetaItem(icon: Icons.schedule_outlined, text: '2024-01-15 09:30')
//
// Usage — row of items:
//   MetaRow(items: [
//     MetaItem(icon: Icons.schedule_outlined, text: '2024-01-15'),
//     MetaItem(icon: Icons.person_outline, text: 'Dr. Seitkali'),
//   ])

import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class MetaRow extends StatelessWidget {
  const MetaRow({super.key, required this.items});
  final List<MetaItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: items,
    );
  }
}

class MetaItem extends StatelessWidget {
  const MetaItem({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: c),
        const SizedBox(width: 3),
        Text(text, style: AppText.bodyXs.copyWith(color: c)),
      ],
    );
  }
}