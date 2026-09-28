import 'package:flutter/material.dart';

/// PaymentInfoCalloutCards renders the two bottom information cards:
/// 1. "What happens next?" (Soft Blue)
/// 2. "Important Information" (Soft Warm Yellow)
/// Matching the exact visual layout and copy from the reference screenshot.
class PaymentInfoCalloutCards extends StatelessWidget {
  const PaymentInfoCalloutCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Card 1: What happens next?
          _buildInfoCard(
            backgroundColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFDBEAFE),
            iconContainerColor: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF2563EB),
            icon: Icons.info_rounded,
            title: 'What happens next?',
            body:
                'The payment will be credited directly to your bank account through DBT. You will receive an in-app notification once the amount is credited.',
          ),

          const SizedBox(height: 12),

          // Card 2: Important Information
          _buildInfoCard(
            backgroundColor: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFEF08A),
            iconContainerColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            icon: Icons.info_rounded,
            title: 'Important Information',
            body:
                'Payment timelines may vary based on bank processing and government procedures. Please ensure your bank account is active and linked with Aadhaar.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required Color backgroundColor,
    required Color borderColor,
    required Color iconContainerColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconContainerColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          // Right Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4B5563),
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
