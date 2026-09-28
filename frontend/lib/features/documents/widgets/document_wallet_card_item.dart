import 'package:flutter/material.dart';
import '../../../core/enums/document_status.dart';
import '../../../models/document.dart';

/// DocumentWalletCardItem renders an individual document card matching the reference image.
/// Displays document title, category subtitle, status chip, issue date, source icon + label,
/// 3-dot overflow menu, and "View >" capsule button.
class DocumentWalletCardItem extends StatelessWidget {
  final DocumentItem document;
  final ValueChanged<DocumentItem>? onViewTap;
  final ValueChanged<DocumentItem>? onMoreTap;

  const DocumentWalletCardItem({
    super.key,
    required this.document,
    this.onViewTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
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
          // Left Icon Badge
          _buildLeadingBadge(),

          const SizedBox(width: 12),

          // Main Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title + Status Chip + 3-Dot More Icon
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        document.docName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => onMoreTap?.call(document),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Category Subtitle (e.g. "Identity Document")
                Text(
                  document.categorySubtitle,
                  style: const TextStyle(
                    fontSize: 11.8,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 8),

                // Bottom Row: Issued Date + Source + "View >" Capsule
                Row(
                  children: [
                    // Issued on Date
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12.5,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 3.5),
                    Flexible(
                      child: Text(
                        document.formattedIssuedDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Source
                    _buildSourceIndicator(),

                    const Spacer(),

                    // "View >" Capsule Button
                    InkWell(
                      onTap: () => onViewTap?.call(document),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View',
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 13,
                              color: Color(0xFF334155),
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
        ],
      ),
    );
  }

  Widget _buildLeadingBadge() {
    final docType = document.docType.toUpperCase();
    final docName = document.docName.toUpperCase();

    Color bgColor;
    Color iconColor;
    IconData icon;

    if (docType.contains('AADHAAR') || docName.contains('AADHAAR')) {
      bgColor = const Color(0xFFEFF6FF);
      iconColor = const Color(0xFF2563EB);
      icon = Icons.badge_outlined;
    } else if (docType.contains('MARK_SHEET_10') || docName.contains('10TH')) {
      bgColor = const Color(0xFFF5F3FF);
      iconColor = const Color(0xFF7C3AED);
      icon = Icons.school_outlined;
    } else if (docType.contains('MARK_SHEET') || docName.contains('12TH') || docType.contains('ACADEMIC')) {
      bgColor = const Color(0xFFF0FDF4);
      iconColor = const Color(0xFF16A34A);
      icon = Icons.description_outlined;
    } else if (docType.contains('INCOME') || docName.contains('INCOME')) {
      bgColor = const Color(0xFFFFFBEB);
      iconColor = const Color(0xFFD97706);
      icon = Icons.receipt_long_outlined;
    } else if (docType.contains('CASTE') || docType.contains('ST_') || docName.contains('CASTE')) {
      bgColor = const Color(0xFFFEF2F2);
      iconColor = const Color(0xFFDC2626);
      icon = Icons.groups_outlined;
    } else {
      bgColor = const Color(0xFFF1F5F9);
      iconColor = const Color(0xFF475569);
      icon = Icons.file_copy_outlined;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _buildStatusChip() {
    Color bgColor;
    Color contentColor;
    IconData icon;
    String label;

    switch (document.status) {
      case DocumentStatus.verified:
        bgColor = const Color(0xFFDCFCE7);
        contentColor = const Color(0xFF15803D);
        icon = Icons.check_circle_rounded;
        label = 'Verified';
        break;
      case DocumentStatus.pending:
        bgColor = const Color(0xFFFEF3C7);
        contentColor = const Color(0xFFB45309);
        icon = Icons.access_time_filled_rounded;
        label = 'Pending';
        break;
      case DocumentStatus.rejected:
        bgColor = const Color(0xFFFEE2E2);
        contentColor = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        label = 'Rejected';
        break;
      case DocumentStatus.expired:
        bgColor = const Color(0xFFF1F5F9);
        contentColor = const Color(0xFF475569);
        icon = Icons.warning_amber_rounded;
        label = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: contentColor),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceIndicator() {
    final isDigiLocker = document.isDigiLockerSource;
    final icon = isDigiLocker ? Icons.account_balance_outlined : Icons.cloud_upload_outlined;
    final label = document.sourceDisplay;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.5, color: const Color(0xFF64748B)),
        const SizedBox(width: 3.5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
