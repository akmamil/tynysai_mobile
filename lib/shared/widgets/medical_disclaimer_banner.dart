// lib/shared/widgets/medical_disclaimer_banner.dart
//
// A compact, reusable medical disclaimer banner for any screen that surfaces
// AI-generated results or diagnoses.
//
// Two ready-made constructors cover the two contexts in the app:
//
//   • MedicalDisclaimerBanner()          — amber "warning" style used on the
//                                          X-ray AI result screen (AI only,
//                                          no doctor review yet).
//
//   • MedicalDisclaimerBanner.aiAssisted — softer blue "info" style used on
//                                          the Report Detail screen (doctor
//                                          has reviewed, but was AI-assisted).
//
// Both constructors are const and zero-dependency beyond the app theme.
//
// Usage:
//   const MedicalDisclaimerBanner()
//   const MedicalDisclaimerBanner.aiAssisted()
 
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
 
// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────
 
class MedicalDisclaimerBanner extends StatelessWidget {
  /// Amber warning variant — use when showing AI-only results that have
  /// not yet been reviewed or validated by a doctor.
  const MedicalDisclaimerBanner({super.key})
      : _variant = _DisclaimerVariant.warning;
 
  /// Blue info variant — use when a doctor has already reviewed / validated
  /// the result but the workflow was AI-assisted.
  const MedicalDisclaimerBanner.aiAssisted({super.key})
      : _variant = _DisclaimerVariant.info;
 
  final _DisclaimerVariant _variant;
 
  @override
  Widget build(BuildContext context) {
    final cfg = _config(_variant);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cfg.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cfg.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon pill ────────────────────────────────────────────────────
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cfg.iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(cfg.icon, color: cfg.iconColor, size: 17),
          ),
          const SizedBox(width: 11),
          // ── Text block ───────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cfg.title,
                  style: AppText.h3.copyWith(
                    fontSize: 13,
                    color: cfg.titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  cfg.body,
                  style: AppText.bodySm.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  _DisclaimerConfig _config(_DisclaimerVariant v) => switch (v) {
        _DisclaimerVariant.warning => const _DisclaimerConfig(
            background: Color(0xFFFFFBEB),
            border: Color(0xFFFDE68A),
            iconBg: Color(0xFFFEF3C7),
            iconColor: AppColors.warning,
            icon: Icons.health_and_safety_outlined,
            titleColor: Color(0xFF92400E),
            title: 'Not a medical diagnosis',
            body:
                'AI results are for informational purposes only and are not a '
                'substitute for a final medical diagnosis. Please consult a '
                'qualified healthcare professional.',
          ),
        _DisclaimerVariant.info => const _DisclaimerConfig(
            background: Color(0xFFEEF2FF),
            border: Color(0xFFC7D2FE),
            iconBg: Color(0xFFE0E7FF),
            iconColor: AppColors.primary,
            icon: Icons.info_outline_rounded,
            titleColor: AppColors.primary,
            title: 'AI-assisted result',
            body:
                'This report was generated with AI assistance and reviewed by '
                'a licensed physician. Always follow your doctor\'s guidance '
                'for treatment decisions.',
          ),
      };
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────
 
enum _DisclaimerVariant { warning, info }
 
class _DisclaimerConfig {
  const _DisclaimerConfig({
    required this.background,
    required this.border,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.titleColor,
    required this.title,
    required this.body,
  });
 
  final Color background;
  final Color border;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final Color titleColor;
  final String title;
  final String body;
}