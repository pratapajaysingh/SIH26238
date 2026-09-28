import 'package:flutter/material.dart';

/// QuickActionsSection renders the 6 primary entry actions from the visual reference:
/// 1. Find Scholarships
/// 2. My Applications
/// 3. Document Locker
/// 4. Payment Status
/// 5. Ask JAGO
/// 6. Notifications (with unread indicator dot)
class QuickActionsSection extends StatelessWidget {
  final int unreadNotificationsCount;
  final VoidCallback? onFindScholarships;
  final VoidCallback? onMyApplications;
  final VoidCallback? onDocumentLocker;
  final VoidCallback? onPaymentStatus;
  final VoidCallback? onAskJago;
  final VoidCallback? onNotifications;
  final VoidCallback? onSeeAll;

  const QuickActionsSection({
    super.key,
    this.unreadNotificationsCount = 0,
    this.onFindScholarships,
    this.onMyApplications,
    this.onDocumentLocker,
    this.onPaymentStatus,
    this.onAskJago,
    this.onNotifications,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading Row
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: Color(0xFF374151),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 6 Quick Action Items Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActionTile(
                icon: Icons.school_rounded,
                label: 'Find\nScholarships',
                onTap: onFindScholarships,
              ),
              _buildActionTile(
                icon: Icons.assignment_rounded,
                label: 'My\nApplications',
                onTap: onMyApplications,
              ),
              _buildActionTile(
                icon: Icons.description_rounded,
                badgeIcon: Icons.check_circle_rounded,
                label: 'Document\nLocker',
                onTap: onDocumentLocker,
              ),
              _buildActionTile(
                icon: Icons.currency_rupee_rounded,
                label: 'Payment\nStatus',
                onTap: onPaymentStatus,
              ),
              _buildActionTile(
                icon: Icons.smart_toy_rounded,
                label: 'Ask JAGO',
                onTap: onAskJago,
              ),
              _buildActionTile(
                icon: Icons.notifications_rounded,
                hasNotificationBadge: unreadNotificationsCount > 0,
                label: 'Notifications',
                onTap: onNotifications,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    IconData? badgeIcon,
    bool hasNotificationBadge = false,
    required String label,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 52,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Square Rounded Tile Container
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: const Color(0xFF111827),
                    ),
                    if (badgeIcon != null)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.all(0.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            badgeIcon,
                            size: 10,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                    if (hasNotificationBadge)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
