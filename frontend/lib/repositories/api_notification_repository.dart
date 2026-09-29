import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/notification_item.dart';
import 'notification_repository.dart';

/// ApiNotificationRepository implements NotificationRepository by consuming:
/// - GET /api/v1/notifications/me
/// - PATCH /api/v1/notifications/{id}/read
class ApiNotificationRepository implements NotificationRepository {
  final ApiClient apiClient;

  ApiNotificationRepository({required this.apiClient});

  @override
  Future<List<NotificationItem>> getNotifications() async {
    // 1. Try authenticated student notifications: GET /api/v1/notifications/me
    try {
      final response = await apiClient.get<List<dynamic>>(ApiConstants.notificationsMe);
      if (response.success && response.data != null) {
        final list = response.data!;
        return list
            .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // 2. Fallback: GET /api/v1/notifications
    final fallback = await apiClient.get<List<dynamic>>(ApiConstants.notifications);
    if (fallback.success && fallback.data != null) {
      final list = fallback.data!;
      return list
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      fallback.message.isNotEmpty ? fallback.message : 'Failed to retrieve notifications',
    );
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.get<List<dynamic>>(
        ApiConstants.notificationsMe,
        queryParameters: {'unread_only': true},
      );
      if (response.success && response.data != null) {
        return response.data!.length;
      }
    } catch (_) {}
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markAsRead(String id) async {
    final response = await apiClient.patch(ApiConstants.markNotificationRead(id));
    if (!response.success) {
      throw ApiException(
        response.message.isNotEmpty ? response.message : 'Failed to mark notification as read',
      );
    }
  }
}
