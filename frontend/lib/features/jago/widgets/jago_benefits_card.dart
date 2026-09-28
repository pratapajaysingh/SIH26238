import 'package:flutter/material.dart';

/// JagoBenefitsCard reproduces the 3-column benefit strip from the reference image:
/// 1. Get instant answers (lightbulb)
/// 2. Step-by-step guidance (document checklist)
/// 3. Simpler explanations (people)
class JagoBenefitsCard extends StatelessWidget {
  const JagoBenefitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Benefit 1: Instant Answers
            Expanded(
              child: _buildBenefitItem(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Get instant\nanswers',
              ),
            ),

            // Divider 1
            Container(
              height: 28,
              width: 1,
              color: const Color(0xFFE5E7EB),
            ),

            // Benefit 2: Step-by-step guidance
            Expanded(
              child: _buildBenefitItem(
                icon: Icons.assignment_outlined,
                title: 'Step-by-step\nguidance',
              ),
            ),

            // Divider 2
            Container(
              height: 28,
              width: 1,
              color: const Color(0xFFE5E7EB),
            ),

            // Benefit 3: Simpler explanations
            Expanded(
              child: _buildBenefitItem(
                icon: Icons.groups_outlined,
                title: 'Simpler\nexplanations',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular white icon badge
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF111827),
          ),
        ),

        const SizedBox(width: 7),

        // Text
        Flexible(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              height: 1.25,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }
}
