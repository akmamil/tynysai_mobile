// lib/features/reports/presentation/providers/reports_provider.dart
// Не уверена

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../../core/models/diagnostic_report.dart';
// import '../../../../core/network/api_response.dart';
// import '../../data/reports_remote_datasource.dart';

/// Loads the first page of patient reports.
/// Use ref.invalidate(reportsProvider) to force a refresh.
// final reportsProvider = FutureProvider.autoDispose<
//     PageResponse<DiagnosticReport>>((ref) async {
//   return ref.read(reportsDatasourceProvider).getPatientReports();
// });

// /// Single report by ID — used by ReportDetailPage.
// final reportDetailProvider = FutureProvider.autoDispose
//     .family<DiagnosticReport, int>((ref, id) async {
//   return ref.read(reportsDatasourceProvider).getReportById(id);
// });