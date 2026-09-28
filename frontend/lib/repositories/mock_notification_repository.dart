import '../models/notification_item.dart';
import 'notification_repository.dart';

/// MockNotificationRepository provides deterministic notification data
/// matching the exact visual target from the reference image.
///
/// Features:
/// - 7 reference notifications (3 unread, 4 read)
/// - Application-linked and system notifications
/// - In-memory state mutation on markAsRead
/// - Latency guard for widget tests
class MockNotificationRepository implements NotificationRepository {
  final Duration latency;

  MockNotificationRepository({this.latency = const Duration(milliseconds: 300)});

  static List<NotificationItem> _createInitialNotifications() {
    return [
      NotificationItem(
        id: 'notif-01',
        userId: 'TS2024S10023',
        title: 'Payment Initiated',
        message: 'Your scholarship amount of ₹48,000 has been initiated for DBT transfer to your bank account.',
        type: 'PAYMENT',
        applicationId: 'app-2024-st-01',
        isRead: false,
        createdAt: DateTime(2025, 12, 12, 16, 30),
      ),
      NotificationItem(
        id: 'notif-02',
        userId: 'TS2024S10023',
        title: 'Document Verified',
        message: 'Your Aadhaar Card has been successfully verified with UIDAI.',
        type: 'DOCUMENT',
        applicationId: 'app-2024-st-01',
        isRead: false,
        createdAt: DateTime(2025, 12, 11, 10, 15),
      ),
      NotificationItem(
        id: 'notif-03',
        userId: 'TS2024S10023',
        title: 'Application Status Updated',
        message: 'Your application TS2026ST000123 is now under verification at the district level.',
        type: 'APPLICATION',
        applicationId: 'app-2026-st-01',
        isRead: false,
        createdAt: DateTime(2025, 12, 10, 14, 20),
      ),
      NotificationItem(
        id: 'notif-04',
        userId: 'TS2024S10023',
        title: 'Profile Updated',
        message: 'Your profile information has been successfully updated.',
        type: 'PROFILE',
        applicationId: null,
        isRead: true,
        createdAt: DateTime(2025, 12, 8, 11, 45),
      ),
      NotificationItem(
        id: 'notif-05',
        userId: 'TS2024S10023',
        title: 'Document Action Required',
        message: 'Your Income Certificate could not be verified. Please check the document and re-upload if required.',
        type: 'DOCUMENT',
        applicationId: 'app-2024-st-01',
        isRead: true,
        createdAt: DateTime(2025, 12, 6, 9, 30),
      ),
      NotificationItem(
        id: 'notif-06',
        userId: 'TS2024S10023',
        title: 'Sanction Order Released',
        message: 'Your application has been sanctioned. Sanction order has been issued by the concerned department.',
        type: 'PAYMENT',
        applicationId: 'app-2024-st-01',
        isRead: true,
        createdAt: DateTime(2025, 12, 5, 15, 15),
      ),
      NotificationItem(
        id: 'notif-07',
        userId: 'TS2024S10023',
        title: 'Welcome to TribalSetu',
        message: 'Your account has been successfully created. You can now explore and apply for scholarships.',
        type: 'SYSTEM',
        applicationId: null,
        isRead: true,
        createdAt: DateTime(2025, 12, 1, 9, 0),
      ),
    ];
  }

  static List<NotificationItem> _notifications = _createInitialNotifications();

  /// Resets mock data to initial reference state (useful for tests).
  static void reset() {
    _notifications = _createInitialNotifications();
  }

  @override
  Future<List<NotificationItem>> getNotifications() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    return List.unmodifiable(_notifications);
  }

  @override
  Future<int> getUnreadCount() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markAsRead(String id) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }
}
