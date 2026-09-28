import 'package:flutter/material.dart';

/// EligibilityStepper renders the 4-step indicator matching the visual reference:
/// 1. Select Scheme
/// 2. Verify Details
/// 3. Check Eligibility
/// 4. View Results
///
/// Strictly UI presentation states only.
class EligibilityStepper extends StatelessWidget {
  final int activeStep;

  const EligibilityStepper({
    super.key,
    this.activeStep = 1,
  });

  @override
  Widget build(BuildContext context) {
    const steps = [
      _StepData(number: 1, label: 'Select Scheme'),
      _StepData(number: 2, label: 'Verify Details'),
      _StepData(number: 3, label: 'Check Eligibility'),
      _StepData(number: 4, label: 'View Results'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final stepCount = steps.length;
          final itemWidth = totalWidth / stepCount;

          return SizedBox(
            height: 60,
            child: Stack(
              children: [
                // Connecting lines between circle centers
                Positioned(
                  top: 13, // Center of 26px circle
                  left: itemWidth * 0.5,
                  right: itemWidth * 0.5,
                  child: Container(
                    height: 1.2,
                    color: const Color(0xFFE5E7EB),
                  ),
                ),

                // Step Circles & Labels
                Row(
                  children: List.generate(steps.length, (index) {
                    final step = steps[index];
                    final isActive = step.number == activeStep;
                    final isCompleted = step.number < activeStep;

                    final circleColor = (isActive || isCompleted)
                        ? const Color(0xFF111827)
                        : Colors.white;
                    final textColor = (isActive || isCompleted)
                        ? Colors.white
                        : const Color(0xFF6B7280);
                    final borderColor = (isActive || isCompleted)
                        ? const Color(0xFF111827)
                        : const Color(0xFFD1D5DB);
                    final labelColor = (isActive || isCompleted)
                        ? const Color(0xFF111827)
                        : const Color(0xFF6B7280);
                    final labelWeight = (isActive || isCompleted)
                        ? FontWeight.w700
                        : FontWeight.w500;

                    return SizedBox(
                      width: itemWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Circle
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: circleColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: borderColor,
                                width: 1.2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${step.number}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                height: 1.0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // Label
                          Text(
                            step.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: labelWeight,
                              color: labelColor,
                              letterSpacing: -0.2,
                              height: 1.15,
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
    );
  }
}

class _StepData {
  final int number;
  final String label;

  const _StepData({required this.number, required this.label});
}
