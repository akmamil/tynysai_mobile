// lib/shared/widgets/step_indicator.dart
//
// Reusable numbered step widget.
// Previously existed as a private _Step class inside upload_xray_page.dart.
// Extracted here so it can be reused on any page that needs to explain
// a multi-step process (upload flow, onboarding, appointments, etc.).
//
// Usage:
//   Row(children: [
//     StepIndicator(number: 1, label: 'Upload', sub: 'JPG or PNG'),
//     StepIndicator(number: 2, label: 'AI Analyzes', sub: 'Neural network'),
//     StepIndicator(number: 3, label: 'Get Result', sub: 'Diagnosis'),
//   ])

import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.number,
    required this.label,
    required this.sub,
  });

  final int number;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: AppGradients.brand,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppText.h3.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: AppText.bodyXs,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}