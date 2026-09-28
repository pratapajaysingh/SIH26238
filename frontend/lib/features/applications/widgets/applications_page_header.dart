import 'package:flutter/material.dart';

/// ApplicationsPageHeader renders the back button, title, and descriptive subtitle
/// exactly matching the visual reference.
class ApplicationsPageHeader extends StatelessWidget {
  final VoidCallback onBack;

  const ApplicationsPageHeader({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Navigation Arrow
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(top: 2.0, right: 12.0, bottom: 8.0),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24,
                color: Color(0xFF111827),
              ),
            ),
          ),

          // Title & Subtitle Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'My Applications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track and manage all your scholarship applications in one place.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.3,
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
