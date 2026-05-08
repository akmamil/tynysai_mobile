// lib/features/xray/presentation/providers/xray_upload_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/xray_remote_datasource.dart';

// ── Upload state sealed class ──────────────────────────────────────────────────
//
// Four states model the full upload lifecycle:
//
//   UploadIdle       → No upload in progress. Initial state. Also after reset().
//   UploadInProgress → File is being sent. progress ∈ [0.0, 1.0].
//   UploadSuccess    → Upload completed. xrayId is the backend-assigned ID.
//                      XrayResultPage uses this ID to start polling.
//   UploadError      → Upload failed. message contains the user-visible error.
//
// The UploadXrayPage watches this provider:
//   • UploadInProgress → show progress bar, disable the submit button
//   • UploadSuccess    → navigate to /xray/$xrayId, then call notifier.reset()
//   • UploadError      → show SnackBar, then call notifier.reset()
// ──────────────────────────────────────────────────────────────────────────────
sealed class UploadState {
  const UploadState();
}

class UploadIdle extends UploadState {
  const UploadIdle();
}

class UploadInProgress extends UploadState {
  const UploadInProgress(this.progress);

  /// Upload progress from 0.0 (not started) to 1.0 (fully sent).
  /// Note: the server may still be processing after progress reaches 1.0.
  final double progress;
}

class UploadSuccess extends UploadState {
  const UploadSuccess(this.xrayId);

  /// The ID returned by the backend (or MockXrayStateMachine in mock mode).
  /// Navigate to /xray/$xrayId to start the polling result page.
  final int xrayId;
}

class UploadError extends UploadState {
  const UploadError(this.message);
  final String message;
}

// ── Provider ──────────────────────────────────────────────────────────────────
final xrayUploadProvider =
    StateNotifierProvider.autoDispose<XrayUploadNotifier, UploadState>((ref) {
  final dio = ref.watch(dioClientProvider).instance;
  return XrayUploadNotifier(XrayRemoteDatasource(dio));
});

class XrayUploadNotifier extends StateNotifier<UploadState> {
  XrayUploadNotifier(this._datasource) : super(const UploadIdle());

  final XrayRemoteDatasource _datasource;

  /// Start the upload. Call only from UploadXrayPage after validation.
  Future<void> upload({
    required File file,
    String? patientNotes,
    String? assignedDoctorId,
  }) async {
    // Guard: prevent double submission.
    if (state is UploadInProgress) return;

    state = const UploadInProgress(0);

    try {
      final result = await _datasource.uploadXray(
        file: file,
        patientNotes: patientNotes?.trim().isEmpty == true
            ? null
            : patientNotes?.trim(),
        assignedDoctorId: assignedDoctorId,
        onProgress: (sent, total) {
          if (mounted && total > 0) {
            state = UploadInProgress(sent / total);
          }
        },
      );

      if (mounted) {
        state = UploadSuccess(result.id);
      }
    } catch (e) {
      if (mounted) {
        // Strip "Exception:" prefix that Dart adds when calling .toString()
        final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        state = UploadError(msg);
      }
    }
  }

  /// Reset to idle. Call after navigation on success, or after showing the
  /// error SnackBar on failure. Required because the provider is autoDispose —
  /// if the page pops before reset(), a new page that watches this provider
  /// will start in UploadIdle automatically, but calling reset() explicitly
  /// makes the lifecycle intent clear.
  void reset() => state = const UploadIdle();
}