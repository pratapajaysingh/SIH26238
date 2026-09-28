import 'package:flutter/material.dart';

/// ApplicationDetailsPageHeader renders the back arrow, title, and descriptive subtitle.
class ApplicationDetailsPageHeader extends StatelessWidget {
  final VoidCallback onBack;

  const ApplicationDetailsPageHeader({
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

          // Title: "Application Details"
          const Text(
            'Application Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.4,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Track the status of your scholarship application\nand view all related information.',
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
