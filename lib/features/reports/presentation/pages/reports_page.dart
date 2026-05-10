// lib/features/reports/presentation/pages/reports_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/diagnostic_report.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/reports_provider.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(reportsProvider),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(reportsProvider),
        ),
        data: (page) {
          if (page.content.isEmpty) {
            return const EmptyStateView(
              icon: Icons.description_outlined,
              title: 'No reports yet',
              subtitle:
                  'When a doctor creates a diagnostic report for you, it will appear here.',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(reportsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: page.content.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ReportCard(report: page.content[i]),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReportCard
// ─────────────────────────────────────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final DiagnosticReport report;

  @override
  Widget build(BuildContext context) {
    final diagnosisLabel = report.finalDiagnosisDisplayName ??
        report.finalDiagnosis.displayName;
    final severityColor = _severityColor(report.severity);

    return GestureDetector(
      onTap: () => context.push('/reports/${report.id}'),
      child: Container(
        decoration: AppDecorations.card,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: report number + sent badge ──────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.reportNumber != null
                        ? 'Report #${report.reportNumber}'
                        : 'Report #${report.id}',
                    style: AppText.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (report.sentToPatient)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.completedBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 11, color: AppColors.completedText),
                        const SizedBox(width: 4),
                        Text(
                          'Sent',
                          style: AppText.labelSm
                              .copyWith(color: AppColors.completedText),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Diagnosis row ─────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.medical_information_outlined,
                      color: severityColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(diagnosisLabel,
                          style: AppText.bodyLg
                              .copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _SeverityChip(severity: report.severity),
                          const SizedBox(width: 8),
                          if (report.doctorName != null)
                            Expanded(
                              child: Text(
                                'Dr. ${report.doctorName}',
                                style: AppText.bodySm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Divider ───────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            // ── Footer: date + chevron ────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 5),
                Text(
                  DateFormatter.formatDate(report.createdAt),
                  style: AppText.labelSm,
                ),
                const Spacer(),
                Text('View details',
                    style: AppText.labelSm
                        .copyWith(color: AppColors.primary)),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right,
                    color: AppColors.primary, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(Severity s) => switch (s) {
        Severity.none => AppColors.success,
        Severity.mild => AppColors.success,
        Severity.moderate => AppColors.warning,
        Severity.severe => AppColors.error,
        Severity.critical => AppColors.error,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// _SeverityChip
// ─────────────────────────────────────────────────────────────────────────────
class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity});
  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _config(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          style: AppText.labelSm.copyWith(color: fg, fontSize: 10)),
    );
  }

  (String, Color, Color) _config(Severity s) => switch (s) {
        Severity.none => ('Normal', AppColors.completedBg, AppColors.completedText),
        Severity.mild => ('Mild', AppColors.completedBg, AppColors.completedText),
        Severity.moderate =>
          ('Moderate', AppColors.pendingBg, AppColors.pendingText),
        Severity.severe => ('Severe', AppColors.failedBg, AppColors.failedText),
        Severity.critical =>
          ('Critical', AppColors.failedBg, AppColors.failedText),
      };
}