import 'package:flutter/material.dart';
import '../../../models/unreached_beneficiary_item.dart';
import '../controllers/admin_controller.dart';

/// UnreachedBeneficiariesTab displays enrolled ST students missing out on benefits,
/// with source provenance tags and outreach triggers.
class UnreachedBeneficiariesTab extends StatelessWidget {
  final AdminController controller;

  const UnreachedBeneficiariesTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final students = controller.unreachedStudents;
    final showAll = controller.showAllEnrolled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Description
          const Text(
            'Unreached ST Beneficiary Identification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cross-matched against UDISE+, AISHE, and APAAR registries to detect tribal students not availing scholarship schemes.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),

          // Filter Segmented Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.toggleShowAllEnrolled(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !showAll ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !showAll
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Unreached Only',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: !showAll ? FontWeight.w700 : FontWeight.w500,
                          color: !showAll ? const Color(0xFF111827) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.toggleShowAllEnrolled(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: showAll ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: showAll
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'All Enrolled Registries',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: showAll ? FontWeight.w700 : FontWeight.w500,
                          color: showAll ? const Color(0xFF111827) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (students.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: const [
                    Icon(Icons.people_outline, size: 44, color: Color(0xFF9CA3AF)),
                    SizedBox(height: 10),
                    Text(
                      'No Records Found',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...students.map((item) => _buildBeneficiaryCard(context, item)),
        ],
      ),
    );
  }

  Widget _buildBeneficiaryCard(BuildContext context, UnreachedBeneficiaryItem item) {
    final isUnreached = item.isUnreached;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnreached ? const Color(0xFFFDE68A) : const Color(0xFFE5E7EB),
          width: isUnreached ? 1.2 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Demo ID, Source tag, Matched status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.demoId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildSourceBadge(item.enrollmentSource),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUnreached ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.matchedStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUnreached ? const Color(0xFFDC2626) : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Institution & State
          Text(
            item.institutionName,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${item.educationLevel} • ${item.state}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),

          if (item.possibleReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.possibleReason!,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isUnreached
                      ? (item.nextAction ?? 'Outreach recommended')
                      : 'Beneficiary active: ${item.scholarshipCode ?? "Sanctioned"}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: isUnreached ? const Color(0xFFB45309) : const Color(0xFF059669),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isUnreached)
                ElevatedButton.icon(
                  onPressed: item.outreachSent
                      ? null
                      : () => controller.sendOutreach(demoId: item.demoId),
                  icon: Icon(
                    item.outreachSent ? Icons.check : Icons.campaign_rounded,
                    size: 15,
                  ),
                  label: Text(item.outreachSent ? 'Outreach Sent' : 'Send Outreach'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.outreachSent
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFD97706),
                    foregroundColor: item.outreachSent
                        ? const Color(0xFF065F46)
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge(String source) {
    Color bg;
    Color fg;
    switch (source.toUpperCase()) {
      case 'UDISE+':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        break;
      case 'AISHE':
        bg = const Color(0xFFFCE7F3);
        fg = const Color(0xFF9D174D);
        break;
      case 'APAAR':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        source,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
