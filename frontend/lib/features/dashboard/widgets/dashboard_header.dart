import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';

/// DashboardHeader renders the top navigation row matching the visual reference:
/// - Left: Government of India emblem & text
/// - Center: TribalSetu mountain logo and tagline
/// - Right: Notification bell with unread badge and Student initials pill (e.g. [ AS v ])
class DashboardHeader extends StatelessWidget {
  final String initials;
  final int unreadNotificationsCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const DashboardHeader({
    super.key,
    required this.initials,
    this.unreadNotificationsCount = 0,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Government of India Emblem + Text
          Image.asset(
            AssetConstants.govtHeader,
            height: 40,
            fit: BoxFit.contain,
            semanticLabel: 'Government of India emblem',
            errorBuilder: (context, error, stackTrace) => Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.account_balance, size: 26, color: AppColors.black),
                SizedBox(width: 6),
                Text(
                  'Government\nof India',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 2. Center TribalSetu Branding
          Image.asset(
            AssetConstants.tribalSetuLogo,
            height: 38,
            fit: BoxFit.contain,
            semanticLabel: 'TribalSetu brand',
            errorBuilder: (context, error, stackTrace) => Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'TribalSetu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'One Platform. Every Opportunity.',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 3. Right Action Group: Notification Bell + Profile Avatar Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Bell with Unread Badge
              GestureDetector(
                onTap: onNotificationTap ?? () => Navigator.of(context).pushNamed('/notifications'),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_rounded,
                        color: Color(0xFF111827),
                        size: 24,
                      ),
                      if (unreadNotificationsCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Student Initials Capsule [ AS v ]
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.only(left: 3, right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // White Circle with Student Initials
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
