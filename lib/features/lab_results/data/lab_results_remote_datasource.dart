// lib/features/lab_results/data/lab_results_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/models/lab_result.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';

final labResultsDatasourceProvider = Provider<LabResultsRemoteDatasource>((ref) {
  return LabResultsRemoteDatasource(ref.watch(dioClientProvider).instance);
});

class LabResultsRemoteDatasource {
  LabResultsRemoteDatasource(this._dio);
  final Dio _dio;

  /// GET /api/lab-results/patient?page=0&size=10
  /// Returns the current patient's lab results, newest first.
  Future<PageResponse<LabResult>> getPatientLabResults({
    int page = 0,
    int size = 20,
  }) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 450));
      return _mockLabResultsPage;
    }

    try {
      final response = await _dio.get(
        ApiPaths.getPatientLabResults,
        queryParameters: {'page': page, 'size': size},
      );
      final body = response.data as Map<String, dynamic>;
      return PageResponse.fromJson(
        body['data'] as Map<String, dynamic>,
        LabResult.fromJson,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// GET /api/lab-results/patient/{id}
  /// Ownership-checked: the gateway validates the JWT's patient claim.
  Future<LabResult> getLabResultById(int id) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockLabResultsPage.content.firstWhere(
        (r) => r.id == id,
        orElse: () => _mockLabResultsPage.content.first,
      );
    }

    try {
      final response = await _dio.get(ApiPaths.getLabResultById(id));
      final body = response.data as Map<String, dynamic>;
      return LabResult.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock data — realistic clinical lab results for patient Aizat Bekova
// ─────────────────────────────────────────────────────────────────────────────
//
// Three panels ordered by the same doctor during a follow-up for the
// COVID-19 diagnosis in the mock reports dataset (labResultId link).
//
// Result #1  — CBC  (COMPLETED, 2 abnormal)
// Result #2  — BMP  (COMPLETED, 1 abnormal)
// Result #3  — Lipid Panel (COMPLETED, 2 abnormal)
// ─────────────────────────────────────────────────────────────────────────────

final _mockLabResultsPage = PageResponse<LabResult>(
  content: [
    // ── 1. Complete Blood Count ───────────────────────────────────────────
    LabResult(
      id: 1,
      labNumber: 'LAB-2024-001',
      patientId: '00000000-0000-0000-0000-000000000001',
      patientName: 'Aizat Bekova',
      doctorId: '00000000-0000-0000-0000-000000000002',
      doctorName: 'Arman Bekovich Seitkali',
      doctorSpecialization: 'Pulmonology',
      testName: 'Complete Blood Count',
      testType: LabTestType.completeBloodCount,
      status: LabResultStatus.completed,
      orderedAt: '2024-01-14T09:00:00Z',
      resultDate: '2024-01-14T13:30:00Z',
      notes:
          'Elevated WBC consistent with active infection. '
          'Recommend repeat CBC in 2 weeks after completing antibiotic course.',
      items: const [
        LabResultItem(
          id: 101,
          name: 'White Blood Cells (WBC)',
          value: '11.2',
          unit: 'K/µL',
          referenceRange: '4.5–11.0',
          status: LabItemStatus.high,
        ),
        LabResultItem(
          id: 102,
          name: 'Red Blood Cells (RBC)',
          value: '4.8',
          unit: 'M/µL',
          referenceRange: '4.5–5.5',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 103,
          name: 'Hemoglobin',
          value: '13.2',
          unit: 'g/dL',
          referenceRange: '12.0–17.5',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 104,
          name: 'Hematocrit',
          value: '39.5',
          unit: '%',
          referenceRange: '36.0–52.0',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 105,
          name: 'Platelets',
          value: '185',
          unit: 'K/µL',
          referenceRange: '150–400',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 106,
          name: 'Neutrophils',
          value: '78.4',
          unit: '%',
          referenceRange: '45.0–70.0',
          status: LabItemStatus.high,
        ),
        LabResultItem(
          id: 107,
          name: 'Lymphocytes',
          value: '16.2',
          unit: '%',
          referenceRange: '20.0–45.0',
          status: LabItemStatus.low,
        ),
      ],
    ),

    // ── 2. Basic Metabolic Panel ──────────────────────────────────────────
    LabResult(
      id: 2,
      labNumber: 'LAB-2024-002',
      patientId: '00000000-0000-0000-0000-000000000001',
      patientName: 'Aizat Bekova',
      doctorId: '00000000-0000-0000-0000-000000000002',
      doctorName: 'Arman Bekovich Seitkali',
      doctorSpecialization: 'Pulmonology',
      testName: 'Basic Metabolic Panel',
      testType: LabTestType.basicMetabolicPanel,
      status: LabResultStatus.completed,
      orderedAt: '2024-01-14T09:00:00Z',
      resultDate: '2024-01-14T14:00:00Z',
      notes:
          'Mild hypokalemia noted, likely due to reduced oral intake during illness. '
          'Consider potassium supplementation. Monitor closely.',
      items: const [
        LabResultItem(
          id: 201,
          name: 'Glucose',
          value: '96',
          unit: 'mg/dL',
          referenceRange: '70–100',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 202,
          name: 'Blood Urea Nitrogen (BUN)',
          value: '18',
          unit: 'mg/dL',
          referenceRange: '7–25',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 203,
          name: 'Creatinine',
          value: '0.9',
          unit: 'mg/dL',
          referenceRange: '0.7–1.3',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 204,
          name: 'Sodium (Na⁺)',
          value: '139',
          unit: 'mEq/L',
          referenceRange: '136–145',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 205,
          name: 'Potassium (K⁺)',
          value: '3.2',
          unit: 'mEq/L',
          referenceRange: '3.5–5.1',
          status: LabItemStatus.low,
        ),
        LabResultItem(
          id: 206,
          name: 'Carbon Dioxide (CO₂)',
          value: '23',
          unit: 'mEq/L',
          referenceRange: '22–29',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 207,
          name: 'Calcium (Ca²⁺)',
          value: '9.4',
          unit: 'mg/dL',
          referenceRange: '8.5–10.5',
          status: LabItemStatus.normal,
        ),
      ],
    ),

    // ── 3. Lipid Panel ────────────────────────────────────────────────────
    LabResult(
      id: 3,
      labNumber: 'LAB-2024-003',
      patientId: '00000000-0000-0000-0000-000000000001',
      patientName: 'Aizat Bekova',
      doctorId: '00000000-0000-0000-0000-000000000002',
      doctorName: 'Arman Bekovich Seitkali',
      doctorSpecialization: 'Pulmonology',
      testName: 'Lipid Panel',
      testType: LabTestType.lipidPanel,
      status: LabResultStatus.completed,
      orderedAt: '2024-01-21T10:00:00Z',
      resultDate: '2024-01-21T15:00:00Z',
      notes:
          'Borderline-high total cholesterol and elevated LDL. '
          'Recommend dietary modification and reassess in 3 months. '
          'Statin therapy not indicated at this time.',
      items: const [
        LabResultItem(
          id: 301,
          name: 'Total Cholesterol',
          value: '212',
          unit: 'mg/dL',
          referenceRange: '<200',
          status: LabItemStatus.high,
        ),
        LabResultItem(
          id: 302,
          name: 'LDL Cholesterol',
          value: '138',
          unit: 'mg/dL',
          referenceRange: '<130',
          status: LabItemStatus.high,
        ),
        LabResultItem(
          id: 303,
          name: 'HDL Cholesterol',
          value: '52',
          unit: 'mg/dL',
          referenceRange: '>40',
          status: LabItemStatus.normal,
        ),
        LabResultItem(
          id: 304,
          name: 'Triglycerides',
          value: '148',
          unit: 'mg/dL',
          referenceRange: '<150',
          status: LabItemStatus.normal,
        ),
      ],
    ),
  ],
  page: 0,
  size: 20,
  totalElements: 3,
  totalPages: 1,
  isLast: true,
  isFirst: true,
);