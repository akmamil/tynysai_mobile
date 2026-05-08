// lib/features/xray/presentation/pages/xray_result_page.dart
//
// NAVIGATION NOTE:
// This page is reached via context.push('/xray/$id') from two places:
//   • UploadXrayPage (after upload success via context.go) → AppBar back goes to /history or /home
//   • XrayHistoryPage (via context.push) → AppBar back goes to /history
//
// context.go('/xray/$id') from upload replaces the stack, so the AppBar back
// button is NOT shown in that case. The FAB "Back to Home" handles that path.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/models/xray_analysis.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/analysis_status_badge.dart';
import '../../../../shared/widgets/confidence_bar.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/xray_detail_provider.dart';

class XrayResultPage extends ConsumerWidget {
  const XrayResultPage({super.key, required this.xrayId});
  final int xrayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(xrayDetailProvider(xrayId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        // GoRouter shows back button automatically when there's a previous route.
        // If the stack only has /home → /xray/:id the back arrow is shown.
        // If the stack is just /xray/:id (after context.go from upload), no back arrow.
      ),
      // FAB only shown when there is no back button (arrived from upload via go())
      floatingActionButton: state.whenOrNull(
        data: (analysis) => analysis.status.isTerminal && !context.canPop()
            ? FloatingActionButton.extended(
                onPressed: () => context.go('/home'),
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.home_outlined),
                label: const Text('Home'),
              )
            : null,
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(xrayDetailProvider(xrayId).notifier).refresh(),
        ),
        data: (analysis) => _ResultBody(analysis: analysis),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.analysis});
  final XrayAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // FAB space
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status + date card ───────────────────────────────────────────
          _Card(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 6),
                      AnalysisStatusBadge(status: analysis.status),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Uploaded',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 12)),
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
          const SizedBox(height: 12),

          // ── Processing indicator ─────────────────────────────────────────
          if (analysis.status.isProcessing)
            _Card(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    analysis.status == AnalysisStatus.pending
                        ? 'Queued for analysis...'
                        : 'AI is analyzing your X-ray...',
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This usually takes 10–30 seconds',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

          // ── AI result ────────────────────────────────────────────────────
          if (analysis.aiPrimaryDiagnosis != null) ...[
            const _SectionLabel('AI Diagnosis'),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis.aiPrimaryDiagnosisDisplayName ??
                        analysis.aiPrimaryDiagnosis!.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  if (analysis.aiConfidence != null) ...[
                    const SizedBox(height: 16),
                    ConfidenceBar(confidence: analysis.aiConfidence!),
                  ],
                  if (analysis.aiFindings != null) ...[
                    const SizedBox(height: 16),
                    const Text('Findings',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(analysis.aiFindings!,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF444444))),
                  ],
                  if (analysis.aiDetectedAbnormalities != null) ...[
                    const SizedBox(height: 12),
                    const Text('Detected Abnormalities',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(analysis.aiDetectedAbnormalities!,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF444444))),
                  ],
                ],
              ),
            ),
          ],

          // ── Doctor validation ────────────────────────────────────────────
          if (analysis.status == AnalysisStatus.validated &&
              analysis.doctorDiagnosis != null) ...[
            const _SectionLabel('Doctor Validation'),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified,
                          color: Color(0xFF1B5E20), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          analysis.doctorDiagnosisDisplayName ??
                              analysis.doctorDiagnosis!.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (analysis.validatedByDoctorName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Validated by ${analysis.validatedByDoctorName}',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                  if (analysis.doctorNotes != null) ...[
                    const SizedBox(height: 12),
                    const Text('Doctor Notes',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(analysis.doctorNotes!,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF444444))),
                  ],
                ],
              ),
            ),
          ],

          // ── Requires review notice ───────────────────────────────────────
          if (analysis.status == AnalysisStatus.requiresReview)
            _Card(
              child: const Row(
                children: [
                  Icon(Icons.rate_review_outlined,
                      color: Color(0xFFF57C00), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Awaiting Doctor Review',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text(
                          'The AI result requires expert validation before it is final.',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Failed notice ────────────────────────────────────────────────
          if (analysis.status == AnalysisStatus.failed)
            _Card(
              child: const Row(
                children: [
                  Icon(Icons.cancel_outlined,
                      color: Color(0xFFC62828), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Analysis Failed',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text(
                          'The AI could not process this image. Please try uploading again.',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF666666)),
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

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1A1A2E))),
      );
}
