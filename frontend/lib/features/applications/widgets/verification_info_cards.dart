import 'package:flutter/material.dart';

/// VerificationInfoCards renders the informational cards at the bottom of the screen:
/// 1. "What happens next?" (soft blue card)
/// 2. "Important Information" (soft amber/yellow card)
class VerificationInfoCards extends StatelessWidget {
  const VerificationInfoCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: const [
          // 1. What happens next?
          _InfoCalloutCard(
            backgroundColor: Color(0xFFEFF6FF),
            borderColor: Color(0xFFDBEAFE),
            iconColor: Color(0xFF2563EB),
            icon: Icons.info_outline_rounded,
            title: 'What happens next?',
            titleColor: Color(0xFF1E40AF),
            body:
                'Once all documents are verified, your application moves to the Department Review stage. You will receive an SMS and email notification at each stage transition.',
            bodyColor: Color(0xFF1E3A8A),
          ),

          SizedBox(height: 12),

          // 2. Important Information
          _InfoCalloutCard(
            backgroundColor: Color(0xFFFFFBEB),
            borderColor: Color(0xFFFDE68A),
            iconColor: Color(0xFFD97706),
            icon: Icons.info_outline_rounded,
            title: 'Important Information',
            titleColor: Color(0xFF92400E),
            body:
                'If any document requires re-upload or clarification, you will have 7 days from the notification date to submit updated documents. Check the Document Locker to re-upload if requested.',
            bodyColor: Color(0xFF78350F),
          ),
        ],
      ),
    );
  }
}

class _InfoCalloutCard extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final Color titleColor;
  final String body;
  final Color bodyColor;

  const _InfoCalloutCard({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.titleColor,
    required this.body,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1.1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: bodyColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
