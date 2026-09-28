import 'package:flutter/material.dart';

/// ApplicationVerificationStatusCard renders the "Verification Status" section on the Overview tab:
/// - Header with "View All >" action
/// - 3 stage verification rows: Institute Verification, District Verification, State Verification
class ApplicationVerificationStatusCard extends StatelessWidget {
  final VoidCallback onViewAll;

  const ApplicationVerificationStatusCard({
    super.key,
    required this.onViewAll,
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
            // Header Row: "Verification Status" and "View All >"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Verification Status',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Details of verification at each stage.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onViewAll,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFF111827),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Row 1: Institute Verification
            _buildStageRow(
              iconData: Icons.check_rounded,
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF16A34A),
              title: 'Institute Verification',
              subtitle: 'Your application has been verified by your institute.',
              statusLabel: 'Verified',
              statusBgColor: const Color(0xFFDCFCE7),
              statusTextColor: const Color(0xFF15803D),
              dateText: '18 Aug 2024',
            ),

            const Divider(height: 18, thickness: 1, color: Color(0xFFF3F4F6)),

            // Row 2: District Verification
            _buildStageRow(
              iconData: Icons.access_time_rounded,
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF2563EB),
              title: 'District Verification',
              subtitle: 'Your application is under review at the district level.',
              statusLabel: 'In Progress',
              statusBgColor: const Color(0xFFDBEAFE),
              statusTextColor: const Color(0xFF1D4ED8),
              dateText: '22 Aug 2024',
            ),

            const Divider(height: 18, thickness: 1, color: Color(0xFFF3F4F6)),

            // Row 3: State Verification
            _buildStageRow(
              iconData: Icons.more_horiz_rounded,
              iconColor: const Color(0xFF9CA3AF),
              iconBgColor: const Color(0xFFF3F4F6),
              title: 'State Verification',
              subtitle: 'Pending at state level.',
              statusLabel: 'Pending',
              statusBgColor: const Color(0xFFF3F4F6),
              statusTextColor: const Color(0xFF6B7280),
              dateText: '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageRow({
    required IconData iconData,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String statusLabel,
    required Color statusBgColor,
    required Color statusTextColor,
    required String dateText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Icon in Circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(iconData, size: 16, color: iconColor),
        ),

        const SizedBox(width: 12),

        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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

        // Status Pill & Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: statusTextColor,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              dateText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
