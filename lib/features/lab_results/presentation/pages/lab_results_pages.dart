// lib/features/lab_results/presentation/pages/lab_results_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/lab_result.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../presentation/providers/lab_results_provider.dart';

class LabResultsPage extends ConsumerWidget {
  const LabResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lab Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(labResultsProvider),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(labResultsProvider),
        ),
        data: (page) {
          if (page.content.isEmpty) {
            return const EmptyStateView(
              icon: Icons.science_outlined,
              title: 'No lab results yet',
              subtitle:
                  'When a doctor orders lab tests for you, the results will appear here.',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(labResultsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: page.content.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _LabResultCard(result: page.content[i]),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LabResultCard
// ─────────────────────────────────────────────────────────────────────────────
class _LabResultCard extends StatelessWidget {
  const _LabResultCard({required this.result});

  final LabResult result;

  @override
  Widget build(BuildContext context) {
    final testLabel =
        result.testTypeDisplayName ?? result.testType.displayName;
    final iconColor = _iconColor(result);

    return GestureDetector(
      onTap: () => context.push('/lab-results/${result.id}'),
      child: Container(
        decoration: AppDecorations.card,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: lab number + status badge ──────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.labNumber != null
                        ? result.labNumber!
                        : 'Lab #${result.id}',
                    style: AppText.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: result.status),
              ],
            ),

            const SizedBox(height: 10),

            // ── Test info row ────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.science_outlined,
                      color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testLabel,
                        style: AppText.bodyLg
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          // Short type tag (e.g. "CBC", "BMP")
                          _TypeChip(result.testType.shortName),
                          if (result.status.isCompleted &&
                              result.items.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _AbnormalBadge(result: result),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Divider ─────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            // ── Footer: ordered date + doctor + chevron ──────────────────
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 5),
                Text(
                  DateFormatter.formatDate(result.orderedAt),
                  style: AppText.labelSm,
                ),
                if (result.doctorName != null) ...[
                  const SizedBox(width: 10),
                  const Text('·',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Dr. ${result.doctorName}',
                      style: AppText.labelSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                Text('View results',
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

  /// Icon colour reflects whether results are all normal or have flags.
  Color _iconColor(LabResult r) {
    if (!r.status.isCompleted) return AppColors.textTertiary;
    if (r.hasCriticalItems) return AppColors.error;
    if (r.hasAbnormalItems) return AppColors.warning;
    return AppColors.success;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusBadge
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final LabResultStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, dot, label) = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: AppText.labelSm.copyWith(color: fg, fontSize: 11)),
        ],
      ),
    );
  }

  (Color, Color, Color, String) _config(LabResultStatus s) => switch (s) {
        LabResultStatus.pending => (
            AppColors.pendingBg,
            AppColors.pendingText,
            AppColors.pendingDot,
            'Pending'
          ),
        LabResultStatus.completed => (
            AppColors.completedBg,
            AppColors.completedText,
            AppColors.completedDot,
            'Completed'
          ),
        LabResultStatus.cancelled => (
            AppColors.failedBg,
            AppColors.failedText,
            AppColors.failedDot,
            'Cancelled'
          ),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// _TypeChip — small pill showing short test type (CBC, BMP…)
// ─────────────────────────────────────────────────────────────────────────────
class _TypeChip extends StatelessWidget {
  const _TypeChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: AppText.labelSm.copyWith(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AbnormalBadge — "2 abnormal" shown on completed results with flags
// ─────────────────────────────────────────────────────────────────────────────
class _AbnormalBadge extends StatelessWidget {
  const _AbnormalBadge({required this.result});
  final LabResult result;

  @override
  Widget build(BuildContext context) {
    if (!result.hasAbnormalItems) return const SizedBox.shrink();

    final count = result.abnormalCount;
    final isCritical = result.hasCriticalItems;
    final bg = isCritical ? AppColors.failedBg : AppColors.pendingBg;
    final fg = isCritical ? AppColors.failedText : AppColors.pendingText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(
        '$count abnormal',
        style: AppText.labelSm.copyWith(color: fg, fontSize: 10),
      ),
    );
  }
}