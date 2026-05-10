// lib/features/reports/data/reports_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/models/diagnostic_report.dart';
import '../../../core/models/enums.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';

final reportsDatasourceProvider = Provider<ReportsRemoteDatasource>((ref) {
  return ReportsRemoteDatasource(ref.watch(dioClientProvider).instance);
});

class ReportsRemoteDatasource {
  ReportsRemoteDatasource(this._dio);
  final Dio _dio;

  /// GET /api/reports/patient?page=0&size=10
  /// Backend: DiagnosticReportController.getPatientReports()
  /// Requires: PATIENT role — gateway validates JWT before forwarding.
  Future<PageResponse<DiagnosticReport>> getPatientReports({
    int page = 0,
    int size = 10,
  }) async {
    // ── BUG FIX ─────────────────────────────────────────────────────────────
    // Was: no mock branch → isMock=false (default) hit Postman at
    //      GET /api/reports/patient → Postman has NO saved example for this
    //      endpoint → Postman returns 404 → mapDioException →
    //      NotFoundException("Resource not found") → shown in error widget.
    //
    // Fix: add mock branch returning seeded report data, identical pattern
    //      to how XrayRemoteDatasource.getPatientXrays() handles mock mode.
    // ────────────────────────────────────────────────────────────────────────
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockReportsPage;
    }

    try {
      final response = await _dio.get(
        ApiPaths.getPatientReports,
        queryParameters: {'page': page, 'size': size},
      );
      final body = response.data as Map<String, dynamic>;
      return PageResponse.fromJson(
        body['data'] as Map<String, dynamic>,
        DiagnosticReport.fromJson,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// GET /api/reports/patient/{id}
  /// Backend: DiagnosticReportController.getByIdForPatient()
  ///
  /// ⚠️ Do NOT call GET /api/reports/{id} for patients — that endpoint
  ///    requires DOCTOR or ADMIN role and returns 403 for PATIENT JWTs.
  ///    The patient-scoped path validates ownership before responding.
  Future<DiagnosticReport> getReportByIdForPatient(int id) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      // Find the matching report from the seeded list, or return the first one.
      return _mockReportsPage.content.firstWhere(
        (r) => r.id == id,
        orElse: () => _mockReportsPage.content.first,
      );
    }

    try {
      final response =
          await _dio.get(ApiPaths.getReportByIdForPatient(id));
      final body = response.data as Map<String, dynamic>;
      return DiagnosticReport.fromJson(
          body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

// ── Mock report data ───────────────────────────────────────────────────────
//
// Mirrors what the real medical-record-service would return for
// GET /api/reports/patient after a doctor validates an X-ray.
//
// report #1: corresponds to the VALIDATED X-ray (id=4) in the seeded history.
// report #2: COMPLETED X-ray (id=43 style) with a COVID-19 result.
// ─────────────────────────────────────────────────────────────────────────

final _mockReportsPage = PageResponse<DiagnosticReport>(
  content: [
    DiagnosticReport(
      id: 1,
      reportNumber: 'RPT-2024-001',
      patientId: '00000000-0000-0000-0000-000000000001',
      patientName: 'Aizat Bekova',
      doctorId: '00000000-0000-0000-0000-000000000002',
      doctorName: 'Arman Bekovich Seitkali',
      doctorSpecialization: 'Pulmonology',
      xrayAnalysisId: 4,
      labResultId: null,
      finalDiagnosis: DiseaseType.covid19,
      finalDiagnosisDisplayName: 'COVID-19',
      severity: Severity.moderate,
      severityDisplayName: 'Moderate',
      clinicalFindings:
          'Bilateral ground-glass opacities in peripheral distribution. '
          'Pattern consistent with COVID-19 viral pneumonia. '
          'No pleural effusion. Oxygen saturation borderline.',
      treatmentRecommendations:
          'Self-isolation for 10 days. Monitor oxygen saturation. '
          'Seek emergency care if SpO2 drops below 94%.',
      medicationRecommendations:
          'Paracetamol 500mg as needed for fever. '
          'Continue prescribed antiviral if applicable.',
      lifestyleRecommendations:
          'Complete bed rest. Stay hydrated. Avoid contact with vulnerable individuals.',
      followUpDate: '2024-01-28',
      reportText:
          'Patient presents with confirmed COVID-19 based on bilateral ground-glass '
          'opacities on chest X-ray and clinical presentation. AI analysis confirmed '
          'with 73% confidence. Manual review and clinical correlation performed. '
          'Prognosis is favorable with appropriate rest and monitoring.',
      sentToPatient: true,
      sentAt: '2024-01-14T15:00:00Z',
      createdAt: '2024-01-14T14:30:00Z',
      updatedAt: '2024-01-14T15:00:00Z',
    ),
    DiagnosticReport(
      id: 2,
      reportNumber: 'RPT-2024-002',
      patientId: '00000000-0000-0000-0000-000000000001',
      patientName: 'Aizat Bekova',
      doctorId: '00000000-0000-0000-0000-000000000002',
      doctorName: 'Arman Bekovich Seitkali',
      doctorSpecialization: 'Pulmonology',
      xrayAnalysisId: 5,
      labResultId: null,
      finalDiagnosis: DiseaseType.tuberculosis,
      finalDiagnosisDisplayName: 'Tuberculosis',
      severity: Severity.mild,
      severityDisplayName: 'Mild',
      clinicalFindings:
          'Possible upper lobe infiltrate identified. '
          'AI confidence below threshold (62%), requiring further investigation. '
          'No cavitation observed at this stage.',
      treatmentRecommendations:
          'Refer to TB specialist for sputum culture and Mantoux test. '
          'Do NOT begin anti-TB therapy without confirmed diagnosis.',
      medicationRecommendations: null,
      lifestyleRecommendations:
          'Avoid crowded spaces until diagnosis is confirmed.',
      followUpDate: '2024-01-21',
      reportText:
          'Inconclusive X-ray findings with possible early pulmonary tuberculosis. '
          'AI flagged the scan for review due to low confidence score. '
          'Clinical history and additional tests are required before treatment.',
      sentToPatient: false,
      sentAt: null,
      createdAt: '2024-01-13T16:00:00Z',
      updatedAt: null,
    ),
  ],
  page: 0,
  size: 10,
  totalElements: 2,
  totalPages: 1,
  isLast: true,
  isFirst: true,
);