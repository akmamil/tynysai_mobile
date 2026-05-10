// lib/shared/widgets/info_banner.dart
//
// Reusable tinted info banner with an icon, title, and body text.
// Appears on: home page, upload page (tip below the drop zone), result page.
//
// Usage:
//   InfoBanner(
//     icon: Icons.info_outline,
//     title: 'How it works',
//     body: 'Upload a chest X-ray to receive an AI-powered analysis.',
//   )
//
// Variants: InfoBanner.warning, InfoBanner.success, InfoBanner.error

import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

enum InfoBannerVariant { info, warning, success, error }

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.info_outline,
    this.variant = InfoBannerVariant.info,
    this.action,
    this.actionLabel,
  });

  const InfoBanner.warning({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.warning_amber_outlined,
    this.action,
    this.actionLabel,
  }) : variant = InfoBannerVariant.warning;

  const InfoBanner.success({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.check_circle_outline,
    this.action,
    this.actionLabel,
  }) : variant = InfoBannerVariant.success;

  const InfoBanner.error({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.error_outline,
    this.action,
    this.actionLabel,
  }) : variant = InfoBannerVariant.error;

  final String title;
  final String body;
  final IconData icon;
  final InfoBannerVariant variant;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(variant);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: colors.iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.h3.copyWith(
                    fontSize: 13,
                    color: colors.textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(body, style: AppText.bodySm),
                if (action != null && actionLabel != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: action,
                    child: Text(
                      actionLabel!,
                      style: AppText.labelMd.copyWith(
                        color: colors.iconColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _BannerColors _colorsFor(InfoBannerVariant v) => switch (v) {
        InfoBannerVariant.info => const _BannerColors(
            background: Color(0xFFEEF2FF),
            border: Color(0xFFC7D2FE),
            iconBg: Color(0xFFE0E7FF),
            iconColor: AppColors.primary,
            textColor: AppColors.primary,
          ),
        InfoBannerVariant.warning => const _BannerColors(
            background: Color(0xFFFFFBEB),
            border: Color(0xFFFDE68A),
            iconBg: Color(0xFFFEF3C7),
            iconColor: AppColors.warning,
            textColor: Color(0xFF92400E),
          ),
        InfoBannerVariant.success => const _BannerColors(
            background: Color(0xFFECFDF5),
            border: Color(0xFFA7F3D0),
            iconBg: Color(0xFFD1FAE5),
            iconColor: AppColors.success,
            textColor: Color(0xFF065F46),
          ),
        InfoBannerVariant.error => const _BannerColors(
            background: Color(0xFFFEF2F2),
            border: Color(0xFFFECACA),
            iconBg: Color(0xFFFEE2E2),
            iconColor: AppColors.error,
            textColor: Color(0xFF991B1B),
          ),
      };
}

class _BannerColors {
  const _BannerColors({
    required this.background,
    required this.border,
    required this.iconBg,
    required this.iconColor,
    required this.textColor,
  });
  final Color background;
  final Color border;
  final Color iconBg;
  final Color iconColor;
  final Color textColor;
}