// lib/shared/widgets/analysis_status_badge.dart

import 'package:flutter/material.dart';

// Relative path from lib/shared/widgets/ to lib/core/models/
import '../../core/models/enums.dart';

class AnalysisStatusBadge extends StatelessWidget {
  const AnalysisStatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.medium,
  });

  final AnalysisStatus status;
  final BadgeSize size;

  @override
  Widget build(BuildContext context) {
    final config = _configFor(status);
    final fontSize = size == BadgeSize.small ? 11.0 : 12.5;
    final hPad = size == BadgeSize.small ? 8.0 : 10.0;
    final vPad = size == BadgeSize.small ? 3.0 : 5.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.animate)
            _PulsingDot(color: config.dotColor)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: config.dotColor,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _configFor(AnalysisStatus status) => switch (status) {
        AnalysisStatus.pending => _BadgeConfig(
            label: 'Pending',
            background: Colors.amber.shade50,
            textColor: Colors.amber.shade800,
            dotColor: Colors.amber.shade600,
            animate: true,
          ),
        AnalysisStatus.processing => _BadgeConfig(
            label: 'Processing',
            background: Colors.blue.shade50,
            textColor: Colors.blue.shade800,
            dotColor: Colors.blue.shade600,
            animate: true,
          ),
        AnalysisStatus.completed => _BadgeConfig(
            label: 'Completed',
            background: Colors.green.shade50,
            textColor: Colors.green.shade800,
            dotColor: Colors.green.shade600,
          ),
        AnalysisStatus.requiresReview => _BadgeConfig(
            label: 'Review Needed',
            background: Colors.orange.shade50,
            textColor: Colors.orange.shade800,
            dotColor: Colors.orange.shade600,
          ),
        AnalysisStatus.validated => _BadgeConfig(
            label: 'Validated',
            background: const Color(0xFFE8F5E9),
            textColor: const Color(0xFF2E7D32),
            dotColor: const Color(0xFF43A047),
          ),
        AnalysisStatus.failed => _BadgeConfig(
            label: 'Failed',
            background: Colors.red.shade50,
            textColor: Colors.red.shade800,
            dotColor: Colors.red.shade600,
          ),
      };
}

enum BadgeSize { small, medium }

class _BadgeConfig {
  const _BadgeConfig({
    required this.label,
    required this.background,
    required this.textColor,
    required this.dotColor,
    this.animate = false,
  });

  final String label;
  final Color background;
  final Color textColor;
  final Color dotColor;
  final bool animate;
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}