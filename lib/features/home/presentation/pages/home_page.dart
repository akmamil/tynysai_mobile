// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/enums.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('TynysAI'),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_outlined,
                  size: 20, color: AppColors.primary),
            ),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'logout') ref.read(authProvider.notifier).logout();
              if (v == 'profile') context.push('/profile');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  (user?.fullName.isNotEmpty == true)
                      ? user!.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(children: [
                  const Icon(Icons.person_outline, size: 18),
                  const SizedBox(width: 10),
                  Text(user?.fullName ?? 'Profile', style: AppText.bodyMd),
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout_outlined, size: 18, color: AppColors.error),
                  SizedBox(width: 10),
                  Text('Sign Out',
                      style: TextStyle(color: AppColors.error, fontSize: 14)),
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

            // ── Hero welcome card ─────────────────────────────────────────
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
                        Text('Good day,', style: AppText.onDarkMuted),
                        const SizedBox(height: 2),
                        Text(
                          firstName.isEmpty ? role.displayName : firstName,
                          style: AppText.onDarkBold,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          // ✅ FIX: role chip reads the real role from JWT
                          child: Text(
                            role.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _roleIcon(role),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Quick Actions', style: AppText.h3),
            const SizedBox(height: 12),

            // ── Role-aware navigation grid ──────────────────────────────
            // Each role gets cards matching only the routes that exist.
            // "Coming soon" cards call a snackbar instead of navigating —
            // no GoException, no crash.
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

            // ── Notifications shortcut (all roles) ────────────────────────
            GestureDetector(
              onTap: () => context.push('/notifications'),
              child: Container(
                decoration: AppDecorations.card,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: AppColors.warning, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifications',
                              style: AppText.h3.copyWith(fontSize: 14)),
                          const SizedBox(height: 1),
                          Text('Updates and alerts',
                              style: AppText.labelSm),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textTertiary, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Info banner ───────────────────────────────────────────────
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('How it works',
                            style:
                                AppText.h3.copyWith(color: AppColors.primary)),
                        const SizedBox(height: 3),
                        Text(
                          _infoBannerText(role),
                          style: AppText.bodySm,
                        ),
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

  // ── Card lists per role ─────────────────────────────────────────────────────
  List<Widget> _buildCards(BuildContext context, UserRole role) {
    switch (role) {
      // ── Patient: all four routes exist ──────────────────────────────────
      case UserRole.patient:
        return [
          _NavCard(
            icon: Icons.upload_file_outlined,
            label: 'Upload X-Ray',
            subtitle: 'AI analysis',
            color: AppColors.primary,
            onTap: () => context.push('/xray/upload'),
          ),
          _NavCard(
            icon: Icons.history_outlined,
            label: 'My X-Rays',
            subtitle: 'View history',
            color: AppColors.teal,
            onTap: () => context.push('/history'),
          ),
          _NavCard(
            icon: Icons.description_outlined,
            label: 'Reports',
            subtitle: 'Doctor reports',
            color: const Color(0xFF7C3AED),
            onTap: () => context.push('/reports'),
          ),
          _NavCard(
            icon: Icons.person_outline,
            label: 'Profile',
            subtitle: 'Medical info',
            color: AppColors.success,
            onTap: () => context.push('/profile'),
          ),
        ];

      // ── Doctor: existing routes + coming-soon stubs ────────────────────
      case UserRole.doctor:
        return [
          _NavCard(
            icon: Icons.image_search_outlined,
            label: 'My X-Rays',
            subtitle: 'Assigned scans',
            color: AppColors.primary,
            onTap: () => context.push('/history'),
          ),
          _NavCard(
            icon: Icons.description_outlined,
            label: 'Reports',
            subtitle: 'My reports',
            color: const Color(0xFF7C3AED),
            onTap: () => context.push('/reports'),
          ),
          _NavCard(
            icon: Icons.person_outline,
            label: 'Profile',
            subtitle: 'My account',
            color: AppColors.success,
            onTap: () => context.push('/profile'),
          ),
          // Coming soon — shows a SnackBar instead of navigating.
          // Replace onTap with context.push('/doctor/validate') in Sprint 4.
          _NavCard(
            icon: Icons.check_circle_outline,
            label: 'Validate',
            subtitle: 'Coming soon',
            color: AppColors.warning,
            onTap: () => _showComingSoon(context, 'Doctor Validate screen'),
          ),
        ];

      // ── Admin: existing routes + coming-soon stubs ─────────────────────
      case UserRole.admin:
        return [
          _NavCard(
            icon: Icons.person_outline,
            label: 'Profile',
            subtitle: 'My account',
            color: AppColors.success,
            onTap: () => context.push('/profile'),
          ),
          _NavCard(
            icon: Icons.people_outline,
            label: 'Users',
            subtitle: 'Coming soon',
            color: AppColors.primary,
            onTap: () => _showComingSoon(context, 'User Management screen'),
          ),
          _NavCard(
            icon: Icons.verified_outlined,
            label: 'Approvals',
            subtitle: 'Coming soon',
            color: AppColors.teal,
            onTap: () => _showComingSoon(context, 'Doctor Approvals screen'),
          ),
          _NavCard(
            icon: Icons.bar_chart_outlined,
            label: 'Statistics',
            subtitle: 'Coming soon',
            color: const Color(0xFF7C3AED),
            onTap: () => _showComingSoon(context, 'Admin Dashboard screen'),
          ),
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
        UserRole.patient =>
          'Upload a chest X-ray and receive an AI-powered diagnosis in seconds.',
        UserRole.doctor =>
          'Review assigned X-ray analyses, validate AI results, and create diagnostic reports.',
        UserRole.admin =>
          'Manage users, approve doctor registrations, and monitor platform activity.',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// _NavCard — shared quick-action card
// ─────────────────────────────────────────────────────────────────────────────
class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.h3.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
