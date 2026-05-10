// lib/shared/widgets/confidence_bar.dart

import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({
    super.key,
    required this.confidence,
    this.label = 'AI Confidence',
    this.showPercentage = true,
  });

  final double confidence;
  final String label;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final pct = (confidence.clamp(0.0, 1.0) * 100).round();
    final color = _colorFor(confidence);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.bodySm),
            if (showPercentage)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: confidence.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(_levelLabel(confidence), style: AppText.labelSm.copyWith(color: color)),
      ],
    );
  }

  Color _colorFor(double v) {
    if (v >= 0.80) return AppColors.success;
    if (v >= 0.60) return AppColors.warning;
    return AppColors.error;
  }

  String _levelLabel(double v) {
    if (v >= 0.80) return 'High confidence';
    if (v >= 0.60) return 'Moderate — doctor review recommended';
    return 'Low confidence — manual review required';
  }
}