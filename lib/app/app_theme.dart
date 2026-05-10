import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppColors {
  // Brand
  static const primary   = Color(0xFF4664E0); // brand.blue
  static const teal      = Color(0xFF1CBEAF); // brand.teal
  static const navy      = Color(0xFF0C1A2E); // brand.navy (login bg)
  static const navyLight = Color(0xFF122236);

  // Surfaces
  static const background = Color(0xFFF8FAFF); // slightly blue-tinted gray-50
  static const surface    = Colors.white;
  static const border     = Color(0xFFE5E7EB); // gray-200
  static const divider    = Color(0xFFF3F4F6); // gray-100

  // Text
  static const textPrimary   = Color(0xFF111827); // gray-900
  static const textSecondary = Color(0xFF6B7280); // gray-500
  static const textTertiary  = Color(0xFF9CA3AF); // gray-400
  static const textOnDark    = Colors.white;

  // Semantic
  static const success = Color(0xFF059669); // emerald-600
  static const warning = Color(0xFFF59E0B); // amber-500
  static const error   = Color(0xFFDC2626); // red-600
  static const info    = Color(0xFF3B82F6); // blue-500

  // Status badge backgrounds (subtle)
  static const pendingBg    = Color(0xFFFFFBEB);
  static const pendingText  = Color(0xFF92400E);
  static const pendingDot   = Color(0xFFF59E0B);
  static const processingBg   = Color(0xFFEFF6FF);
  static const processingText = Color(0xFF1D4ED8);
  static const processingDot  = Color(0xFF3B82F6);
  static const completedBg   = Color(0xFFECFDF5);
  static const completedText = Color(0xFF065F46);
  static const completedDot  = Color(0xFF059669);
  static const reviewBg   = Color(0xFFFFF7ED);
  static const reviewText = Color(0xFF9A3412);
  static const reviewDot  = Color(0xFFF97316);
  static const validatedBg   = Color(0xFFECFDF5);
  static const validatedText = Color(0xFF14532D);
  static const validatedDot  = Color(0xFF16A34A);
  static const failedBg   = Color(0xFFFEF2F2);
  static const failedText = Color(0xFF991B1B);
  static const failedDot  = Color(0xFFDC2626);
}

abstract final class AppGradients {
  static const brand = LinearGradient(
    colors: [AppColors.primary, AppColors.teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const navy = LinearGradient(
    colors: [AppColors.navy, AppColors.navyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const surfaceTint = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFE0F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract final class AppText {
  // Display
  static const displayLg = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2);
  static const displayMd = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25);

  // Headings
  static const h1 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const h2 = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const h3 = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  // Body
  static const bodyLg   = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5);
  static const bodyMd   = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5);
  static const bodySm   = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.4);
  static const bodyXs   = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary);

  // Labels
  static const labelLg = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.4);
  static const labelMd = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.3);
  static const labelSm = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.2);

  // On-dark (for gradient surfaces)
  static const onDark       = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white);
  static const onDarkMuted  = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xB3FFFFFF)); // white 70%
  static const onDarkBold   = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white);
}

// ─────────────────────────────────────────────────────────────────────────────
// DECORATIONS  (reusable BoxDecoration presets)
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppDecorations {
  /// Standard white card with border + subtle shadow. Matches web's Card.tsx.
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.border),
    boxShadow: const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  /// Gradient card — for hero/CTA elements.
  static BoxDecoration get gradientCard => BoxDecoration(
    gradient: AppGradients.brand,
    borderRadius: BorderRadius.circular(14),
    boxShadow: const [
      BoxShadow(color: Color(0x334664E0), blurRadius: 16, offset: Offset(0, 4)),
    ],
  );

  /// Dashed border container — for file drop zones.
  static BoxDecoration dashedBox({Color? borderColor}) => BoxDecoration(
    color: const Color(0xFFF0F4FF),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: borderColor ?? AppColors.primary.withValues(alpha: 0.4),
      // Note: Flutter doesn't support CSS dashed borders natively.
      // We simulate with a DashedBorder widget or use a solid light border.
    ),
  );

  /// Outlined section — for form sections.
  static BoxDecoration get section => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
  );
}

abstract final class AppSpacing {
  static const xs  =  4.0;
  static const sm  =  8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;

  static const pagePadding = EdgeInsets.all(16);
  static const cardPadding = EdgeInsets.all(16);
  static const sectionGap  = SizedBox(height: 16);
  static const itemGap     = SizedBox(height: 10);
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.teal,
    surface: AppColors.surface,
    error: AppColors.error,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: base,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'SF Pro Display', // Falls back to system font on Android

    // ── AppBar ──────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.h2,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.border,
      scrolledUnderElevation: 1,
    ),

    // ── Cards ────────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),

    // ── Input fields ─────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: AppText.bodyMd.copyWith(color: AppColors.textSecondary),
      hintStyle: AppText.bodyMd.copyWith(color: AppColors.textTertiary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
    ),

    // ── Elevated buttons ─────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white70,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // ── Outlined buttons ─────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // ── Floating action buttons ───────────────────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: StadiumBorder(),
    ),

    // ── Chips ────────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: AppText.bodySm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    ),

    // ── Divider ──────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),

    // ── SnackBar ─────────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.navy,
      contentTextStyle: AppText.bodyMd.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    // ── Bottom sheet ─────────────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // ── Progress indicator ───────────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
  );
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 52.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null || isLoading
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.teal.withValues(alpha: 0.5),
                  ],
                )
              : AppGradients.brand,
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed == null || isLoading
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x404664E0),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  )
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding ?? AppSpacing.cardPadding,
      decoration: AppDecorations.card,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text.toUpperCase(),
        style: AppText.labelMd.copyWith(color: AppColors.primary),
      ),
    );
  }
}