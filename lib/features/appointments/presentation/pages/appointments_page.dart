// lib/features/appointments/presentation/pages/appointments_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/appointments_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppointmentsPage
// ─────────────────────────────────────────────────────────────────────────────
class AppointmentsPage extends ConsumerWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // ── Back button ───────────────────────────────────────────────────
        // Uses context.pop() when there is a route to return to (the normal
        // case: pushed from HomePage via context.push('/appointments')).
        // Falls back to context.go('/home') for direct-navigation scenarios
        // (deep links, notifications, fresh sessions) so the user is never
        // stranded on this screen without a way back.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('My Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(appointmentsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/appointments/book'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Book Appointment',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(appointmentsProvider),
        ),
        data: (page) {
          final all = page.content;

          if (all.isEmpty) {
            return const EmptyStateView(
              icon: Icons.calendar_today_outlined,
              title: 'No appointments yet',
              subtitle:
                  'When you book an appointment with a doctor, it will appear here.',
            );
          }

          final upcoming =
              all.where((a) => a.isUpcoming).toList(growable: false);
          final past =
              all.where((a) => !a.isUpcoming).toList(growable: false);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(appointmentsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                // ── Upcoming ──────────────────────────────────────────────
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Upcoming',
                    count: upcoming.length,
                    dotColor: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  ...upcoming.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AppointmentCard(appointment: a),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // ── Past ──────────────────────────────────────────────────
                if (past.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Past',
                    count: past.length,
                    dotColor: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 8),
                  ...past.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AppointmentCard(appointment: a),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.dotColor,
  });

  final String label;
  final int count;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppText.h3),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: AppText.labelSm.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppointmentCard
// ─────────────────────────────────────────────────────────────────────────────
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final (statusBg, statusFg, statusIcon) = _statusConfig(appointment.status);

    return GestureDetector(
      onTap: () => context.push('/appointments/${appointment.id}'),
      child: Container(
        decoration: AppDecorations.card,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: doctor + status badge ──────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor avatar placeholder
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${appointment.doctorName}',
                        style: AppText.bodyLg
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (appointment.doctorSpecialization != null)
                        Text(
                          appointment.doctorSpecialization!,
                          style: AppText.bodySm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon,
                          size: 11, color: statusFg),
                      const SizedBox(width: 4),
                      Text(
                        appointment.status.displayName,
                        style: AppText.labelSm
                            .copyWith(color: statusFg, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            // ── Date / time row ──────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 5),
                Text(
                  DateFormatter.formatDate(appointment.appointmentDate),
                  style: AppText.bodySm
                      .copyWith(color: AppColors.textPrimary),
                ),
                if (appointment.startTime != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time_outlined,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 5),
                  Text(
                    _formatTimeRange(
                        appointment.startTime, appointment.endTime),
                    style: AppText.bodySm
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ],
                const Spacer(),
                Text(
                  'Details',
                  style: AppText.labelSm
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right,
                    color: AppColors.primary, size: 16),
              ],
            ),

            // ── Reason preview ───────────────────────────────────────────
            if (appointment.reason != null &&
                appointment.reason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_outlined,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      appointment.reason!,
                      style: AppText.bodySm,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // ── Meeting link badge ────────────────────────────────────────
            if (appointment.meetingLink != null &&
                appointment.status.isUpcoming) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_outlined,
                        size: 14, color: AppColors.teal),
                    const SizedBox(width: 6),
                    Text(
                      'Telehealth link available',
                      style: AppText.labelSm
                          .copyWith(color: AppColors.teal, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Returns (background, foreground, icon) tuple for each status.
  (Color, Color, IconData) _statusConfig(AppointmentStatus s) =>
      switch (s) {
        AppointmentStatus.scheduled => (
            AppColors.completedBg,
            AppColors.completedText,
            Icons.event_available_outlined,
          ),
        AppointmentStatus.completed => (
            AppColors.processingBg,
            AppColors.processingText,
            Icons.check_circle_outline,
          ),
        AppointmentStatus.cancelled => (
            AppColors.failedBg,
            AppColors.failedText,
            Icons.cancel_outlined,
          ),
        AppointmentStatus.noShow => (
            AppColors.reviewBg,
            AppColors.reviewText,
            Icons.person_off_outlined,
          ),
      };

  String _formatTimeRange(String? start, String? end) {
    if (start == null) return '';
    if (end == null) return start;
    return '$start – $end';
  }
}
