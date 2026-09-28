import 'package:flutter/foundation.dart';
import '../../../models/notification_item.dart';
import '../../../repositories/notification_repository.dart';

/// Frontend filter categories matching the visual reference pills.
enum NotificationFilter {
  all('All'),
  unread('Unread'),
  applications('Applications'),
  payments('Payments'),
  system('System');

  final String label;
  const NotificationFilter(this.label);
}

/// NotificationsController manages notification retrieval, local category filtering,
/// and optimistic/server-backed mark-as-read updates.
///
/// Follows Clean Architecture: Screen -> Controller -> Repository -> ApiClient.
class NotificationsController extends ChangeNotifier {
  final NotificationRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<NotificationItem> _notifications = [];
  NotificationFilter _selectedFilter = NotificationFilter.all;

  NotificationsController({required NotificationRepository repository})
      : _repository = repository;

  // ── GETTERS ─────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  NotificationFilter get selectedFilter => _selectedFilter;
  List<NotificationItem> get allNotifications => List.unmodifiable(_notifications);

  /// Unread notifications count derived directly from real notification models.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Returns filtered notifications according to the active tab.
  /// Filtering is performed purely in-memory; no additional API calls are made.
  List<NotificationItem> get filteredNotifications {
    switch (_selectedFilter) {
      case NotificationFilter.all:
        return _notifications;

      case NotificationFilter.unread:
        return _notifications.where((n) => !n.isRead).toList();

      case NotificationFilter.applications:
        // Section 26: Based on documented application_id != null relationship
        return _notifications.where((n) => n.applicationId != null).toList();

      case NotificationFilter.payments:
        return _notifications.where((n) => _isPaymentNotification(n)).toList();

      case NotificationFilter.system:
        return _notifications.where((n) => _isSystemNotification(n)).toList();
    }
  }

  // ── FILTER HELPERS ──────────────────────────────────────────────────────
  bool _isPaymentNotification(NotificationItem item) {
    final typeUpper = item.type.toUpperCase();
    final titleUpper = item.title.toUpperCase();
    return typeUpper.contains('PAY') ||
        typeUpper.contains('DBT') ||
        typeUpper.contains('SANCTION') ||
        titleUpper.contains('PAYMENT') ||
        titleUpper.contains('SANCTION') ||
        titleUpper.contains('DBT');
  }

  bool _isSystemNotification(NotificationItem item) {
    final typeUpper = item.type.toUpperCase();
    final titleUpper = item.title.toUpperCase();
    final isPay = _isPaymentNotification(item);
    return typeUpper.contains('SYS') ||
        typeUpper.contains('WELCOME') ||
        typeUpper.contains('PROFILE') ||
        titleUpper.contains('WELCOME') ||
        titleUpper.contains('PROFILE') ||
        (item.applicationId == null && !isPay);
  }

  // ── ACTIONS ─────────────────────────────────────────────────────────────
  /// Loads all student notifications from GET /api/v1/notifications.
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _repository.getNotifications();
      _notifications = List.of(items);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh without showing the full skeleton loader.
  Future<void> refresh() async {
    try {
      final items = await _repository.getNotifications();
      _notifications = List.of(items);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh notifications: $e';
      notifyListeners();
    }
  }

  /// Changes the active presentation filter.
  void setFilter(NotificationFilter filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  /// Marks a notification as read via PATCH /api/v1/notifications/{id}/read.
  /// Updates local state only upon successful confirmation.
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) {
      return; // Already read or not found
    }

    try {
      await _repository.markAsRead(id);
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to mark notification as read: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
