// lib/features/notifications/data/notifications_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../core/config/app_env.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/models/notification.dart';
import '../../../core/network/api_response.dart';

class NotificationsRemoteDatasource {
  NotificationsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<PageResponse<AppNotification>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockNotificationsPage;
    }
    try {
      final response = await _dio.get(
        ApiPaths.getNotifications,
        queryParameters: {'page': page, 'size': size},
      );
      final body = response.data as Map<String, dynamic>;
      return PageResponse.fromJson(
        body['data'] as Map<String, dynamic>,
        AppNotification.fromJson,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> markAsRead(int id) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    try {
      await _dio.post(ApiPaths.markNotificationRead(id));
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

const _mockNotificationsPage = PageResponse<AppNotification>(
  content: [
    AppNotification(
      id: 1,
      userId: '00000000-0000-0000-0000-000000000001',
      type: 'ANALYSIS_COMPLETED',
      params: const {'doctorName': 'Arman Seitkali'},
      read: false,
      relatedEntityId: '3',
      relatedEntityType: 'XRAY_ANALYSIS',
      readAt: null,
      createdAt: '2024-01-15T10:30:00Z',
    ),
    AppNotification(
      id: 2,
      userId: '00000000-0000-0000-0000-000000000001',
      type: 'ANALYSIS_REQUIRES_REVIEW',
      params: const {'confidence': '62%'},
      read: true,
      relatedEntityId: '5',
      relatedEntityType: 'XRAY_ANALYSIS',
      readAt: '2024-01-14T16:00:00Z',
      createdAt: '2024-01-13T15:00:20Z',
    ),
  ],
  page: 0,
  size: 20,
  totalElements: 2,
  totalPages: 1,
  isLast: true,
  isFirst: true,
);