import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/notification_item.dart';

/// Style configuration for a notification category/type.
class _NotificationStyle {
  final Color backgroundColor;
  final Color iconColor;
  final IconData? icon;
  final String? textIcon;

  const _NotificationStyle({
    required this.backgroundColor,
    required this.iconColor,
    this.icon,
    this.textIcon,
  });
}

/// NotificationCardItem renders an individual notification card matching the visual reference.
///
/// Features:
/// - Distinct category circular badge
/// - Bold title and clean wrapped body message
/// - Exact date and time formatted from created_at
/// - Subtle blue unread indicator dot when isRead == false
/// - Clean trailing chevron
class NotificationCardItem extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onTap;

  const NotificationCardItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyle(item);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Left Circular Icon Badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: style.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: style.textIcon != null
                      ? Text(
                          style.textIcon!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: style.iconColor,
                          ),
                        )
                      : Icon(
                          style.icon,
                          size: 20,
                          color: style.iconColor,
                        ),
                ),

                const SizedBox(width: 12),

                // 2. Middle Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.1,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Message Body
                      Text(
                        item.message,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Formatted Timestamp from created_at
                      Text(
                        DateFormatter.formatDateTime(item.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 3. Right Status Area: Unread Dot + Trailing Chevron
                SizedBox(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Blue Unread Indicator Dot
                      if (!item.isRead)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(top: 2, right: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(width: 7, height: 7),

                      // Trailing Chevron
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Conservative presentation styling derived safely from notification metadata.
  static _NotificationStyle _getStyle(NotificationItem item) {
    final typeUpper = item.type.toUpperCase();
    final titleUpper = item.title.toUpperCase();

    // 1. Sanction Order (Mint Green with Rupee Symbol)
    if (typeUpper.contains('SANCTION') || titleUpper.contains('SANCTION')) {
      return const _NotificationStyle(
        backgroundColor: Color(0xFFDCFCE7),
        iconColor: Color(0xFF16A34A),
        textIcon: '₹',
      );
    }

    // 2. Payment / DBT Initiated (Soft Green with Checkmark)
    if (typeUpper.contains('PAY') ||
        typeUpper.contains('DBT') ||
        titleUpper.contains('PAYMENT') ||
        titleUpper.contains('DBT')) {
      return const _NotificationStyle(
        backgroundColor: Color(0xFFDCFCE7),
        iconColor: Color(0xFF16A34A),
        icon: Icons.check_circle_rounded,
      );
    }

    // 3. Document Action Required / Deficiency (Soft Red with Alert Doc)
    if (typeUpper.contains('DEFICIENCY') ||
        typeUpper.contains('ACTION') ||
        titleUpper.contains('ACTION REQUIRED') ||
        titleUpper.contains('REJECTED')) {
      return const _NotificationStyle(
        backgroundColor: Color(0xFFFEE2E2),
        iconColor: Color(0xFFDC2626),
        icon: Icons.assignment_late_rounded,
      );
    }

    // 4. Document Verified (Soft Amber with Document)
    if (typeUpper.contains('DOC') || titleUpper.contains('DOCUMENT')) {
      return const _NotificationStyle(
        backgroundColor: Color(0xFFFEF3C7),
        iconColor: Color(0xFFD97706),
        icon: Icons.description_rounded,
      );
    }

    // 5. Application Status / Verification (Soft Blue with Graduation Cap)
    if (typeUpper.contains('APP') ||
        typeUpper.contains('VERIF') ||
        titleUpper.contains('APPLICATION')) {
      return const _NotificationStyle(
        backgroundColor: Color(0xFFDBEAFE),
        iconColor: Color(0xFF2563EB),
        icon: Icons.school_rounded,
      );
    }

    // 6. Profile Updated (Soft Lavender with Person Icon)
    if (typeUpper.contains('PROF') || titleUpper.contains('PROFILE')) {
      return const _NotificationStyle(
        backgroundColor: Color(0xFFF3E8FF),
        iconColor: Color(0xFF9333EA),
        icon: Icons.person_rounded,
      );
    }

    // 7. Welcome / Info (Soft Blue with Info Icon)
    if (typeUpper.contains('WELC') ||
        typeUpper.contains('SYS') ||
        titleUpper.contains('WELCOME')) {
      return const _NotificationStyle(
        backgroundColor: Color(0xFFDBEAFE),
        iconColor: Color(0xFF2563EB),
        icon: Icons.info_rounded,
      );
    }

    // Default Fallback: Neutral Grey with Notification Bell
    return const _NotificationStyle(
      backgroundColor: Color(0xFFF3F4F6),
      iconColor: Color(0xFF4B5563),
      icon: Icons.notifications_outlined,
    );
  }
}
