// lib/features/lab_results/presentation/providers/lab_results_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/lab_result.dart';
import '../../../../core/network/api_response.dart';
import '../../data/lab_results_remote_datasource.dart';

/// Loads the first page of lab results for the current patient.
///
/// autoDispose — dropped when no widget watches it, so navigating away
/// and back always fetches fresh data. Force refresh: ref.invalidate(labResultsProvider).
final labResultsProvider =
    FutureProvider.autoDispose<PageResponse<LabResult>>((ref) async {
  return ref.read(labResultsDatasourceProvider).getPatientLabResults();
});

/// Single lab result by ID — consumed by LabResultDetailPage.
///
/// Keyed by result ID via .family so each result gets its own cache entry.
/// autoDispose clears the cache when the detail page is popped.
final labResultDetailProvider =
    FutureProvider.autoDispose.family<LabResult, int>((ref, id) async {
  return ref.read(labResultsDatasourceProvider).getLabResultById(id);
});