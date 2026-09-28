import 'package:flutter/material.dart';
import '../../../models/application.dart';
import '../../../models/application_timeline.dart';

/// ApplicationStatusTracker renders the 4-stage horizontal application progress tracker
/// matching the exact visual reference:
/// Stages:
/// 1. Applied (12 Sep 2024) [Dark circle, document icon, solid black connector]
/// 2. Under Review (18 Sep 2024) [Dark circle, clock icon, dotted grey connector]
/// 3. Verification (-) [Light grey circle, shield icon, dotted grey connector]
/// 4. Payment (-) [Light grey circle, rupee icon]
class ApplicationStatusTracker extends StatelessWidget {
  final Application? application;
  final List<ApplicationTimelineEvent> timelineEvents;
  final VoidCallback? onTap;
  final VoidCallback? onViewAll;

  const ApplicationStatusTracker({
    super.key,
    this.application,
    this.timelineEvents = const [],
    this.onTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Extract dates dynamically from timeline if provided, with deterministic fallback
    final appliedDate = _getDateForStage(0, '12 Sep 2024');
    final reviewDate = _getDateForStage(1, '18 Sep 2024');
    final verificationDate = _getDateForStage(2, '-');
    final paymentDate = _getDateForStage(3, '-');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading Row
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Application Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: Color(0xFF374151),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tracker Container
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stage 1: Applied
                    Expanded(
                      flex: 4,
                      child: _buildStageNode(
                        icon: Icons.description_rounded,
                        label: 'Applied',
                        date: appliedDate,
                        isActive: true,
                        isCurrent: false,
                      ),
                    ),

                    // Connector 1: Solid Black Line
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.only(top: 17),
                        height: 2,
                        color: const Color(0xFF111827),
                      ),
                    ),

                    // Stage 2: Under Review
                    Expanded(
                      flex: 4,
                      child: _buildStageNode(
                        icon: Icons.access_time_rounded,
                        label: 'Under Review',
                        date: reviewDate,
                        isActive: true,
                        isCurrent: true,
                      ),
                    ),

                    // Connector 2: Dotted Grey Line
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.only(top: 17),
                        height: 2,
                        child: CustomPaint(
                          painter: _DottedLinePainter(color: const Color(0xFFD1D5DB)),
                        ),
                      ),
                    ),

                    // Stage 3: Verification
                    Expanded(
                      flex: 4,
                      child: _buildStageNode(
                        icon: Icons.shield_outlined,
                        label: 'Verification',
                        date: verificationDate,
                        isActive: false,
                        isCurrent: false,
                      ),
                    ),

                    // Connector 3: Dotted Grey Line
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.only(top: 17),
                        height: 2,
                        child: CustomPaint(
                          painter: _DottedLinePainter(color: const Color(0xFFD1D5DB)),
                        ),
                      ),
                    ),

                    // Stage 4: Payment
                    Expanded(
                      flex: 4,
                      child: _buildStageNode(
                        icon: Icons.currency_rupee_rounded,
                        label: 'Payment',
                        date: paymentDate,
                        isActive: false,
                        isCurrent: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageNode({
    required IconData icon,
    required String label,
    required String date,
    required bool isActive,
    required bool isCurrent,
  }) {
    final circleColor = isActive ? const Color(0xFF111827) : const Color(0xFFE5E7EB);
    final iconColor = isActive ? Colors.white : const Color(0xFF6B7280);
    final labelColor = (isActive || isCurrent) ? const Color(0xFF111827) : const Color(0xFF6B7280);
    final labelWeight = (isActive || isCurrent) ? FontWeight.w700 : FontWeight.w500;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stage Icon Circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),

        const SizedBox(height: 8),

        // Stage Title
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 11,
              fontWeight: labelWeight,
              color: labelColor,
              letterSpacing: -0.1,
            ),
          ),
        ),

        const SizedBox(height: 2),

        // Stage Date / Hyphen
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            date,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  String _getDateForStage(int stageIdx, String defaultDate) {
    if (stageIdx < timelineEvents.length) {
      final evt = timelineEvents[stageIdx];
      if (evt.dateFormatted.isNotEmpty) return evt.dateFormatted;
    }
    return defaultDate;
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    const dotSpacing = 3.8;
    double currentX = 0;
    while (currentX < size.width) {
      canvas.drawCircle(Offset(currentX, size.height / 2), 0.9, paint);
      currentX += dotSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
