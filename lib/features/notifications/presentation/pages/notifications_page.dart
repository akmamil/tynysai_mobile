// lib/features/notifications/presentation/pages/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/models/notification.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
// import '../../data/notifications_remote_datasource.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () => ref.invalidate(notificationsProvider),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (page) {
          if (page.content.isEmpty) {
            return const EmptyStateView(
              icon: Icons.notifications_none_outlined,
              title: 'No notifications yet',
              subtitle: 'Updates about your X-ray analyses will appear here.',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: page.content.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _NotificationCard(
                notification: page.content[i],
                onTap: () => _handleTap(context, ref, page.content[i]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, AppNotification n) {
    ref
        .read(notificationsDatasourceProvider)
        .markAsRead(n.id)
        .then((_) => ref.invalidate(notificationsProvider))
        .catchError((_) {});

    if (n.relatedEntityType == 'XRAY_ANALYSIS' && n.relatedEntityId != null) {
      context.push('/xray/${n.relatedEntityId}');
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.read;
    final iconConfig = _iconFor(notification.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconConfig.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconConfig.icon,
                  color: iconConfig.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _labelForType(notification.type),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitleFor(notification),
                    style: AppText.bodySm,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppText.labelSm,
                  ),
                ],
              ),
            ),
            if (notification.relatedEntityType == 'XRAY_ANALYSIS') ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  _IconConfig _iconFor(String type) => switch (type) {
        'ANALYSIS_COMPLETED' =>
          const _IconConfig(Icons.check_circle_outline, AppColors.success),
        'ANALYSIS_REQUIRES_REVIEW' =>
          const _IconConfig(Icons.rate_review_outlined, AppColors.warning),
        'ANALYSIS_VALIDATED' =>
          const _IconConfig(Icons.verified_outlined, AppColors.teal),
        'ANALYSIS_FAILED' =>
          const _IconConfig(Icons.error_outline, AppColors.error),
        'APPOINTMENT_CONFIRMED' =>
          const _IconConfig(Icons.calendar_today_outlined, AppColors.primary),
        _ => const _IconConfig(Icons.notifications_outlined, AppColors.primary),
      };

  String _labelForType(String type) => switch (type) {
        'ANALYSIS_COMPLETED' => 'Analysis Complete',
        'ANALYSIS_REQUIRES_REVIEW' => 'Doctor Review Required',
        'ANALYSIS_VALIDATED' => 'Result Validated',
        'ANALYSIS_FAILED' => 'Analysis Failed',
        'APPOINTMENT_CONFIRMED' => 'Appointment Confirmed',
        _ => type
            .split('_')
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join(' '),
      };

  String _subtitleFor(AppNotification n) {
    final params = n.params ?? {};
    return switch (n.type) {
      'ANALYSIS_COMPLETED' => 'Your X-ray analysis completed successfully.',
      'ANALYSIS_REQUIRES_REVIEW' =>
        'The AI result requires validation by a doctor.',
      'ANALYSIS_VALIDATED' => params['doctorName'] != null
          ? 'Dr. ${params['doctorName']} reviewed your result.'
          : 'A doctor reviewed your result.',
      'ANALYSIS_FAILED' =>
        'The analysis could not be completed. Please try again.',
      _ => 'Tap to view details.',
    };
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return isoString.substring(0, 10);
    } catch (_) {
      return isoString;
    }
  }
}

class _IconConfig {
  const _IconConfig(this.icon, this.color);
  final IconData icon;
  final Color color;
}