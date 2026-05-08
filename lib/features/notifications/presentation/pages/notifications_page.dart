// lib/features/notifications/presentation/pages/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
              subtitle: 'You\'ll see updates about your X-ray analyses here.',
            );
          }
          return RefreshIndicator(
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

  // ── FIXED: markAsRead wired on tap ─────────────────────────────────────────
  // Fire-and-forget: POST /api/notifications/{id}/read runs in background.
  // On success, invalidate the provider so the list reloads with updated
  // read states from the server. Failures are silently ignored — the UI
  // already showed the item as "read" by navigating away from it.
  // ───────────────────────────────────────────────────────────────────────────
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(12),
          border: notification.read
              ? null
              : Border.all(
                  color: const Color(0xFF1A73E8).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5, right: 10),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.read
                    ? Colors.transparent
                    : const Color(0xFF1A73E8),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelForType(notification.type),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.read
                          ? FontWeight.w500
                          : FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitleFor(notification),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            if (notification.relatedEntityType == 'XRAY_ANALYSIS')
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  String _labelForType(String type) => switch (type) {
        'ANALYSIS_COMPLETED' => 'Analysis Complete',
        'ANALYSIS_REQUIRES_REVIEW' => 'Doctor Review Required',
        'ANALYSIS_VALIDATED' => 'Doctor Validated Result',
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
      'ANALYSIS_COMPLETED' => 'Your X-ray analysis has been completed successfully.',
      'ANALYSIS_REQUIRES_REVIEW' => 'The AI result requires validation by a doctor.',
      'ANALYSIS_VALIDATED' => params['doctorName'] != null
          ? 'Dr. ${params['doctorName']} has reviewed your result.'
          : 'A doctor has reviewed your result.',
      'ANALYSIS_FAILED' =>
        'The analysis could not be completed. Please try uploading again.',
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