import '../models/notification_item.dart';

/// NotificationRepository defines the contract for fetching alerts and notifications.
/// Conforms to documented endpoints:
/// - GET /api/v1/notifications
/// - PATCH /api/v1/notifications/{id}/read
abstract class NotificationRepository {
  /// Fetches the list of notifications for the logged-in student.
  Future<List<NotificationItem>> getNotifications();

  /// Fetches the count of unread notifications.
  Future<int> getUnreadCount();

  /// Marks a specific notification as read.
  Future<void> markAsRead(String id);
}
