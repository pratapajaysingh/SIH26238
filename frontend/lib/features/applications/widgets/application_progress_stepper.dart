import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/application_timeline.dart';

/// ApplicationProgressStepper renders the 5-stage horizontal tracker:
/// 1. Submitted
/// 2. Institute Verification
/// 3. District Verification
/// 4. Sanction
/// 5. DBT Payment
class ApplicationProgressStepper extends StatelessWidget {
  final List<ApplicationTimelineEvent> timelineEvents;
  final DateTime? submittedAt;
  final String? currentStage;

  const ApplicationProgressStepper({
    super.key,
    this.timelineEvents = const [],
    this.submittedAt,
    this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    // 5 Stages matching the visual target
    final stages = [
      _StageData(
        title: 'Submitted',
        subtitle: _getSubmittedDate(),
        state: _StepState.completed,
      ),
      _StageData(
        title: 'Institute\nVerification',
        subtitle: _getStageDate(1, fallback: '18 Aug 2024'),
        state: _StepState.completed,
      ),
      _StageData(
        title: 'District\nVerification',
        subtitle: 'In Progress',
        state: _StepState.inProgress,
      ),
      _StageData(
        title: 'Sanction',
        subtitle: 'Pending',
        state: _StepState.pending,
      ),
      _StageData(
        title: 'DBT Payment',
        subtitle: 'Pending',
        state: _StepState.pending,
      ),
    ];

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
            // Title & Subtitle
            const Text(
              'Application Progress',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Track your application through each stage of the process.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 18),

            // Horizontal Stepper
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final itemWidth = totalWidth / stages.length;

                return SizedBox(
                  height: 86,
                  child: Stack(
                    children: [
                      // Connecting lines (height at circle center: 12px)
                      // Line 1 to 2 (Green)
                      Positioned(
                        top: 12,
                        left: itemWidth * 0.5,
                        width: itemWidth,
                        child: Container(height: 2, color: const Color(0xFF16A34A)),
                      ),
                      // Line 2 to 3 (Blue)
                      Positioned(
                        top: 12,
                        left: itemWidth * 1.5,
                        width: itemWidth,
                        child: Container(height: 2, color: const Color(0xFF2563EB)),
                      ),
                      // Line 3 to 4 (Grey)
                      Positioned(
                        top: 12,
                        left: itemWidth * 2.5,
                        width: itemWidth,
                        child: Container(height: 2, color: const Color(0xFFE5E7EB)),
                      ),
                      // Line 4 to 5 (Grey)
                      Positioned(
                        top: 12,
                        left: itemWidth * 3.5,
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
                                _buildCircle(stage.state),
                                const SizedBox(height: 6),
                                Text(
                                  stage.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: stage.state == _StepState.pending
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                    color: stage.state == _StepState.pending
                                        ? const Color(0xFF4B5563)
                                        : const Color(0xFF111827),
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stage.subtitle,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: stage.state == _StepState.inProgress
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: stage.state == _StepState.inProgress
                                        ? const Color(0xFF2563EB)
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
      ),
    );
  }

  Widget _buildCircle(_StepState state) {
    switch (state) {
      case _StepState.completed:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF16A34A),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 15,
          ),
        );
      case _StepState.inProgress:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.description_rounded,
            color: Colors.white,
            size: 13,
          ),
        );
      case _StepState.pending:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD1D5DB),
              width: 1.5,
            ),
          ),
        );
    }
  }

  String _getSubmittedDate() {
    if (submittedAt != null) {
      return DateFormatter.formatDate(submittedAt);
    }
    if (timelineEvents.isNotEmpty && timelineEvents.first.date != null) {
      return DateFormatter.formatDate(timelineEvents.first.date);
    }
    return '12 Aug 2024';
  }

  String _getStageDate(int index, {required String fallback}) {
    if (index < timelineEvents.length && timelineEvents[index].date != null) {
      return DateFormatter.formatDate(timelineEvents[index].date);
    }
    return fallback;
  }
}

enum _StepState { completed, inProgress, pending }

class _StageData {
  final String title;
  final String subtitle;
  final _StepState state;

  const _StageData({
    required this.title,
    required this.subtitle,
    required this.state,
  });
}
