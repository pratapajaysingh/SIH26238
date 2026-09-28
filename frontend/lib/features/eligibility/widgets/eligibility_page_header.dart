import 'package:flutter/material.dart';

/// EligibilityPageHeader renders the back button, title, and descriptive subtitle
/// matching the exact visual target from the reference image.
class EligibilityPageHeader extends StatelessWidget {
  final VoidCallback onBack;

  const EligibilityPageHeader({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF111827),
                size: 24,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title: "Check Eligibility"
          const Text(
            'Check Eligibility',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.4,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle: "Find out if you are eligible for a scholarship scheme before you apply."
          const Text(
            'Find out if you are eligible for a scholarship scheme before you apply.',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
