// lib/shared/widgets/confidence_bar.dart

import 'package:flutter/material.dart';

/// Displays an AI confidence score (0.0 – 1.0) as a labelled progress bar.
/// Color shifts from red → amber → green based on confidence level.
class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({
    super.key,
    required this.confidence,
    this.label = 'AI Confidence',
    this.showPercentage = true,
  });

  /// Value between 0.0 and 1.0.
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
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            if (showPercentage)
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: confidence.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _levelLabel(confidence),
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _colorFor(double v) {
    if (v >= 0.80) return const Color(0xFF2E7D32); // green
    if (v >= 0.60) return const Color(0xFFF57C00); // amber
    return const Color(0xFFC62828);                // red
  }

  String _levelLabel(double v) {
    if (v >= 0.80) return 'High confidence';
    if (v >= 0.60) return 'Moderate confidence — doctor review recommended';
    return 'Low confidence — manual review required';
  }
}