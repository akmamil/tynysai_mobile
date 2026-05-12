// lib/features/appointments/data/doctors_remote_datasource.dart
//
// Fetches the list of approved doctors for the booking doctor-selection step.
// Reuses the existing DoctorProfile model — no new model needed.
//
// Response shape from GET /api/doctors/approved:
//   { success: true, data: [ ...DoctorProfileResponse ] }
//   OR
//   { success: true, data: { content: [...], totalElements: N, ... } }
//
// Both shapes are handled defensively so the code works against the real
// backend AND the Postman mock (which may return either format).

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/models/doctor_profile.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final doctorsDatasourceProvider = Provider<DoctorsRemoteDatasource>((ref) {
  return DoctorsRemoteDatasource(ref.watch(dioClientProvider).instance);
});

/// FutureProvider — autoDispose so the list is re-fetched each time the
/// booking page opens (prevents stale doctor data between sessions).
final approvedDoctorsProvider =
    FutureProvider.autoDispose<List<DoctorProfile>>((ref) async {
  return ref.read(doctorsDatasourceProvider).getApprovedDoctors();
});

// ── Datasource ────────────────────────────────────────────────────────────────

class DoctorsRemoteDatasource {
  DoctorsRemoteDatasource(this._dio);

  final Dio _dio;

  /// GET /api/doctors/approved
  /// Returns all approved doctors visible to patients.
  Future<List<DoctorProfile>> getApprovedDoctors() async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockDoctors;
    }

    try {
      final response = await _dio.get(ApiPaths.approvedDoctors);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];

      // Handle both list and paged response shapes.
      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map(DoctorProfile.fromJson)
            .toList();
      }
      if (data is Map<String, dynamic>) {
        // PageResponse shape: { content: [...], ... }
        final content = data['content'] as List<dynamic>? ?? [];
        return content
            .cast<Map<String, dynamic>>()
            .map(DoctorProfile.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

// ── Mock seed data ─────────────────────────────────────────────────────────────
//
// Mirrors the two doctors already referenced in the appointments mock data
// so the booking flow feels consistent end-to-end in mock mode.

const _mockDoctors = [
  DoctorProfile(
    id: 1,
    userId: '00000000-0000-0000-0000-000000000002',
    email: 'arman.seitkali@tynys.kz',
    firstName: 'Arman',
    lastName: 'Seitkali',
    fullName: 'Arman Bekovich Seitkali',
    middleName: 'Bekovich',
    phoneNumber: '+7 701 123 4567',
    specialization: 'Pulmonology',
    licenseNumber: 'KZ-2018-PUL-0042',
    hospitalName: 'Almaty City Clinical Hospital',
    department: 'Pulmonology & Respiratory Medicine',
    yearsOfExperience: 12,
    bio: 'Specialist in lung diseases, respiratory infections, and chest imaging interpretation.',
    education: 'Kazakh National Medical University, 2012',
    approved: true,
    workSchedule: null,
    profileCreatedAt: '2024-01-01T00:00:00Z',
  ),
  DoctorProfile(
    id: 2,
    userId: '00000000-0000-0000-0000-000000000003',
    email: 'dinara.seitkali@tynys.kz',
    firstName: 'Dinara',
    lastName: 'Seitkali',
    fullName: 'Dinara Seitkali',
    middleName: null,
    phoneNumber: '+7 702 987 6543',
    specialization: 'General Practice',
    licenseNumber: 'KZ-2019-GP-0087',
    hospitalName: 'Almaty Family Medicine Center',
    department: 'General Practice',
    yearsOfExperience: 7,
    bio: 'Primary care physician with focus on preventive medicine and patient wellness.',
    education: 'Astana Medical University, 2017',
    approved: true,
    workSchedule: null,
    profileCreatedAt: '2024-01-02T00:00:00Z',
  ),
  DoctorProfile(
    id: 3,
    userId: '00000000-0000-0000-0000-000000000004',
    email: 'nurlan.abenov@tynys.kz',
    firstName: 'Nurlan',
    lastName: 'Abenov',
    fullName: 'Nurlan Abenov',
    middleName: null,
    phoneNumber: '+7 705 456 7890',
    specialization: 'Radiology',
    licenseNumber: 'KZ-2015-RAD-0023',
    hospitalName: 'National Oncology Center',
    department: 'Diagnostic Radiology',
    yearsOfExperience: 15,
    bio: 'Expert in diagnostic imaging, CT, MRI and chest X-ray interpretation.',
    education: 'Semey Medical University, 2009',
    approved: true,
    workSchedule: null,
    profileCreatedAt: '2024-01-03T00:00:00Z',
  ),
];
