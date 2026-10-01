import 'package:flutter/material.dart';
import '../../../models/manual_review_item.dart';
import '../controllers/admin_controller.dart';

/// ManualReviewTab renders the exception verification queue for District Nodal Officers.
class ManualReviewTab extends StatefulWidget {
  final AdminController controller;

  const ManualReviewTab({super.key, required this.controller});

  @override
  State<ManualReviewTab> createState() => _ManualReviewTabState();
}

class _ManualReviewTabState extends State<ManualReviewTab> {
  final TextEditingController _remarksController = TextEditingController();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _showReviewDialog(ManualReviewItem item) {
    _remarksController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.rule_folder, color: Color(0xFFD97706), size: 22),
            const SizedBox(width: 8),
            const Text(
              'Manual Verification Review',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Review ID', item.id.substring(0, 8).toUpperCase()),
              _buildDetailRow('Application ID', item.applicationId.substring(0, 8).toUpperCase()),
              _buildDetailRow('Verification ID', item.verificationId.substring(0, 8).toUpperCase()),
              _buildDetailRow('Current Status', item.status),
              if (item.reason != null) ...[
                const SizedBox(height: 6),
                const Text(
                  'Exception Reason:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                ),
                Text(
                  item.reason!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Officer Decision Remarks:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _remarksController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Enter justification (e.g. verified via local tehsildar office)...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.controller.decideReview(
                reviewId: item.id,
                action: 'REJECT',
                remarks: _remarksController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.controller.decideReview(
                reviewId: item.id,
                action: 'APPROVE',
                remarks: _remarksController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = widget.controller.manualReviews;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manual Verification Queue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${reviews.length} exception records in queue',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF4B5563)),
                tooltip: 'Refresh Queue',
                onPressed: () => widget.controller.refreshManualReviews(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: const [
                    Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF059669)),
                    SizedBox(height: 12),
                    Text(
                      'No Pending Reviews',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'All automated verifications and exceptions are currently resolved.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...reviews.map((item) => _buildReviewCard(item)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ManualReviewItem item) {
    final isOpen = item.isOpen;
    Color statusColor;
    Color statusBg;
    if (item.isResolved) {
      statusColor = const Color(0xFF059669);
      statusBg = const Color(0xFFECFDF5);
    } else if (item.isRejected) {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
    } else {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFFFBEB);
    }

    final appShort = item.applicationId.length > 8
        ? item.applicationId.substring(0, 8).toUpperCase()
        : item.applicationId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Application APP-$appShort',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (item.studentName != null)
            Text(
              'Applicant: ${item.studentName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
            ),
          if (item.documentName != null)
            Text(
              'Document: ${item.documentName}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          if (item.reason != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.reason!,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFFB91C1C)),
              ),
            ),
          ],
          if (item.remarks != null && item.remarks!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Remarks: ${item.remarks}',
              style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF4B5563)),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showReviewDialog(item),
                icon: Icon(isOpen ? Icons.gavel_rounded : Icons.visibility_outlined, size: 15),
                label: Text(isOpen ? 'Decide Review' : 'View Decision'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOpen ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                  foregroundColor: isOpen ? Colors.white : const Color(0xFF374151),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
