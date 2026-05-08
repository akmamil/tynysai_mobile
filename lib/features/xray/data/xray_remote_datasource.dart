// lib/features/xray/data/xray_remote_datasource.dart

import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/config/app_env.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/models/xray_analysis.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_exception.dart';
import 'mock_xray_state_machine.dart';
import '../../../core/models/enums.dart';

class XrayRemoteDatasource {
  XrayRemoteDatasource(this._dio);
  final Dio _dio;

  Future<PageResponse<XrayAnalysis>> getPatientXrays({
  int page = 0,
  int size = 10,
}) async {
  if (AppEnv.isMock) {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockXrayHistoryPage;
  }
  try {
    final response = await _dio.get(
      ApiPaths.getPatientXrays,
      queryParameters: {'page': page, 'size': size},
    );
    final body = response.data as Map<String, dynamic>;
    return PageResponse.fromJson(
      body['data'] as Map<String, dynamic>,
      XrayAnalysis.fromJson,
    );
  } on DioException catch (e) {
    throw mapDioException(e);
  }
}

  Future<XrayAnalysis> getXrayById(int id) async {
    // For mock-generated IDs (>= 100), the state machine handles transitions.
    // For pre-seeded Postman IDs (1–6), fall through to HTTP.
    if (AppEnv.isMock) {
      final mockState = MockXrayStateMachine.instance.getState(id);
      if (mockState != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        return mockState;
      }
    }
    try {
      final response = await _dio.get(ApiPaths.getXrayById(id));
      final body = response.data as Map<String, dynamic>;
      return XrayAnalysis.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<XrayAnalysis> uploadXray({
    required File file,
    String? patientNotes,
    String? assignedDoctorId,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 1200));
      final id = MockXrayStateMachine.instance.registerUpload(
        patientNotes: patientNotes,
        assignedDoctorId: assignedDoctorId,
      );
      return MockXrayStateMachine.instance.getState(id)!;
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        if (patientNotes != null) 'patientNotes': patientNotes,
        if (assignedDoctorId != null) 'assignedDoctorId': assignedDoctorId,
      });

      final response = await _dio.post(
        ApiPaths.patientUploadXray,
        data: formData,
        onSendProgress: onProgress,
        options: Options(
          headers: {'x-mock-response-delay': '1200'},
        ),
      );

      final body = response.data as Map<String, dynamic>;
      return XrayAnalysis.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> deleteXray(int id) async {
    try {
      await _dio.delete(ApiPaths.deleteXray(id));
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

// Pre-seeded mock history — mirrors the Postman /api/xrays/patient response.
final _mockXrayHistoryPage = PageResponse<XrayAnalysis>(
  content: [
    XrayAnalysis(
      id: 4,
      patientId: '00000000-0000-0000-0000-000000000001',
      patientName: 'Aizat Bekova',
      originalFileName: 'old_scan.jpg',
      contentType: 'image/jpeg',
      fileSizeBytes: 480000,
      status: AnalysisStatus.validated,
      aiPrimaryDiagnosis: DiseaseType.covid19,
      aiPrimaryDiagnosisDisplayName: 'COVID-19',
      aiConfidence: 0.73,
      aiFindings: 'Bilateral ground-glass opacities.',
      aiDetectedAbnormalities: 'Bilateral ground-glass opacities',
      aiAllPredictionsJson: null,
      assignedDoctorId: '00000000-0000-0000-0000-000000000002',
      assignedDoctorName: 'Arman Bekovich Seitkali',
      validatedByDoctorId: '00000000-0000-0000-0000-000000000002',
      validatedByDoctorName: 'Arman Bekovich Seitkali',
      doctorDiagnosis: DiseaseType.covid19,
      doctorDiagnosisDisplayName: 'COVID-19',
      doctorNotes: 'AI diagnosis confirmed.',
      validatedAt: '2024-01-14T14:30:00Z',
      patientNotes: null,
      uploadedAt: '2024-01-14T08:00:00Z',
      analyzedAt: '2024-01-14T08:00:22Z',
    ),
    XrayAnalysis(
      id: 5,
      patientId: '00000000-0000-0000-0000-000000000001',
      patientName: 'Aizat Bekova',
      originalFileName: 'review_needed.jpg',
      contentType: 'image/jpeg',
      fileSizeBytes: 530000,
      status: AnalysisStatus.requiresReview,
      aiPrimaryDiagnosis: DiseaseType.tuberculosis,
      aiPrimaryDiagnosisDisplayName: 'Tuberculosis',
      aiConfidence: 0.62,
      aiFindings: 'Possible upper lobe infiltrate.',
      aiDetectedAbnormalities: 'Possible upper lobe infiltrate',
      aiAllPredictionsJson: null,
      assignedDoctorId: '00000000-0000-0000-0000-000000000002',
      assignedDoctorName: 'Arman Bekovich Seitkali',
      validatedByDoctorId: null,
      validatedByDoctorName: null,
      doctorDiagnosis: null,
      doctorDiagnosisDisplayName: null,
      doctorNotes: null,
      validatedAt: null,
      patientNotes: null,
      uploadedAt: '2024-01-13T15:00:00Z',
      analyzedAt: '2024-01-13T15:00:19Z',
    ),
  ],
  page: 0,
  size: 10,
  totalElements: 2,
  totalPages: 1,
  isLast: true,
  isFirst: true,
);