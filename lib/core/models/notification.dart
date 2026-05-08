// lib/core/models/notification.dart

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,       // NotificationType enum string: 'ANALYSIS_COMPLETED' etc.
    required this.read,
    required this.createdAt,
    this.params,              // Map<String, String> — i18n substitution values
    this.relatedEntityId,     // xray ID, appointment ID etc.
    this.relatedEntityType,   // 'XRAY_ANALYSIS' | 'APPOINTMENT' etc.
    this.readAt,
  });

  final int id;
  final String userId;
  final String type;
  final Map<String, String>? params;
  final bool read;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final String? readAt;
  final String createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // params arrives as Map<String, dynamic> from JSON — cast values to String
    Map<String, String>? params;
    final rawParams = json['params'];
    if (rawParams is Map) {
      params = rawParams.map(
        (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
      );
    }

    return AppNotification(
      id: json['id'] as int,
      userId: json['userId'] as String,
      type: json['type'] as String,
      params: params,
      read: json['read'] as bool,
      relatedEntityId: json['relatedEntityId'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}