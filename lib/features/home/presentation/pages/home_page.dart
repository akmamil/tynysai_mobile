import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/models/enums.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    S.setLocale(AppLocale.values.firstWhere(
          (e) => e.name == locale.languageCode,
      orElse: () => AppLocale.ru,
    ));

    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final firstName = user?.fullName.split(' ').first ?? '';
    final role = user?.role ?? UserRole.patient;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white),
              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/logo.png', fit: BoxFit.contain)),
            ),
            const SizedBox(width: 10),
            const Text('TynysAI'),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.primary),
            ),
            tooltip: S.notifications,
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'logout') ref.read(authProvider.notifier).logout();
              if (v == 'profile') context.push('/profile');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36, height: 36,
              decoration: BoxDecoration(gradient: AppGradients.brand, borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(
                  (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(children: [
                  const Icon(Icons.person_outline, size: 18),
                  const SizedBox(width: 10),
                  Text(user?.fullName ?? S.profile, style: AppText.bodyMd),
                ]),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  const Icon(Icons.logout_outlined, size: 18, color: AppColors.error),
                  const SizedBox(width: 10),
                  Text(S.signOut, style: const TextStyle(color: AppColors.error, fontSize: 14)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.gradientCard,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.goodDay, style: AppText.onDarkMuted),
                        const SizedBox(height: 2),
                        Text(firstName.isEmpty ? role.displayName : firstName, style: AppText.onDarkBold),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
                          child: Text(role.displayName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: Icon(_roleIcon(role), color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(S.quickActions, style: AppText.h3),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.20,
              children: _buildCards(context, role),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => context.push('/notifications'),
              child: Container(
                decoration: AppDecorations.card,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.notifications_outlined, color: AppColors.warning, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.notifications, style: AppText.h3.copyWith(fontSize: 14)),
                          const SizedBox(height: 1),
                          Text(S.notificationsSubtitle, style: AppText.labelSm),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.howItWorks, style: AppText.h3.copyWith(color: AppColors.primary)),
                        const SizedBox(height: 3),
                        Text(_infoBannerText(role), style: AppText.bodySm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.patient:
        return [
          _NavCard(icon: Icons.upload_file_outlined, label: S.uploadXray, subtitle: S.uploadXraySubtitle, color: AppColors.primary, onTap: () => context.push('/xray/upload')),
          _NavCard(icon: Icons.history_outlined, label: S.myXrays, subtitle: S.viewHistory, color: AppColors.teal, onTap: () => context.push('/history')),
          _NavCard(icon: Icons.description_outlined, label: S.reports, subtitle: S.reportsSubtitle, color: const Color(0xFF7C3AED), onTap: () => context.push('/reports')),
          _NavCard(icon: Icons.calendar_today_outlined, label: S.appointments, subtitle: S.appointmentsSubtitle, color: const Color(0xFF0EA5E9), onTap: () => context.push('/appointments')),
          _NavCard(icon: Icons.science_outlined, label: S.labResults, subtitle: S.labResultsSubtitle, color: const Color(0xFF0891B2), onTap: () => context.push('/lab-results')),
          _NavCard(icon: Icons.person_outline, label: S.profile, subtitle: S.profileSubtitle, color: AppColors.success, onTap: () => context.push('/profile')),
        ];
      case UserRole.doctor:
        return [
          _NavCard(icon: Icons.image_search_outlined, label: S.myXrays, subtitle: 'Assigned scans', color: AppColors.primary, onTap: () => context.push('/history')),
          _NavCard(icon: Icons.description_outlined, label: S.reports, subtitle: S.reportsSubtitle, color: const Color(0xFF7C3AED), onTap: () => context.push('/reports')),
          _NavCard(icon: Icons.person_outline, label: S.profile, subtitle: S.profileSubtitle, color: AppColors.success, onTap: () => context.push('/profile')),
          _NavCard(icon: Icons.check_circle_outline, label: 'Validate', subtitle: S.comingSoon, color: AppColors.warning, onTap: () => _showComingSoon(context, 'Doctor Validate screen')),
        ];
      case UserRole.admin:
        return [
          _NavCard(icon: Icons.person_outline, label: S.profile, subtitle: S.profileSubtitle, color: AppColors.success, onTap: () => context.push('/profile')),
          _NavCard(icon: Icons.people_outline, label: 'Users', subtitle: S.comingSoon, color: AppColors.primary, onTap: () => _showComingSoon(context, 'User Management screen')),
          _NavCard(icon: Icons.verified_outlined, label: 'Approvals', subtitle: S.comingSoon, color: AppColors.teal, onTap: () => _showComingSoon(context, 'Doctor Approvals screen')),
          _NavCard(icon: Icons.bar_chart_outlined, label: 'Statistics', subtitle: S.comingSoon, color: const Color(0xFF7C3AED), onTap: () => _showComingSoon(context, 'Admin Dashboard screen')),
        ];
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming in the next sprint.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  IconData _roleIcon(UserRole role) => switch (role) {
    UserRole.patient => Icons.medical_services_outlined,
    UserRole.doctor => Icons.medical_services_outlined,
    UserRole.admin => Icons.admin_panel_settings_outlined,
  };

  String _infoBannerText(UserRole role) => switch (role) {
    UserRole.patient => S.infoBannerPatient,
    UserRole.doctor => S.infoBannerDoctor,
    UserRole.admin => S.infoBannerAdmin,
  };
}

class _NavCard extends StatelessWidget {
  const _NavCard({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecorations.card,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.h3.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text(subtitle, style: AppText.labelSm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}