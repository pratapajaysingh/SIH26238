import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';

/// StudentGreetingSection renders the warm personalized greeting and compact student card.
/// Left: "Good Morning, Aarav Singh 👋 \n Keep going! Your dreams matter."
/// Right: Rounded card containing student avatar, Student ID, and navigation chevron.
class StudentGreetingSection extends StatelessWidget {
  final String greeting;
  final String studentName;
  final String motivationalQuote;
  final String studentId;
  final String? avatarUrl;
  final VoidCallback? onCardTap;

  const StudentGreetingSection({
    super.key,
    required this.greeting,
    required this.studentName,
    required this.motivationalQuote,
    required this.studentId,
    this.avatarUrl,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Greeting Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '👋',
                      style: TextStyle(fontSize: 19),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  motivationalQuote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right: Student ID Pill Card
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCardTap,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar Image
                    ClipOval(
                      child: Image.asset(
                        AssetConstants.studentAvatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 40,
                          height: 40,
                          color: AppColors.grey300,
                          child: const Icon(Icons.person, color: AppColors.grey600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // ID Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Student ID',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          studentId,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 4),

                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
