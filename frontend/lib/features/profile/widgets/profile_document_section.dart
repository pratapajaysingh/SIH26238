import 'package:flutter/material.dart';
import '../../../core/enums/document_status.dart';
import '../../../models/document.dart';

/// ProfileDocumentSection renders the Document Management section with:
/// - Section title and "View All >"
/// - Horizontal scrollable compact document cards with status indicator
class ProfileDocumentSection extends StatelessWidget {
  final List<DocumentItem> documents;
  final VoidCallback? onViewAll;
  final ValueChanged<DocumentItem>? onDocumentTap;

  const ProfileDocumentSection({
    super.key,
    required this.documents,
    this.onViewAll,
    this.onDocumentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Document Management',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onViewAll,
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  'View All >',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Horizontal Document Cards List
        if (documents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              alignment: Alignment.center,
              child: const Text(
                'No documents uploaded yet',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: documents.map((doc) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: _buildDocumentCard(doc),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentCard(DocumentItem doc) {
    final isVerified = doc.status == DocumentStatus.verified;
    final isPending = doc.status == DocumentStatus.pending;
    final statusColor = isVerified
        ? const Color(0xFF15803D)
        : (isPending ? const Color(0xFFD97706) : const Color(0xFFDC2626));
    final statusText = isVerified
        ? 'Verified'
        : (isPending ? 'Under Review' : doc.status.label);

    return InkWell(
      onTap: () => onDocumentTap?.call(doc),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 176,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 9.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Document Icon in Grey Square
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.description_outlined,
                size: 15,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(width: 8),

            // Middle: Name + Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doc.docName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.2,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            // Right Chevron
            const Icon(
              Icons.chevron_right_rounded,
              size: 15,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
