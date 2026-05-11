// lib/features/appointments/presentation/providers/appointments_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/appointment.dart';
import '../../../../core/network/api_response.dart';
import '../../data/appointments_remote_datasource.dart';

// ─────────────────────────────────────────────────────────────────────────────
// appointmentsProvider
// ─────────────────────────────────────────────────────────────────────────────
// Loads the full appointment list for the current patient.
//
// autoDispose: refreshes when the user navigates away and back (no stale data).
// Force-refresh from UI: ref.invalidate(appointmentsProvider).
final appointmentsProvider =
    FutureProvider.autoDispose<PageResponse<Appointment>>((ref) async {
  return ref.read(appointmentsDatasourceProvider).getPatientAppointments();
});

// ─────────────────────────────────────────────────────────────────────────────
// appointmentDetailProvider
// ─────────────────────────────────────────────────────────────────────────────
// Single appointment by ID — consumed by AppointmentDetailPage.
//
// Keyed by appointment ID via .family so each appointment gets its own cache.
// autoDispose clears the entry when the detail page is popped.
final appointmentDetailProvider =
    FutureProvider.autoDispose.family<Appointment, int>((ref, id) async {
  return ref.read(appointmentsDatasourceProvider).getAppointmentById(id);
});

// ─────────────────────────────────────────────────────────────────────────────
// CancelAppointmentNotifier
// ─────────────────────────────────────────────────────────────────────────────
// Manages the loading / error / success lifecycle for the cancel action.
//
// Usage from UI:
//   final success = await ref
//       .read(cancelAppointmentProvider.notifier)
//       .cancel(appointmentId);
//
// After success, the notifier invalidates both the list and the specific
// detail provider so any open screens automatically rebuild with fresh data.

class CancelAppointmentNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Idle on creation — no initial async work needed.
  }

  /// Cancels the appointment with [id].
  /// Returns `true` on success, `false` if an error occurred.
  Future<bool> cancel(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(appointmentsDatasourceProvider).cancelAppointment(id);
    });

    if (state is! AsyncError) {
      // Invalidate list so AppointmentsPage rebuilds on next watch.
      ref.invalidate(appointmentsProvider);
      // Invalidate the specific detail cache entry if the detail page is open.
      ref.invalidate(appointmentDetailProvider(id));
      return true;
    }
    return false;
  }
}

final cancelAppointmentProvider =
    AsyncNotifierProvider<CancelAppointmentNotifier, void>(
  CancelAppointmentNotifier.new,
);
