import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../models/scholarship.dart';

/// ScholarshipDiscoveryCard renders the individual scholarship card matching the visual reference:
/// - Left: Ministry panel with government emblem and institutional styling
/// - Top right: Status badge ("Ongoing" / "Closing Soon") and "Most Relevant" badge
/// - Title and description
/// - Metadata chips: Level, Audience, and Benefit
/// - Circular chevron CTA button
class ScholarshipDiscoveryCard extends StatelessWidget {
  final Scholarship scholarship;
  final VoidCallback? onTap;

  const ScholarshipDiscoveryCard({
    super.key,
    required this.scholarship,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panelColor = _getMinistryTint(scholarship.ministry);
    final isClosingSoon = scholarship.statusBadge.toLowerCase().contains('closing');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Left Ministry Badge Panel
              Container(
                width: 76,
                height: 82,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AssetConstants.emblemStandalone,
                      height: 26,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_balance,
                        size: 22,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatMinistryName(scholarship.ministry),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Government of India',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 6.2,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 2. Right Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Badges (Wrap to prevent overflow on narrow viewports)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        if (scholarship.isMostRelevant)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Most Relevant',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        // Status Badge: Ongoing (Green) or Closing Soon (Red)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isClosingSoon ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            scholarship.statusBadge,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: isClosingSoon ? const Color(0xFFDC2626) : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Scheme Title
                    Text(
                      scholarship.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Description
                    Text(
                      scholarship.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Metadata Row & Chevron Button
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.school_rounded, size: 12, color: Color(0xFF4B5563)),
                                  const SizedBox(width: 3),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 85),
                                    child: Text(
                                      scholarship.educationLevel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people_rounded, size: 12, color: Color(0xFF4B5563)),
                                  const SizedBox(width: 3),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 85),
                                    child: Text(
                                      scholarship.targetAudience,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.currency_rupee_rounded, size: 12, color: Color(0xFF4B5563)),
                                  const SizedBox(width: 1),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 105),
                                    child: Text(
                                      scholarship.benefitAmount,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action Chevron Circle
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMinistryTint(String ministry) {
    final lower = ministry.toLowerCase();
    if (lower.contains('tribal')) return const Color(0xFFFDF4ED); // Warm peach
    if (lower.contains('education')) return const Color(0xFFEFF6FF); // Soft blue
    if (lower.contains('grants') || lower.contains('ugc')) return const Color(0xFFF0FDF4); // Soft mint
    if (lower.contains('social justice')) return const Color(0xFFF5F3FF); // Soft lavender
    if (lower.contains('health')) return const Color(0xFFFFF1F2); // Soft rose
    return const Color(0xFFF3F4F6); // Neutral
  }

  String _formatMinistryName(String ministry) {
    if (ministry.contains('Ministry of Tribal Affairs')) return 'Ministry of\nTribal Affairs';
    if (ministry.contains('Ministry of Education')) return 'Ministry of\nEducation';
    if (ministry.contains('University Grants Commission')) return 'University Grants\nCommission';
    if (ministry.contains('Ministry of Social Justice')) return 'Ministry of\nSocial Justice';
    if (ministry.contains('Ministry of Health')) return 'Ministry of\nHealth & Family Welfare';
    return ministry;
  }
}
