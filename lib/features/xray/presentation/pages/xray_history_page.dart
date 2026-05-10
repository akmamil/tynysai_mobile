// lib/features/xray/presentation/pages/xray_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/models/xray_analysis.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../../shared/widgets/analysis_status_badge.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/xray_list_provider.dart';

class XrayHistoryPage extends ConsumerWidget {
  const XrayHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(xrayListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My X-Rays'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(xrayListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/xray/upload'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_outlined, size: 18),
        label: const Text('Upload X-Ray',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 3,
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(xrayListProvider),
        ),
        data: (page) {
          if (page.content.isEmpty) {
            return EmptyStateView(
              icon: Icons.image_search_outlined,
              title: 'No X-rays yet',
              subtitle: 'Upload your first chest X-ray to get an AI-powered analysis.',
              action: () => context.push('/xray/upload'),
              actionLabel: 'Upload X-Ray',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(xrayListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: page.content.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _XrayCard(xray: page.content[i]),
            ),
          );
        },
      ),
    );
  }
}

class _XrayCard extends StatelessWidget {
  const _XrayCard({required this.xray});
  final XrayAnalysis xray;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/xray/${xray.id}'),
      child: Container(
        decoration: AppDecorations.card,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Thumbnail icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image_outlined,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filename + status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          xray.originalFileName,
                          style: AppText.h3.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnalysisStatusBadge(status: xray.status),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Meta row
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Text(
                        DateFormatter.formatDateTime(xray.uploadedAt),
                        style: AppText.bodyXs,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.storage_outlined,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Text(
                        FileSizeFormatter.format(xray.fileSizeBytes),
                        style: AppText.bodyXs,
                      ),
                    ],
                  ),
                  // Diagnosis pill (if available)
                  if (xray.aiPrimaryDiagnosisDisplayName != null) ...[
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        xray.aiPrimaryDiagnosisDisplayName!,
                        style: AppText.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}