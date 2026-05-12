// lib/features/xray/presentation/pages/xray_result_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/models/xray_analysis.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/analysis_status_badge.dart';
import '../../../../shared/widgets/confidence_bar.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/medical_disclaimer_banner.dart'; // ← added
import '../providers/xray_detail_provider.dart';

class XrayResultPage extends ConsumerWidget {
  const XrayResultPage({
    super.key,
    required this.xrayId,
  });

  final int xrayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(xrayDetailProvider(xrayId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analysis Result'),
      ),
      floatingActionButton: state.whenOrNull(
        data: (analysis) => analysis.status.isTerminal && !context.canPop()
            ? FloatingActionButton.extended(
                onPressed: () => context.go('/home'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.home_outlined),
                label: const Text('Home'),
              )
            : null,
      ),
      body: state.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading analysis...',
                style: AppText.bodyMd,
              ),
            ],
          ),
        ),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () {
            ref.read(xrayDetailProvider(xrayId).notifier).refresh();
          },
        ),
        data: (analysis) => _ResultBody(analysis: analysis),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.analysis,
  });

  final XrayAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status / upload date ─────────────────────────────────────────
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnalysisStatusBadge(status: analysis.status),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Uploaded',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDateTime(analysis.uploadedAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Processing spinner ───────────────────────────────────────────
          if (analysis.status.isProcessing)
            AppCard(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    analysis.status == AnalysisStatus.pending
                        ? 'Queued for analysis'
                        : 'AI is analyzing your X-ray',
                    style: AppText.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This usually takes 10–30 seconds. Stay on this page.',
                    style: AppText.bodySm,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: AppColors.border,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // ── AI Diagnosis ─────────────────────────────────────────────────
          if (analysis.aiPrimaryDiagnosis != null) ...[
            const SectionLabel('AI Diagnosis'),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis.aiPrimaryDiagnosisDisplayName ??
                        analysis.aiPrimaryDiagnosis!.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  if (analysis.aiConfidence != null) ...[
                    const SizedBox(height: 16),
                    ConfidenceBar(
                      confidence: analysis.aiConfidence!,
                    ),
                  ],

                  if (analysis.aiFindings != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Findings',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      analysis.aiFindings!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  if (analysis.aiDetectedAbnormalities != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Detected Abnormalities',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      analysis.aiDetectedAbnormalities!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Medical disclaimer — shown whenever AI results are visible ──
            const SizedBox(height: 12),
            const MedicalDisclaimerBanner(),
            const SizedBox(height: 16),
          ],

          // ── Doctor Validation ────────────────────────────────────────────
          if (analysis.status == AnalysisStatus.validated &&
              analysis.doctorDiagnosis != null) ...[
            const SectionLabel('Doctor Validation'),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        color: AppColors.validatedText,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          analysis.doctorDiagnosisDisplayName ??
                              analysis.doctorDiagnosis!.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.validatedText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (analysis.validatedByDoctorName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Validated by ${analysis.validatedByDoctorName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  if (analysis.doctorNotes != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Doctor Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      analysis.doctorNotes!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // ── Awaiting review notice ───────────────────────────────────────
          if (analysis.status == AnalysisStatus.requiresReview)
            AppCard(
              child: const Row(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Awaiting Doctor Review',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'The AI result requires expert validation before it is final.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Failed notice ────────────────────────────────────────────────
          if (analysis.status == AnalysisStatus.failed)
            AppCard(
              child: const Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: AppColors.error,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analysis Failed',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'The AI could not process this image. Please try uploading again.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}