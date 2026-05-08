// lib/features/notifications/presentation/providers/notifications_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/notification.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/notifications_remote_datasource.dart';

final notificationsDatasourceProvider =
    Provider.autoDispose<NotificationsRemoteDatasource>((ref) {
  return NotificationsRemoteDatasource(ref.watch(dioClientProvider).instance);
});

final notificationsProvider =
    FutureProvider.autoDispose<PageResponse<AppNotification>>((ref) {
  return ref.watch(notificationsDatasourceProvider).getNotifications();
});
