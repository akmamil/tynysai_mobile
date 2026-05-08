import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('My X-Rays'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(xrayListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/xray/upload'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload X-Ray'),
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
              subtitle: 'Upload your first X-ray to get an AI analysis.',
              action: () => context.push('/xray/upload'),
              actionLabel: 'Upload X-Ray',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(xrayListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image_search_outlined,
                    size: 20, color: Color(0xFF1A73E8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    xray.originalFileName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnalysisStatusBadge(status: xray.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  DateFormatter.formatDateTime(xray.uploadedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 12),
                Text(
                  FileSizeFormatter.format(xray.fileSizeBytes),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            if (xray.aiPrimaryDiagnosisDisplayName != null) ...[
              const SizedBox(height: 8),
              Text(
                xray.aiPrimaryDiagnosisDisplayName!,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF1A73E8), fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}