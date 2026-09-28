import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/application_timeline.dart';

/// VerificationProgressWidget renders the "Verification Progress" section with:
/// - Section title & authoritative "Last updated" timestamp
/// - 4-stage horizontal checkpoint progression matching the visual reference
class VerificationProgressWidget extends StatelessWidget {
  final DateTime? lastUpdatedAt;
  final List<ApplicationTimelineEvent> timelineEvents;

  const VerificationProgressWidget({
    super.key,
    this.lastUpdatedAt,
    this.timelineEvents = const [],
  });

  @override
  Widget build(BuildContext context) {
    // 4 visual stages strictly matching the reference image layout
    final stages = [
      _StageInfo(
        title: 'Application\nSubmitted',
        subtitle: _getStageDate(0, fallback: '10 Dec 2025'),
        isCompleted: true,
        isInProgress: false,
        stepNumber: 1,
      ),
      _StageInfo(
        title: 'Document\nVerification',
        subtitle: _getStageDate(1, fallback: '12 Dec 2025'),
        isCompleted: true,
        isInProgress: false,
        stepNumber: 2,
      ),
      _StageInfo(
        title: 'Department\nReview',
        subtitle: 'In Progress',
        isCompleted: false,
        isInProgress: true,
        stepNumber: 3,
      ),
      _StageInfo(
        title: 'Final\nDecision',
        subtitle: 'Pending',
        isCompleted: false,
        isInProgress: false,
        stepNumber: 4,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: "Verification Progress" and "Last updated"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Flexible(
                flex: 1,
                child: Text(
                  'Verification Progress',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (lastUpdatedAt != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Last updated: ${DateFormatter.formatDateTime(lastUpdatedAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Horizontal Progress Stepper
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final itemWidth = totalWidth / stages.length;

              return SizedBox(
                height: 84,
                child: Stack(
                  children: [
                    // Connecting lines positioned at circle center height (13px)
                    // Line 1 to 2 (Green)
                    Positioned(
                      top: 13,
                      left: itemWidth * 0.5,
                      width: itemWidth,
                      child: Container(height: 2, color: const Color(0xFF16A34A)),
                    ),
                    // Line 2 to 3 (Black)
                    Positioned(
                      top: 13,
                      left: itemWidth * 1.5,
                      width: itemWidth,
                      child: Container(height: 2, color: const Color(0xFF111827)),
                    ),
                    // Line 3 to 4 (Grey)
                    Positioned(
                      top: 13,
                      left: itemWidth * 2.5,
                      width: itemWidth,
                      child: Container(height: 2, color: const Color(0xFFE5E7EB)),
                    ),

                    // Stage Items
                    Row(
                      children: List.generate(stages.length, (index) {
                        final stage = stages[index];

                        return SizedBox(
                          width: itemWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Checkpoint Circle
                              _buildCircle(stage),

                              const SizedBox(height: 6),

                              // Stage Title
                              Text(
                                stage.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: (stage.isCompleted || stage.isInProgress)
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: (stage.isCompleted || stage.isInProgress)
                                      ? const Color(0xFF111827)
                                      : const Color(0xFF6B7280),
                                  height: 1.15,
                                ),
                              ),

                              const SizedBox(height: 2),

                              // Subtitle / Date
                              Text(
                                stage.subtitle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: stage.isInProgress ? FontWeight.w600 : FontWeight.w400,
                                  color: stage.isInProgress
                                      ? const Color(0xFF374151)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(_StageInfo stage) {
    if (stage.isCompleted) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Color(0xFF16A34A),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 16,
        ),
      );
    } else if (stage.isInProgress) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${stage.stepNumber}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '${stage.stepNumber}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }
  }

  String _getStageDate(int index, {required String fallback}) {
    if (index < timelineEvents.length && timelineEvents[index].date != null) {
      return DateFormatter.formatDate(timelineEvents[index].date);
    }
    return fallback;
  }
}

class _StageInfo {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isInProgress;
  final int stepNumber;

  const _StageInfo({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isInProgress,
    required this.stepNumber,
  });
}
