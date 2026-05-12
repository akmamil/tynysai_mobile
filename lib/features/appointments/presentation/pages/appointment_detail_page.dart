// lib/features/appointments/presentation/pages/appointment_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/appointments_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppointmentDetailPage
// ─────────────────────────────────────────────────────────────────────────────
class AppointmentDetailPage extends ConsumerWidget {
  const AppointmentDetailPage({super.key, required this.appointmentId});

  final int appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentDetailProvider(appointmentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Appointment Details')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(appointmentDetailProvider(appointmentId)),
        ),
        data: (appointment) => _DetailBody(appointment: appointment),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailBody
// ─────────────────────────────────────────────────────────────────────────────
class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final cancelState = ref.watch(cancelAppointmentProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero card ──────────────────────────────────────────────────
          _HeroCard(appointment: appointment),
          const SizedBox(height: 16),

          // ── Doctor section ──────────────────────────────────────────────
          const _SectionLabel('Doctor'),
          _InfoCard(
            child: _MetaRow(
              icon: Icons.person_outline,
              label: 'Dr. ${appointment.doctorName}',
              sublabel: appointment.doctorSpecialization,
            ),
          ),
          const SizedBox(height: 16),

          // ── Date & Time ─────────────────────────────────────────────────
          const _SectionLabel('Date & Time'),
          _InfoCard(
            child: Column(
              children: [
                _MetaRow(
                  icon: Icons.calendar_today_outlined,
                  label: DateFormatter.formatDate(appointment.appointmentDate),
                  sublabel: 'Appointment date',
                ),
                if (appointment.startTime != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _MetaRow(
                    icon: Icons.access_time_outlined,
                    label: _formatTimeRange(
                        appointment.startTime, appointment.endTime),
                    sublabel: 'Time slot',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Reason ──────────────────────────────────────────────────────
          if (appointment.reason != null &&
              appointment.reason!.isNotEmpty) ...[
            const _SectionLabel('Reason for Visit'),
            _InfoCard(
              child: Text(
                appointment.reason!,
                style: AppText.bodyMd.copyWith(height: 1.55),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Doctor Notes (post-visit) ────────────────────────────────────
          if (appointment.notes != null &&
              appointment.notes!.isNotEmpty) ...[
            const _SectionLabel("Doctor's Notes"),
            _InfoCard(
              child: Text(
                appointment.notes!,
                style: AppText.bodyMd.copyWith(height: 1.55),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Telehealth link ──────────────────────────────────────────────
          if (appointment.meetingLink != null &&
              appointment.status.isUpcoming) ...[
            const _SectionLabel('Telehealth'),
            _InfoCard(
              child: _MetaRow(
                icon: Icons.videocam_outlined,
                label: 'Join video consultation',
                sublabel: appointment.meetingLink,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Appointment meta ─────────────────────────────────────────────
          const _SectionLabel('Appointment Info'),
          _InfoCard(
            child: Column(
              children: [
                _MetaRow(
                  icon: Icons.tag,
                  label: '#${appointment.id}',
                  sublabel: 'Appointment ID',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                _MetaRow(
                  icon: Icons.schedule_outlined,
                  label: DateFormatter.formatDateTime(appointment.createdAt),
                  sublabel: 'Booked on',
                ),
                if (appointment.updatedAt != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _MetaRow(
                    icon: Icons.update_outlined,
                    label:
                        DateFormatter.formatDateTime(appointment.updatedAt),
                    sublabel: 'Last updated',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Cancel button ────────────────────────────────────────────────
          // Shown only when the appointment is still SCHEDULED.
          if (appointment.status.isUpcoming) ...[
            // Display API error inline if cancel failed.
            if (cancelState is AsyncError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.failedBg,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cancelState.error.toString(),
                          style: AppText.bodySm
                              .copyWith(color: AppColors.failedText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            AppButton(
              label: 'Cancel Appointment',
              isLoading: cancelState is AsyncLoading,
              variant: AppButtonVariant.danger,
              onPressed: cancelState is AsyncLoading
                  ? null
                  : () => _confirmCancel(context, appointment.id),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, int id) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CancelBottomSheet(),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final success =
        await ref.read(cancelAppointmentProvider.notifier).cancel(id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Appointment cancelled successfully.'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      // Pop back to list — list is already invalidated by the notifier.
      if (mounted) context.pop();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeroCard — gradient hero at the top of the page
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final (statusBg, statusLabel) = _statusBadge(appointment.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.gradientCard,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appointment', style: AppText.onDarkMuted),
                const SizedBox(height: 4),
                Text(
                  'Dr. ${appointment.doctorName}',
                  style: AppText.onDarkBold,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormatter.formatDate(appointment.appointmentDate),
                      style: AppText.onDarkMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _statusBadge(AppointmentStatus s) => switch (s) {
        AppointmentStatus.scheduled => (AppColors.success, '● Scheduled'),
        AppointmentStatus.completed => (AppColors.info, '✓ Completed'),
        AppointmentStatus.cancelled => (AppColors.error, '✕ Cancelled'),
        AppointmentStatus.noShow => (AppColors.warning, '⚠ No Show'),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// _CancelBottomSheet — confirmation modal
// ─────────────────────────────────────────────────────────────────────────────
class _CancelBottomSheet extends StatelessWidget {
  const _CancelBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x20000000), blurRadius: 24, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Warning icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.failedBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.cancel_outlined,
                color: AppColors.error, size: 26),
          ),
          const SizedBox(height: 16),

          Text('Cancel Appointment?', style: AppText.h2),
          const SizedBox(height: 8),
          Text(
            'This action cannot be undone. The appointment slot will be released '
            'and you will need to rebook if you change your mind.',
            style: AppText.bodyMd
                .copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Keep it',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Yes, cancel',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared local widgets (scoped to this file — match report_detail_page style)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: AppText.labelLg.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 0.8,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: child,
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    this.sublabel,
  });

  final IconData icon;
  final String label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      AppText.bodyMd.copyWith(fontWeight: FontWeight.w500)),
              if (sublabel != null)
                Text(sublabel!, style: AppText.bodySm),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _formatTimeRange(String? start, String? end) {
  if (start == null) return '—';
  if (end == null) return start;
  return '$start – $end';
}