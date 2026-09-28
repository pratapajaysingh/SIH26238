import 'package:flutter/material.dart';
import '../../../core/enums/verification_status.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/verification.dart';

/// DocumentVerificationRow renders an individual document's verification status
/// strictly matching the visual target from the reference image.
class DocumentVerificationRow extends StatelessWidget {
  final VerificationRecord record;
  final String documentName;
  final String subtitle;
  final VoidCallback? onTap;

  const DocumentVerificationRow({
    super.key,
    required this.record,
    required this.documentName,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _resolveDocumentIcon(record);
    final statusConfig = _getStatusConfig(record.status);
    final timestamp = record.verifiedAt ?? record.createdAt;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Left Document Icon in Grey Circle
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  iconData,
                  size: 18,
                  color: const Color(0xFF1F2937),
                ),
              ),

              const SizedBox(width: 12),

              // 2. Middle Content (Document Name + Subtitle/Source)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 3. Right Status Pill & Timestamp
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusConfig.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusConfig.icon,
                          size: 11.5,
                          color: statusConfig.textColor,
                        ),
                        const SizedBox(width: 3.5),
                        Text(
                          statusConfig.label,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: statusConfig.textColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (timestamp != null) ...[
                    const SizedBox(height: 2.5),
                    Text(
                      DateFormatter.formatDateTime(timestamp),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(width: 4),

              // 4. Chevron right
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _resolveDocumentIcon(VerificationRecord record) {
    final type = record.verificationType?.toUpperCase() ?? '';
    final nameLower = documentName.toLowerCase();

    if (type == 'IDENTITY' || nameLower.contains('aadhaar')) {
      return Icons.badge_outlined;
    }
    if (type == 'COMMUNITY' || nameLower.contains('caste') || nameLower.contains('tribe')) {
      return Icons.people_alt_outlined;
    }
    if (type == 'ACADEMIC' || nameLower.contains('marksheet') || nameLower.contains('class')) {
      return Icons.school_outlined;
    }
    if (type == 'INCOME' || nameLower.contains('income')) {
      return Icons.receipt_long_outlined;
    }
    if (type == 'INSTITUTION' || nameLower.contains('admission') || nameLower.contains('institute')) {
      return Icons.account_balance_outlined;
    }
    return Icons.description_outlined;
  }

  ({Color background, Color textColor, IconData icon, String label}) _getStatusConfig(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return (
          background: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF15803D),
          icon: Icons.check_circle_rounded,
          label: 'VERIFIED',
        );
      case VerificationStatus.pending:
        return (
          background: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFD97706),
          icon: Icons.access_time_filled_rounded,
          label: 'PENDING',
        );
      case VerificationStatus.manualReview:
        return (
          background: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFDC2626),
          icon: Icons.error_rounded,
          label: 'MANUAL REVIEW',
        );
      case VerificationStatus.mismatch:
        return (
          background: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFD97706),
          icon: Icons.warning_rounded,
          label: 'MISMATCH',
        );
      case VerificationStatus.failed:
        return (
          background: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFDC2626),
          icon: Icons.cancel_rounded,
          label: 'FAILED',
        );
    }
  }
}
