import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../models/student_profile.dart';

/// ProfileHeroCard renders the top profile summary card matching the visual reference:
/// - Student Avatar with camera icon overlay
/// - Full Name
/// - Student Category ("ST Student")
/// - Student ID ("Student ID: TS2024S10023")
/// - Green "Verified" pill badge
/// - Outlined "Edit Profile" pill button
class ProfileHeroCard extends StatelessWidget {
  final StudentProfile profile;
  final VoidCallback? onEditProfile;

  const ProfileHeroCard({
    super.key,
    required this.profile,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Avatar with Camera Icon Overlay
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Circular Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE5E7EB),
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AssetConstants.studentAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF111827),
                          alignment: Alignment.center,
                          child: Text(
                            profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'S',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Camera Badge (Bottom Right)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // 2. Profile Details & Action Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Full Name + Edit Profile Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          profile.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Edit Profile Button
                      GestureDetector(
                        onTap: onEditProfile,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: Color(0xFF111827),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Student Category
                  Text(
                    profile.studentTypeDisplay,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Student ID
                  Text(
                    'Student ID: ${profile.id}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Verified Pill Badge
                  if (profile.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 11,
                            color: Color(0xFF15803D),
                          ),
                          SizedBox(width: 3.5),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
