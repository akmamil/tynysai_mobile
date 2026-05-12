// lib/features/appointments/presentation/providers/book_appointment_provider.dart
//
// Mirrors the XrayUploadNotifier pattern exactly:
//   sealed state class → StateNotifier → StateNotifierProvider.autoDispose
//
// BookingState lifecycle:
//   BookingIdle       — Initial state and state after reset().
//   BookingLoading    — POST /api/appointments in flight.
//   BookingSuccess    — Server responded 200/201. Holds the created Appointment.
//   BookingError      — Request failed. Holds user-visible message.
//
// Usage from BookAppointmentPage:
//   ref.listen<BookingState>(bookAppointmentProvider, (_, next) {
//     if (next is BookingSuccess) { ... navigate ... }
//   });
//   ref.read(bookAppointmentProvider.notifier).book(request);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/appointment.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/appointments_remote_datasource.dart';
import 'appointments_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BookingState — sealed class
// ─────────────────────────────────────────────────────────────────────────────

sealed class BookingState {
  const BookingState();
}

class BookingIdle extends BookingState {
  const BookingIdle();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingSuccess extends BookingState {
  const BookingSuccess(this.appointment);
  final Appointment appointment;
}

class BookingError extends BookingState {
  const BookingError(this.message);
  final String message;
}

// ─────────────────────────────────────────────────────────────────────────────
// BookingNotifier
// ─────────────────────────────────────────────────────────────────────────────

final bookAppointmentProvider = StateNotifierProvider.autoDispose<
    BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref);
});

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier(this._ref) : super(const BookingIdle());

  final Ref _ref;

  /// Submits the booking. On success, invalidates the appointments list so
  /// AppointmentsPage is fresh when the user pops back.
  Future<void> book(BookAppointmentRequest request) async {
    // Guard: prevent double submission.
    if (state is BookingLoading) return;

    state = const BookingLoading();

    try {
      final appointment = await _ref
          .read(appointmentsDatasourceProvider)
          .bookAppointment(request);

      // Invalidate the list so it auto-refreshes when the user returns.
      _ref.invalidate(appointmentsProvider);

      if (mounted) state = BookingSuccess(appointment);
    } on ApiException catch (e) {
      if (mounted) state = BookingError(e.message);
    } catch (e) {
      if (mounted) {
        state = BookingError(
          e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
      }
    }
  }

  /// Resets to idle. Call after navigation on success, or after dismissing
  /// the error message on failure.
  void reset() => state = const BookingIdle();
}
