import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/notification_item.dart';
import 'notification_repository.dart';

/// ApiNotificationRepository implements NotificationRepository by consuming:
/// - GET /api/v1/notifications
/// - PATCH /api/v1/notifications/{id}/read
class ApiNotificationRepository implements NotificationRepository {
  final ApiClient apiClient;

  ApiNotificationRepository({required this.apiClient});

  @override
  Future<List<NotificationItem>> getNotifications() async {
    final response = await apiClient.get(ApiConstants.notifications);
    if (response.success && response.data != null) {
      final list = response.data as List<dynamic>;
      return list
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markAsRead(String id) async {
    final response = await apiClient.patch(ApiConstants.markNotificationRead(id));
    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
