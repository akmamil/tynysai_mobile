// lib/features/reports/data/reports_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_paths.dart';
import '../../../core/models/diagnostic_report.dart';
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
  /// ⚠️  Do NOT call GET /api/reports/{id} for patients — that endpoint
  ///     requires DOCTOR or ADMIN role and returns 403 for PATIENT JWTs.
  ///     The patient-scoped path validates ownership before responding.
  Future<DiagnosticReport> getReportByIdForPatient(int id) async {
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
