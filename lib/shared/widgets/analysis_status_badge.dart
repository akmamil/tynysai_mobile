// lib/shared/widgets/analysis_status_badge.dart

import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
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
    final cfg = _config(status);
    final fontSize = size == BadgeSize.small ? 10.5 : 12.0;
    final hPad = size == BadgeSize.small ? 7.0 : 9.0;
    final vPad = size == BadgeSize.small ? 3.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: cfg.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.dotColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          cfg.animate
              ? _PulsingDot(color: cfg.dotColor, size: 6)
              : Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: cfg.dotColor, shape: BoxShape.circle),
                ),
          const SizedBox(width: 5),
          Text(
            cfg.label,
            style: TextStyle(
              color: cfg.textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _config(AnalysisStatus status) => switch (status) {
        AnalysisStatus.pending => const _BadgeConfig(
            label: 'Pending',
            background: AppColors.pendingBg,
            textColor: AppColors.pendingText,
            dotColor: AppColors.pendingDot,
            animate: true,
          ),
        AnalysisStatus.processing => const _BadgeConfig(
            label: 'Processing',
            background: AppColors.processingBg,
            textColor: AppColors.processingText,
            dotColor: AppColors.processingDot,
            animate: true,
          ),
        AnalysisStatus.completed => const _BadgeConfig(
            label: 'Completed',
            background: AppColors.completedBg,
            textColor: AppColors.completedText,
            dotColor: AppColors.completedDot,
          ),
        AnalysisStatus.requiresReview => const _BadgeConfig(
            label: 'Review Needed',
            background: AppColors.reviewBg,
            textColor: AppColors.reviewText,
            dotColor: AppColors.reviewDot,
          ),
        AnalysisStatus.validated => const _BadgeConfig(
            label: 'Validated',
            background: AppColors.validatedBg,
            textColor: AppColors.validatedText,
            dotColor: AppColors.validatedDot,
          ),
        AnalysisStatus.failed => const _BadgeConfig(
            label: 'Failed',
            background: AppColors.failedBg,
            textColor: AppColors.failedText,
            dotColor: AppColors.failedDot,
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
  const _PulsingDot({required this.color, required this.size});
  final Color color;
  final double size;

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
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
              color: widget.color, shape: BoxShape.circle),
        ),
      );
}