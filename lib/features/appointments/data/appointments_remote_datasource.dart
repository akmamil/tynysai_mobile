// lib/features/appointments/data/appointments_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/models/appointment.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';

final appointmentsDatasourceProvider =
    Provider<AppointmentsRemoteDatasource>((ref) {
  return AppointmentsRemoteDatasource(
    ref.watch(dioClientProvider).instance,
  );
});

class AppointmentsRemoteDatasource {
  AppointmentsRemoteDatasource(this._dio);

  final Dio _dio;

  // ── GET /api/appointments/patient ─────────────────────────────────────────
  //
  // Backend: AppointmentController.getPatientAppointments()
  // Requires: PATIENT role — gateway validates JWT before forwarding.
  // Returns: PageResponse<AppointmentResponse>
  //
  // Note: We fetch all appointments in one page (size=50) and split into
  //       upcoming/past on the client — avoids two round-trips and keeps the
  //       provider simple. For large datasets this can be paginated later.
  Future<PageResponse<Appointment>> getPatientAppointments({
    int page = 0,
    int size = 50,
  }) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 450));
      return _mockAppointmentsPage;
    }

    try {
      final response = await _dio.get(
        ApiPaths.getPatientAppointments,
        queryParameters: {'page': page, 'size': size},
      );
      final body = response.data as Map<String, dynamic>;
      return PageResponse.fromJson(
        body['data'] as Map<String, dynamic>,
        Appointment.fromJson,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── GET /api/appointments/patient/:id ─────────────────────────────────────
  //
  // Fetches a single appointment by id.  The backend verifies ownership
  // (patientId must match JWT sub) before returning the record.
  //
  // In mock mode we look up from the seeded list so the detail page can be
  // exercised without a real server.
  Future<Appointment> getAppointmentById(int id) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockAppointmentsPage.content.firstWhere(
        (a) => a.id == id,
        orElse: () => _mockAppointmentsPage.content.first,
      );
    }

    try {
      // The backend may expose GET /api/appointments/patient/{id} or just
      // GET /api/appointments/{id}. We use the patient-scoped path here to
      // stay consistent with the reports pattern. Update ApiPaths when the
      // backend contract is finalised.
      final response = await _dio.get('/api/appointments/patient/$id');
      final body = response.data as Map<String, dynamic>;
      return Appointment.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── PUT /api/appointments/:id/cancel ──────────────────────────────────────
  //
  // Backend: AppointmentController.cancelAppointment()
  // Allowed only when status == SCHEDULED.  Backend returns 409 if the
  // appointment is already completed / cancelled.
  //
  // Returns the updated Appointment on success.  In mock mode we return a
  // copy with status=CANCELLED so the UI can update immediately.
  Future<Appointment> cancelAppointment(int id) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final original = _mockAppointmentsPage.content.firstWhere(
        (a) => a.id == id,
        orElse: () => _mockAppointmentsPage.content.first,
      );
      return original.copyWith(
        status: AppointmentStatus.cancelled,
        updatedAt: DateTime.now().toIso8601String(),
      );
    }

    try {
      final response = await _dio.put(ApiPaths.cancelAppointment(id));
      final body = response.data as Map<String, dynamic>;
      return Appointment.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

// ── Mock seed data ─────────────────────────────────────────────────────────
//
// Reflects realistic TynysAI appointments:
// - 2 upcoming (SCHEDULED, future dates)
// - 1 completed (COMPLETED, past)
// - 1 cancelled (CANCELLED, past)
//
// Dates are relative to the project's May 2026 context.

final _mockAppointmentsPage = PageResponse<Appointment>(
  content: [
    Appointment(
      id: 1,
      patientId: '00000000-0000-0000-0000-000000000001',
      doctorId: '00000000-0000-0000-0000-000000000002',
      doctorName: 'Arman Bekovich Seitkali',
      doctorSpecialization: 'Pulmonology',
      appointmentDate: '2026-05-20T10:00:00Z',
      startTime: '10:00',
      endTime: '10:30',
      status: AppointmentStatus.scheduled,
      reason: 'Follow-up after COVID-19 diagnosis. '
          'Reviewing AI X-ray result #1 and treatment response.',
      notes: null,
      meetingLink: null,
      createdAt: '2026-05-11T08:30:00Z',
      updatedAt: null,
    ),
    Appointment(
      id: 2,
      patientId: '00000000-0000-0000-0000-000000000001',
      doctorId: '00000000-0000-0000-0000-000000000003',
      doctorName: 'Dinara Seitkali',
      doctorSpecialization: 'General Practice',
      appointmentDate: '2026-06-03T14:30:00Z',
      startTime: '14:30',
      endTime: '15:00',
      status: AppointmentStatus.scheduled,
      reason: 'Routine check-up and chest pain assessment.',
      notes: null,
      meetingLink: 'https://meet.tynysai.kz/session/abc123',
      createdAt: '2026-05-10T16:00:00Z',
      updatedAt: null,
    ),
    Appointment(
      id: 3,
      patientId: '00000000-0000-0000-0000-000000000001',
      doctorId: '00000000-0000-0000-0000-000000000002',
      doctorName: 'Arman Bekovich Seitkali',
      doctorSpecialization: 'Pulmonology',
      appointmentDate: '2026-04-28T11:00:00Z',
      startTime: '11:00',
      endTime: '11:30',
      status: AppointmentStatus.completed,
      reason: 'Initial consultation after X-ray upload.',
      notes: 'Patient responded well to prescribed treatment. '
          'Scheduled a follow-up in 3 weeks.',
      meetingLink: null,
      createdAt: '2026-04-20T09:00:00Z',
      updatedAt: '2026-04-28T11:35:00Z',
    ),
    Appointment(
      id: 4,
      patientId: '00000000-0000-0000-0000-000000000001',
      doctorId: '00000000-0000-0000-0000-000000000003',
      doctorName: 'Dinara Seitkali',
      doctorSpecialization: 'General Practice',
      appointmentDate: '2026-04-10T09:00:00Z',
      startTime: '09:00',
      endTime: '09:30',
      status: AppointmentStatus.cancelled,
      reason: 'Annual physical examination.',
      notes: null,
      meetingLink: null,
      createdAt: '2026-04-01T14:00:00Z',
      updatedAt: '2026-04-08T10:00:00Z',
    ),
  ],
  page: 0,
  size: 50,
  totalElements: 4,
  totalPages: 1,
  isLast: true,
  isFirst: true,
);
