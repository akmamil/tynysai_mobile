// lib/features/xray/presentation/providers/xray_detail_provider.dart
// This is the POLLING provider — critical for async AI analysis.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/enums.dart';          
import '../../../../core/models/xray_analysis.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/xray_remote_datasource.dart';

final xrayDetailProvider = StateNotifierProvider.autoDispose
    .family<XrayDetailNotifier, AsyncValue<XrayAnalysis>, int>((ref, id) {
  final dio = ref.watch(dioClientProvider).instance;
  final datasource = XrayRemoteDatasource(dio);
  return XrayDetailNotifier(datasource, id);
});

class XrayDetailNotifier extends StateNotifier<AsyncValue<XrayAnalysis>> {
  XrayDetailNotifier(this._datasource, this._id)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final XrayRemoteDatasource _datasource;
  final int _id;
  Timer? _pollTimer;
  int _pollAttempts = 0;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final analysis = await _datasource.getXrayById(_id);
      state = AsyncValue.data(analysis);
      _startPollingIfNeeded(analysis);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── FIXED: reset poll state before reloading ───────────────────────────────
  // Without this, calling refresh() after maxAttempts exhaustion never restarts
  // polling — the counter stays at 15 and _startPollingIfNeeded exits immediately.
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> refresh() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollAttempts = 0;
    return _load();
  }

  void _startPollingIfNeeded(XrayAnalysis analysis) {
    if (analysis.status.isProcessing &&
        _pollAttempts < AppConstants.xrayPollingMaxAttempts) {
      _pollTimer = Timer(AppConstants.xrayPollingInterval, () async {
        if (!mounted) return;
        _pollAttempts++;
        try {
          final updated = await _datasource.getXrayById(_id);
          if (!mounted) return;
          state = AsyncValue.data(updated);
          _startPollingIfNeeded(updated);
        } catch (_) {
          // Don't crash polling on a transient network failure.
          // Schedule the next attempt using the last known state.
          if (mounted && _pollAttempts < AppConstants.xrayPollingMaxAttempts) {
            _startPollingIfNeeded(state.valueOrNull ?? analysis);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}