import 'package:flutter/material.dart';
import '../../../models/verification.dart';
import 'document_verification_row.dart';

/// DocumentVerificationListCard displays the "Document Verification Status" card
/// with the header, subtitle, and list of DocumentVerificationRow items.
class DocumentVerificationListCard extends StatelessWidget {
  final List<VerificationRecord> verifications;
  final String Function(VerificationRecord) getDocumentName;
  final String Function(VerificationRecord) getDocumentSubtitle;
  final void Function(VerificationRecord)? onRowTap;

  const DocumentVerificationListCard({
    super.key,
    required this.verifications,
    required this.getDocumentName,
    required this.getDocumentSubtitle,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
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
            // Card Title
            const Text(
              'Document Verification Status',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 3),
            // Card Subtitle
            const Text(
              'Live status of each document submitted with your application.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 12),

            // Rows or Empty State
            if (verifications.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(
                        Icons.description_outlined,
                        size: 36,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No verification records available yet.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: verifications.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 16,
                  thickness: 1,
                  color: Color(0xFFF3F4F6),
                ),
                itemBuilder: (context, index) {
                  final record = verifications[index];
                  return DocumentVerificationRow(
                    record: record,
                    documentName: getDocumentName(record),
                    subtitle: getDocumentSubtitle(record),
                    onTap: onRowTap != null ? () => onRowTap!(record) : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
