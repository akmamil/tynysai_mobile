// lib/features/reports/presentation/providers/reports_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/diagnostic_report.dart';
import '../../../../core/network/api_response.dart';
import '../../data/reports_remote_datasource.dart';

/// Loads the first page of reports for the current patient.
///
/// Lifecycle: autoDispose — provider is dropped when no widget watches it,
/// so navigating away and back triggers a fresh fetch (no stale data).
/// Force refresh from UI: ref.invalidate(reportsProvider).
final reportsProvider =
    FutureProvider.autoDispose<PageResponse<DiagnosticReport>>((ref) async {
  return ref.read(reportsDatasourceProvider).getPatientReports();
});

/// Single report by ID — consumed by ReportDetailPage.
///
/// Uses /api/reports/patient/{id} (ownership-checked, PATIENT role).
/// The provider is keyed by report ID via .family so each report
/// gets its own cache entry. autoDispose clears it on pop.
final reportDetailProvider = FutureProvider.autoDispose
    .family<DiagnosticReport, int>((ref, id) async {
  return ref
      .read(reportsDatasourceProvider)
      .getReportByIdForPatient(id);
});
