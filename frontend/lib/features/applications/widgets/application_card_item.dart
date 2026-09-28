import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../models/application.dart';
import 'application_timeline_widget.dart';

/// ApplicationCardItem renders an individual scholarship application tracking card
/// matching the exact layout, colors, badges, and horizontal milestone tracker from the reference image.
class ApplicationCardItem extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;

  const ApplicationCardItem({
    super.key,
    required this.application,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panelColor = _getPanelColor(application);
    final shortTitle = _getShortSchemeTitle(application);
    final ministry = _getMinistryDisplay(application);
    final statusText = application.displayStatus;
    final badgeColors = _getStatusColors(statusText);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Left Emblem & Ministry Panel
                  Container(
                    width: 78,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AssetConstants.emblemStandalone,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.account_balance,
                            size: 24,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          shortTitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ministry,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 6.8,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4B5563),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
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

                  // 2. Right Content & Timeline Area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Scheme Title & Status Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                application.schemeName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: badgeColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: badgeColors.text,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Row 2: Metadata (Application ID, Applied Date) + Action Button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Application ID: ${application.applicationNumber}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Applied on ${_formatDate(application.submittedAt)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Row 3: Horizontal 4-Stage Timeline Tracker
                        if (application.timeline != null && application.timeline!.isNotEmpty)
                          ApplicationTimelineWidget(events: application.timeline!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPanelColor(Application app) {
    final code = app.schemeCode.toUpperCase();
    if (code.contains('PMS') || code.contains('POST_MATRIC')) {
      return const Color(0xFFFDEEE6); // Peach
    } else if (code.contains('TOP_CLASS') || code.contains('TCS')) {
      return const Color(0xFFEBF3FC); // Soft Light Blue
    } else if (code.contains('FELLOWSHIP') || code.contains('NF')) {
      return const Color(0xFFEAF5EF); // Soft Mint
    } else if (code.contains('PRE_MATRIC') || code.contains('PRE')) {
      return const Color(0xFFF1F0F7); // Soft Lavender/Grey
    } else if (code.contains('OVERSEAS') || code.contains('NOS')) {
      return const Color(0xFFFDF0F0); // Soft Pink
    }
    return const Color(0xFFF3F4F6);
  }

  String _getShortSchemeTitle(Application app) {
    final code = app.schemeCode.toUpperCase();
    if (code.contains('PMS') || code.contains('POST_MATRIC')) {
      return 'Post Matric\nScholarship';
    } else if (code.contains('TOP_CLASS') || code.contains('TCS')) {
      return 'Top Class\nEducation Scheme';
    } else if (code.contains('FELLOWSHIP') || code.contains('NF')) {
      return 'National Fellowship';
    } else if (code.contains('PRE_MATRIC') || code.contains('PRE')) {
      return 'Pre Matric\nScholarship';
    } else if (code.contains('OVERSEAS') || code.contains('NOS')) {
      return 'National Overseas\nScholarship';
    }
    return app.schemeName;
  }

  String _getMinistryDisplay(Application app) {
    if (app.ministryName != null && app.ministryName!.isNotEmpty) {
      return app.ministryName!;
    }
    final code = app.schemeCode.toUpperCase();
    if (code.contains('TOP_CLASS') || code.contains('TCS')) {
      return 'Ministry of Education';
    } else if (code.contains('PRE_MATRIC') || code.contains('PRE')) {
      return 'Ministry of Social Justice';
    }
    return 'Ministry of Tribal Affairs';
  }

  _BadgeColors _getStatusColors(String status) {
    switch (status) {
      case 'Under Review':
        return const _BadgeColors(
          background: Color(0xFFDCFCE7),
          text: Color(0xFF15803D),
        );
      case 'In Progress':
        return const _BadgeColors(
          background: Color(0xFFDBEAFE),
          text: Color(0xFF1D4ED8),
        );
      case 'Documents Required':
        return const _BadgeColors(
          background: Color(0xFFFEF3C7),
          text: Color(0xFFD97706),
        );
      case 'Rejected':
        return const _BadgeColors(
          background: Color(0xFFFEE2E2),
          text: Color(0xFFDC2626),
        );
      case 'Completed':
        return const _BadgeColors(
          background: Color(0xFFDCFCE7),
          text: Color(0xFF15803D),
        );
      default:
        return const _BadgeColors(
          background: Color(0xFFF3F4F6),
          text: Color(0xFF4B5563),
        );
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
  }
}

class _BadgeColors {
  final Color background;
  final Color text;
  const _BadgeColors({required this.background, required this.text});
}
