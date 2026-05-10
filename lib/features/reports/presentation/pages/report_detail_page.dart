// lib/features/reports/presentation/pages/report_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/diagnostic_report.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/reports_provider.dart';

class ReportDetailPage extends ConsumerWidget {
  const ReportDetailPage({super.key, required this.reportId});

  final int reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report Detail'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(reportDetailProvider(reportId)),
        ),
        data: (report) => _ReportBody(report: report),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReportBody — all sections
// ─────────────────────────────────────────────────────────────────────────────
class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});

  final DiagnosticReport report;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ─────────────────────────────────────────────────
          _HeaderCard(report: report),
          const SizedBox(height: 16),

          // ── Doctor ──────────────────────────────────────────────────────
          if (report.doctorName != null) ...[
            const SectionLabel('Doctor'),
            AppCard(
              child: _MetaRow(
                icon: Icons.person_outline,
                label: report.doctorName!,
                sublabel: report.doctorSpecialization,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Diagnosis ───────────────────────────────────────────────────
          const SectionLabel('Final Diagnosis'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.finalDiagnosisDisplayName ??
                            report.finalDiagnosis.displayName,
                        style: AppText.h2,
                      ),
                    ),
                    _SeverityBadge(severity: report.severity),
                  ],
                ),
                if (report.xrayAnalysisId != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        context.push('/xray/${report.xrayAnalysisId}'),
                    child: Row(
                      children: [
                        const Icon(Icons.image_outlined,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          'View linked X-Ray #${report.xrayAnalysisId}',
                          style: AppText.bodySm
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Clinical Findings ───────────────────────────────────────────
          if (report.clinicalFindings.isNotEmpty) ...[
            const SectionLabel('Clinical Findings'),
            AppCard(
              child: Text(report.clinicalFindings,
                  style: AppText.bodyMd.copyWith(height: 1.55)),
            ),
            const SizedBox(height: 16),
          ],

          // ── Report Text ─────────────────────────────────────────────────
          if (report.reportText.isNotEmpty) ...[
            const SectionLabel('Doctor\'s Notes'),
            AppCard(
              child: Text(report.reportText,
                  style: AppText.bodyMd.copyWith(height: 1.55)),
            ),
            const SizedBox(height: 16),
          ],

          // ── Recommendations ─────────────────────────────────────────────
          if (_hasRecommendations(report)) ...[
            const SectionLabel('Recommendations'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (report.treatmentRecommendations != null)
                    _RecRow(
                      icon: Icons.medical_services_outlined,
                      title: 'Treatment',
                      body: report.treatmentRecommendations!,
                    ),
                  if (report.medicationRecommendations != null) ...[
                    if (report.treatmentRecommendations != null)
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1)),
                    _RecRow(
                      icon: Icons.medication_outlined,
                      title: 'Medication',
                      body: report.medicationRecommendations!,
                    ),
                  ],
                  if (report.lifestyleRecommendations != null) ...[
                    if (report.treatmentRecommendations != null ||
                        report.medicationRecommendations != null)
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1)),
                    _RecRow(
                      icon: Icons.directions_walk_outlined,
                      title: 'Lifestyle',
                      body: report.lifestyleRecommendations!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Follow-up ───────────────────────────────────────────────────
          if (report.followUpDate != null) ...[
            const SectionLabel('Follow-up'),
            AppCard(
              child: _MetaRow(
                icon: Icons.calendar_today_outlined,
                label: DateFormatter.formatDate(report.followUpDate),
                sublabel: 'Scheduled follow-up date',
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Meta ────────────────────────────────────────────────────────
          const SectionLabel('Report Info'),
          AppCard(
            child: Column(
              children: [
                _MetaRow(
                  icon: Icons.tag,
                  label: report.reportNumber != null
                      ? 'Report #${report.reportNumber}'
                      : 'Report #${report.id}',
                  sublabel: 'Report number',
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1)),
                _MetaRow(
                  icon: Icons.schedule_outlined,
                  label: DateFormatter.formatDateTime(report.createdAt),
                  sublabel: 'Created',
                ),
                if (report.sentAt != null) ...[
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1)),
                  _MetaRow(
                    icon: Icons.send_outlined,
                    label: DateFormatter.formatDateTime(report.sentAt),
                    sublabel: 'Sent to patient',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasRecommendations(DiagnosticReport r) =>
      r.treatmentRecommendations != null ||
      r.medicationRecommendations != null ||
      r.lifestyleRecommendations != null;
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeaderCard — gradient hero at the top of the page
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.report});
  final DiagnosticReport report;

  @override
  Widget build(BuildContext context) {
    final isSent = report.sentToPatient;
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
                Text('Diagnostic Report', style: AppText.onDarkMuted),
                const SizedBox(height: 4),
                Text(
                  report.finalDiagnosisDisplayName ??
                      report.finalDiagnosis.displayName,
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
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isSent ? '✓ Sent to you' : 'Not yet sent',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
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
            child: const Icon(Icons.description_outlined,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SeverityBadge
// ─────────────────────────────────────────────────────────────────────────────
class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});
  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _config(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style:
              AppText.labelMd.copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }

  (String, Color, Color) _config(Severity s) => switch (s) {
        Severity.none =>
          ('Normal', AppColors.completedBg, AppColors.completedText),
        Severity.mild =>
          ('Mild', AppColors.completedBg, AppColors.completedText),
        Severity.moderate =>
          ('Moderate', AppColors.pendingBg, AppColors.pendingText),
        Severity.severe =>
          ('Severe', AppColors.failedBg, AppColors.failedText),
        Severity.critical =>
          ('Critical', AppColors.failedBg, AppColors.failedText),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// _MetaRow — icon + label + optional sublabel
// ─────────────────────────────────────────────────────────────────────────────
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
                  style: AppText.bodyMd
                      .copyWith(fontWeight: FontWeight.w500)),
              if (sublabel != null)
                Text(sublabel!, style: AppText.bodySm),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RecRow — recommendation item (icon + title + body text)
// ─────────────────────────────────────────────────────────────────────────────
class _RecRow extends StatelessWidget {
  const _RecRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: AppColors.teal, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppText.h3.copyWith(fontSize: 13)),
              const SizedBox(height: 3),
              Text(body,
                  style: AppText.bodyMd.copyWith(
                      color: AppColors.textSecondary, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
