// lib/features/reports/data/reports_remote_datasource.dart
// Пока что не точный вариант


// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../core/constants/api_paths.dart';
// import '../../../core/models/diagnostic_report.dart';
// import '../../../core/network/api_exception.dart';
// import '../../../core/network/api_response.dart';
// import '../../../core/network/dio_client.dart';

// final reportsDatasourceProvider = Provider<ReportsRemoteDatasource>((ref) {
//   return ReportsRemoteDatasource(ref.watch(dioClientProvider).instance);
// });

// class ReportsRemoteDatasource {
//   ReportsRemoteDatasource(this._dio);
//   final Dio _dio;

//   /// GET /api/reports/patient?page=0&size=10
//   /// Returns a paginated list of diagnostic reports for the current patient.
//   Future<PageResponse<DiagnosticReport>> getPatientReports({
//     int page = 0,
//     int size = 10,
//   }) async {
//     try {
//       final response = await _dio.get(
//         ApiPaths.getPatientReports,
//         queryParameters: {'page': page, 'size': size},
//       );
//       final body = response.data as Map<String, dynamic>;
//       return PageResponse.fromJson(
//         body['data'] as Map<String, dynamic>,
//         DiagnosticReport.fromJson,
//       );
//     } on DioException catch (e) {
//       throw mapDioException(e);
//     }
//   }

//   /// GET /api/reports/{id}
//   Future<DiagnosticReport> getReportById(int id) async {
//     try {
//       final response = await _dio.get(ApiPaths.getReportById(id));
//       final body = response.data as Map<String, dynamic>;
//       return DiagnosticReport.fromJson(
//           body['data'] as Map<String, dynamic>);
//     } on DioException catch (e) {
//       throw mapDioException(e);
//     }
//   }
// }