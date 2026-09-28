import 'package:flutter/material.dart';
import '../controllers/payment_status_controller.dart';

/// PaymentProgressStepper renders the 4-stage horizontal progress tracker:
/// 1. Application Approved
/// 2. Sanction Released
/// 3. Payment Processing
/// 4. Amount Credited
/// Matching the exact visual target from the reference screenshot.
class PaymentProgressStepper extends StatelessWidget {
  final List<PaymentProgressStepModel> steps;

  const PaymentProgressStepper({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Payment Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 16),

          // Stepper Tracker Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final itemWidth = totalWidth / steps.length;

              // Line colors
              final line1Color = _isLineActive(steps, 1)
                  ? const Color(0xFF059669)
                  : const Color(0xFFE5E7EB);
              final line2Color = _isLineActive(steps, 2)
                  ? const Color(0xFF059669)
                  : const Color(0xFFE5E7EB);
              final line3Color = _isLineActive(steps, 3)
                  ? const Color(0xFF059669)
                  : const Color(0xFFE5E7EB);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Line 1 to 2
                  Positioned(
                    top: 13,
                    left: itemWidth * 0.5,
                    width: itemWidth,
                    height: 2.2,
                    child: Container(color: line1Color),
                  ),
                  // Line 2 to 3
                  Positioned(
                    top: 13,
                    left: itemWidth * 1.5,
                    width: itemWidth,
                    height: 2.2,
                    child: Container(color: line2Color),
                  ),
                  // Line 3 to 4
                  Positioned(
                    top: 13,
                    left: itemWidth * 2.5,
                    width: itemWidth,
                    height: 2.2,
                    child: Container(color: line3Color),
                  ),

                  // 4 Step Columns
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: steps.map((step) {
                      return SizedBox(
                        width: itemWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Circle Badge
                            _buildStepBadge(step),

                            const SizedBox(height: 8),

                            // Step Title (Two lines, centered)
                            Text(
                              step.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: step.status == PaymentStepStatus.pending
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: step.status == PaymentStepStatus.pending
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFF111827),
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 3),

                            // Date or Status Text
                            if (step.dateOrStatus != null)
                              Text(
                                step.dateOrStatus!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: step.status == PaymentStepStatus.inProgress
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: step.status == PaymentStepStatus.inProgress
                                      ? const Color(0xFF1F2937)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isLineActive(List<PaymentProgressStepModel> stepList, int lineIndex) {
    if (lineIndex < 1 || lineIndex >= stepList.length) return false;
    final targetStep = stepList[lineIndex];
    return targetStep.status == PaymentStepStatus.completed ||
        targetStep.status == PaymentStepStatus.inProgress;
  }

  Widget _buildStepBadge(PaymentProgressStepModel step) {
    switch (step.status) {
      case PaymentStepStatus.completed:
        return Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFF059669),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 16,
          ),
        );

      case PaymentStepStatus.inProgress:
        return Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFF111827),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${step.stepIndex}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

      case PaymentStepStatus.failed:
        return Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFFDC2626),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 16,
          ),
        );

      case PaymentStepStatus.pending:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD1D5DB),
              width: 1.4,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${step.stepIndex}',
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
    }
  }
}
