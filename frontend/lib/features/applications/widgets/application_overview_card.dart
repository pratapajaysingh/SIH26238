import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/enums/application_status.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/application.dart';

/// ApplicationOverviewCard renders the top overview card from the reference image:
/// - Emblem badge
/// - Scheme Name & Ministry
/// - Status pill with green dot (e.g. Under Verification)
/// - 3 columns: Application Number | Academic Year | Applied On
class ApplicationOverviewCard extends StatelessWidget {
  final Application? application;

  const ApplicationOverviewCard({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final app = application;
    final schemeName = app?.schemeName ?? 'Post Matric Scholarship for ST Students';
    final ministry = app?.ministryName ?? 'Ministry of Tribal Affairs';
    final appNumber = app?.applicationNumber ?? 'TS2024ST001567';
    final academicYear = app?.academicYear ?? '2024 - 2025';
    final appliedOn = app?.submittedAt != null ? DateFormatter.formatDate(app!.submittedAt) : '12 Aug 2024';

    final statusConfig = _getStatusConfig(app?.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Emblem, Scheme Name, Ministry & Status Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emblem Container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    AssetConstants.emblemStandalone,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.account_balance_rounded,
                      size: 26,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Scheme Name and Ministry
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schemeName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$ministry\nGovernment of India',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusConfig.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusConfig.textColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusConfig.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusConfig.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 14),

            // Bottom Section: 3-column metadata
            Row(
              children: [
                // Col 1: Application Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Application Number',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        appNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider 1
                Container(
                  width: 1,
                  height: 28,
                  color: const Color(0xFFE5E7EB),
                ),

                // Col 2: Academic Year
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Academic Year',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          academicYear,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Vertical Divider 2
                Container(
                  width: 1,
                  height: 28,
                  color: const Color(0xFFE5E7EB),
                ),

                // Col 3: Applied On
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Applied On',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          appliedOn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ({Color background, Color textColor, String label}) _getStatusConfig(ApplicationStatus? status) {
    if (status == null || status == ApplicationStatus.inVerification) {
      return (
        background: const Color(0xFFDCFCE7),
        textColor: const Color(0xFF15803D),
        label: 'Under Verification',
      );
    }
    switch (status) {
      case ApplicationStatus.submitted:
        return (
          background: const Color(0xFFEFF6FF),
          textColor: const Color(0xFF2563EB),
          label: 'Submitted',
        );
      case ApplicationStatus.draft:
        return (
          background: const Color(0xFFF3F4F6),
          textColor: const Color(0xFF4B5563),
          label: 'Draft',
        );
      case ApplicationStatus.deficiency:
        return (
          background: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFD97706),
          label: 'Action Required',
        );
      case ApplicationStatus.sanctioned:
      case ApplicationStatus.completed:
        return (
          background: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF15803D),
          label: 'Completed',
        );
      case ApplicationStatus.rejected:
        return (
          background: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFDC2626),
          label: 'Rejected',
        );
      case ApplicationStatus.withdrawn:
        return (
          background: const Color(0xFFF3F4F6),
          textColor: const Color(0xFF6B7280),
          label: 'Withdrawn',
        );
      default:
        return (
          background: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF15803D),
          label: 'Under Verification',
        );
    }
  }
}
