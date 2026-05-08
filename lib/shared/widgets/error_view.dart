// lib/shared/widgets/error_view.dart

import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.compact = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  /// When true, renders inline (no centering wrapper). Use inside a list tile or card.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 44 : 72,
          height: compact ? 44 : 72,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: compact ? 22 : 36,
            color: Colors.red.shade400,
          ),
        ),
        SizedBox(height: compact ? 10 : 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 13 : 15,
            color: Colors.grey.shade700,
            height: 1.45,
          ),
        ),
        if (onRetry != null) ...[
          SizedBox(height: compact ? 12 : 20),
          SizedBox(
            width: 140,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(retryLabel, style: const TextStyle(fontSize: 14)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (compact) return content;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: content,
      ),
    );
  }
}