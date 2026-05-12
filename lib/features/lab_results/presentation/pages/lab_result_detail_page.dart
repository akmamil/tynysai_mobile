// lib/features/lab_results/presentation/pages/lab_result_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/lab_result.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/lab_results_provider.dart';

class LabResultDetailPage extends ConsumerWidget {
  const LabResultDetailPage({super.key, required this.labResultId});

  final int labResultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labResultDetailProvider(labResultId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lab Result'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(labResultDetailProvider(labResultId)),
        ),
        data: (result) => _DetailBody(result: result),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailBody
// ─────────────────────────────────────────────────────────────────────────────
class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.result});

  final LabResult result;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero header card ─────────────────────────────────────────
          _HeaderCard(result: result),
          const SizedBox(height: 16),

          // ── Ordered by (doctor info) ─────────────────────────────────
          if (result.doctorName != null) ...[
            const SectionLabel('Ordered by'),
            AppCard(
              child: _MetaRow(
                icon: Icons.person_outline,
                label: result.doctorName!,
                sublabel: result.doctorSpecialization,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Dates ────────────────────────────────────────────────────
          const SectionLabel('Dates'),
          AppCard(
            child: Column(
              children: [
                _MetaRow(
                  icon: Icons.assignment_outlined,
                  label: DateFormatter.formatDateTime(result.orderedAt),
                  sublabel: 'Ordered',
                ),
                if (result.resultDate != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _MetaRow(
                    icon: Icons.check_circle_outline,
                    label: DateFormatter.formatDateTime(result.resultDate),
                    sublabel: 'Results available',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Test results table ───────────────────────────────────────
          if (result.items.isNotEmpty) ...[
            const SectionLabel('Test Results'),
            _ResultsTable(items: result.items),
            const SizedBox(height: 16),
          ],

          // ── Summary chips (counts) ───────────────────────────────────
          if (result.items.isNotEmpty && result.status.isCompleted)
            _ResultSummaryRow(result: result),

          if (result.items.isNotEmpty && result.status.isCompleted)
            const SizedBox(height: 16),

          // ── Doctor's notes ───────────────────────────────────────────
          if (result.notes != null) ...[
            const SectionLabel('Doctor\'s Notes'),
            AppCard(
              child: Text(
                result.notes!,
                style: AppText.bodyMd.copyWith(height: 1.55),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Lab info ─────────────────────────────────────────────────
          const SectionLabel('Lab Info'),
          AppCard(
            child: Column(
              children: [
                _MetaRow(
                  icon: Icons.tag,
                  label: result.labNumber ?? 'Lab #${result.id}',
                  sublabel: 'Lab number',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                _MetaRow(
                  icon: Icons.science_outlined,
                  label: result.testTypeDisplayName ??
                      result.testType.displayName,
                  sublabel: 'Test type',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeaderCard — gradient hero matching the reports detail page style
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.result});
  final LabResult result;

  @override
  Widget build(BuildContext context) {
    final testLabel =
        result.testTypeDisplayName ?? result.testType.displayName;
    final isCompleted = result.status.isCompleted;
    final hasCritical = result.hasCriticalItems;
    final hasAbnormal = result.hasAbnormalItems;

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
                Text('Lab Result', style: AppText.onDarkMuted),
                const SizedBox(height: 4),
                Text(
                  testLabel,
                  style: AppText.onDarkBold,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        result.status.displayName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    // Abnormal flag
                    if (isCompleted && hasAbnormal) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasCritical
                                  ? Icons.warning_rounded
                                  : Icons.info_outline,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasCritical
                                  ? '${result.abnormalCount} critical'
                                  : '${result.abnormalCount} abnormal',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
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
            child: const Icon(Icons.science_outlined,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ResultsTable — one row per LabResultItem, with color-coded status
// ─────────────────────────────────────────────────────────────────────────────
class _ResultsTable extends StatelessWidget {
  const _ResultsTable({required this.items});
  final List<LabResultItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card,
      // Clip children to the card's rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Column header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.divider,
            child: Row(
              children: [
                const Expanded(
                  flex: 5,
                  child: Text(
                    'Test',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Value',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Reference',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          // ── Data rows ─────────────────────────────────────────────────
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isLast = i == items.length - 1;
            return _ResultRow(item: item, showDivider: !isLast);
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ResultRow — a single item row inside the results table
// ─────────────────────────────────────────────────────────────────────────────
class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.item, required this.showDivider});

  final LabResultItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final cfg = _statusConfig(item.status);

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Test name + status indicator ─────────────────────────
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    // Color-dot indicator
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 8, top: 1),
                      decoration: BoxDecoration(
                        color: cfg.dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Value + unit + status label ──────────────────────────
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.unit != null
                          ? '${item.value} ${item.unit}'
                          : item.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cfg.valueColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!item.status.isNormal)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: cfg.badgeBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.status.displayName,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: cfg.badgeFg,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Reference range ──────────────────────────────────────
              Expanded(
                flex: 4,
                child: Text(
                  item.referenceRange ?? '—',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
      ],
    );
  }

  _ItemStatusConfig _statusConfig(LabItemStatus s) => switch (s) {
        LabItemStatus.normal => const _ItemStatusConfig(
            dotColor: AppColors.success,
            valueColor: AppColors.textPrimary,
            badgeBg: AppColors.completedBg,
            badgeFg: AppColors.completedText,
          ),
        LabItemStatus.low => const _ItemStatusConfig(
            dotColor: AppColors.warning,
            valueColor: Color(0xFF92400E),
            badgeBg: AppColors.pendingBg,
            badgeFg: AppColors.pendingText,
          ),
        LabItemStatus.high => const _ItemStatusConfig(
            dotColor: AppColors.warning,
            valueColor: Color(0xFF92400E),
            badgeBg: AppColors.pendingBg,
            badgeFg: AppColors.pendingText,
          ),
        LabItemStatus.criticalLow => const _ItemStatusConfig(
            dotColor: AppColors.error,
            valueColor: AppColors.error,
            badgeBg: AppColors.failedBg,
            badgeFg: AppColors.failedText,
          ),
        LabItemStatus.criticalHigh => const _ItemStatusConfig(
            dotColor: AppColors.error,
            valueColor: AppColors.error,
            badgeBg: AppColors.failedBg,
            badgeFg: AppColors.failedText,
          ),
      };
}

class _ItemStatusConfig {
  const _ItemStatusConfig({
    required this.dotColor,
    required this.valueColor,
    required this.badgeBg,
    required this.badgeFg,
  });
  final Color dotColor;
  final Color valueColor;
  final Color badgeBg;
  final Color badgeFg;
}

// ─────────────────────────────────────────────────────────────────────────────
// _ResultSummaryRow — "X normal · Y abnormal" summary below the table
// ─────────────────────────────────────────────────────────────────────────────
class _ResultSummaryRow extends StatelessWidget {
  const _ResultSummaryRow({required this.result});
  final LabResult result;

  @override
  Widget build(BuildContext context) {
    final totalCount = result.items.length;
    final abnormal = result.abnormalCount;
    final normal = totalCount - abnormal;

    return Row(
      children: [
        _SummaryChip(
          label: '$normal normal',
          bg: AppColors.completedBg,
          fg: AppColors.completedText,
          icon: Icons.check_circle_outline,
        ),
        if (abnormal > 0) ...[
          const SizedBox(width: 8),
          _SummaryChip(
            label: '$abnormal out of range',
            bg: result.hasCriticalItems
                ? AppColors.failedBg
                : AppColors.pendingBg,
            fg: result.hasCriticalItems
                ? AppColors.failedText
                : AppColors.pendingText,
            icon: result.hasCriticalItems
                ? Icons.warning_outlined
                : Icons.info_outline,
          ),
        ],
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(label,
              style: AppText.labelMd.copyWith(color: fg, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MetaRow — icon + label + optional sublabel (shared pattern)
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