import 'package:flutter/material.dart';
import '../../../core/enums/application_status.dart';
import '../../../models/application.dart';

/// PaymentApplicationSummaryCard renders the top application card on Payment / DBT Status screen:
/// - Left graduation cap icon badge
/// - Application ID & Number
/// - Status pill ("APPROVED")
/// - Scheme Name & Ministry ("Post Matric Scholarship for ST Students", "Ministry of Tribal Affairs, Government of India")
/// - "View Application >" button
class PaymentApplicationSummaryCard extends StatelessWidget {
  final Application? application;
  final VoidCallback? onViewApplication;

  const PaymentApplicationSummaryCard({
    super.key,
    required this.application,
    this.onViewApplication,
  });

  @override
  Widget build(BuildContext context) {
    final app = application;
    final appNumber = app?.applicationNumber ?? 'TS2026ST000123';
    final schemeName = app?.schemeName ?? 'Post Matric Scholarship for ST Students';
    final ministry = app?.ministryName ?? 'Ministry of Tribal Affairs';
    final ministryText = ministry.contains('Government of India')
        ? ministry
        : '$ministry, Government of India';

    final statusText = _getStatusLabel(app?.status);
    final statusColors = _getStatusColors(app?.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Graduation Cap Icon Badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.school_rounded,
                size: 26,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(width: 12),

            // Middle & Right Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Application ID and Status Pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Application ID',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              appNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: statusColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: statusColors.text,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Scheme Name
                  Text(
                    schemeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.1,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Ministry & Govt of India
                  Text(
                    ministryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // View Application Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onViewApplication,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Application',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  String _getStatusLabel(ApplicationStatus? status) {
    if (status == null) return 'APPROVED';
    switch (status) {
      case ApplicationStatus.sanctioned:
      case ApplicationStatus.completed:
        return 'APPROVED';
      case ApplicationStatus.inVerification:
        return 'APPROVED';
      case ApplicationStatus.deficiency:
        return 'DEFICIENCY';
      case ApplicationStatus.rejected:
        return 'REJECTED';
      case ApplicationStatus.withdrawn:
        return 'WITHDRAWN';
      case ApplicationStatus.draft:
        return 'DRAFT';
      case ApplicationStatus.submitted:
        return 'SUBMITTED';
    }
  }

  ({Color background, Color text}) _getStatusColors(ApplicationStatus? status) {
    if (status == null ||
        status == ApplicationStatus.sanctioned ||
        status == ApplicationStatus.completed ||
        status == ApplicationStatus.inVerification) {
      return (
        background: const Color(0xFFDCFCE7),
        text: const Color(0xFF15803D),
      );
    }
    switch (status) {
      case ApplicationStatus.deficiency:
        return (
          background: const Color(0xFFFEF3C7),
          text: const Color(0xFFB45309),
        );
      case ApplicationStatus.rejected:
        return (
          background: const Color(0xFFFEE2E2),
          text: const Color(0xFFB91C1C),
        );
      default:
        return (
          background: const Color(0xFFF3F4F6),
          text: const Color(0xFF4B5563),
        );
    }
  }
}
