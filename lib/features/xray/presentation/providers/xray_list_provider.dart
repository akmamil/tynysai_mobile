// lib/features/xray/presentation/providers/xray_list_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/xray_analysis.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/xray_remote_datasource.dart';

final xrayListProvider = StateNotifierProvider.autoDispose<
    XrayListNotifier, AsyncValue<PageResponse<XrayAnalysis>>>((ref) {
  final dio = ref.watch(dioClientProvider).instance;
  return XrayListNotifier(XrayRemoteDatasource(dio));
});

class XrayListNotifier
    extends StateNotifier<AsyncValue<PageResponse<XrayAnalysis>>> {
  XrayListNotifier(this._datasource) : super(const AsyncValue.loading()) {
    load();
  }

  final XrayRemoteDatasource _datasource;
  int _page = 0;
  static const _pageSize = 10;

  Future<void> load() async {
    // Only show the full loading indicator on the first load.
    // On refresh, keep the existing data visible while fetching.
    if (state is! AsyncData) {
      state = const AsyncValue.loading();
    }
    try {
      final result = await _datasource.getPatientXrays(
        page: _page,
        size: _pageSize,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Pull-to-refresh: reset to page 0 and reload.
  Future<void> refresh() {
    _page = 0;
    return load();
  }

  /// Convenience getter for the content list.
  /// Returns empty list when state is loading or error.
  List<XrayAnalysis> get items =>
      state.valueOrNull?.content ?? const [];
}