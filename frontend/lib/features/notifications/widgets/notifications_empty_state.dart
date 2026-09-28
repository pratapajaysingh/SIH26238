import 'package:flutter/material.dart';
import '../controllers/notifications_controller.dart';

/// NotificationsEmptyState renders a clean contextual empty state
/// when a filter returns zero records or the student has no notifications.
class NotificationsEmptyState extends StatelessWidget {
  final NotificationFilter filter;

  const NotificationsEmptyState({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(filter);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                config.icon,
                size: 30,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              config.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              config.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static ({IconData icon, String title, String subtitle}) _getConfig(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return (
          icon: Icons.notifications_none_rounded,
          title: 'No Notifications Yet',
          subtitle: "You're all caught up! Updates regarding your scholarships and applications will appear here.",
        );
      case NotificationFilter.unread:
        return (
          icon: Icons.done_all_rounded,
          title: 'No Unread Notifications',
          subtitle: 'All your notifications have been marked as read.',
        );
      case NotificationFilter.applications:
        return (
          icon: Icons.school_outlined,
          title: 'No Application Updates',
          subtitle: 'Updates regarding your scholarship applications will appear here.',
        );
      case NotificationFilter.payments:
        return (
          icon: Icons.account_balance_wallet_outlined,
          title: 'No Payment Notifications',
          subtitle: 'Disbursement and Direct Benefit Transfer alerts will appear here.',
        );
      case NotificationFilter.system:
        return (
          icon: Icons.info_outline_rounded,
          title: 'No System Alerts',
          subtitle: 'General announcements and system notices will appear here.',
        );
    }
  }
}
