import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../models/scholarship.dart';

/// RecommendedScholarshipCard renders the featured scholarship recommendation card.
/// Matches the reference design:
/// - Left: Ministry of Tribal Affairs emblem badge
/// - Right: "Most Relevant" pill, scheme title, description, metadata tags, and chevron CTA.
class RecommendedScholarshipCard extends StatelessWidget {
  final Scholarship? scholarship;
  final VoidCallback? onTap;
  final VoidCallback? onViewAll;

  const RecommendedScholarshipCard({
    super.key,
    this.scholarship,
    this.onTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final title = scholarship?.name ?? 'Post Matric Scholarship for ST Students';
    final description = scholarship?.description.isNotEmpty == true
        ? scholarship!.description
        : 'Financial support for higher education of ST students across India.';
    final benefit = scholarship?.benefitAmount.isNotEmpty == true
        ? scholarship!.benefitAmount
        : 'Upto ₹48,000';
    final level = scholarship?.educationLevel.isNotEmpty == true
        ? scholarship!.educationLevel
        : 'Post Matric';

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
                  'Recommended for You',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'View All',
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

          // Main Card
          Material(
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
                    // MoTA Emblem Badge
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        AssetConstants.motaBadge,
                        width: 74,
                        height: 74,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 74,
                          height: 74,
                          color: const Color(0xFFFDF4ED),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.account_balance, size: 24, color: Color(0xFF854D0E)),
                              SizedBox(height: 2),
                              Text(
                                'Ministry of\nTribal Affairs',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Card Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag & Action Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Most Relevant',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                              const Spacer(),
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

                          const SizedBox(height: 5),

                          // Title
                          Text(
                            title,
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
                            description,
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

                          // Metadata Chips Row
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.school_rounded, size: 12.5, color: Color(0xFF4B5563)),
                                  const SizedBox(width: 4),
                                  Text(
                                    level,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.people_rounded, size: 12.5, color: Color(0xFF4B5563)),
                                  SizedBox(width: 4),
                                  Text(
                                    'ST Students',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.currency_rupee_rounded, size: 12.5, color: Color(0xFF4B5563)),
                                  const SizedBox(width: 2),
                                  Text(
                                    benefit,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}
