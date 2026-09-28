import 'package:flutter/material.dart';

/// MyDocumentsPageHeader renders the title section matching the reference image:
/// - Back arrow button
/// - Title "My Documents"
/// - Subtitle "Manage your documents for scholarships and other services."
class MyDocumentsPageHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const MyDocumentsPageHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          GestureDetector(
            onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(top: 2.0, right: 12.0),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          // Title & Subtitle Column
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Documents',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage your documents for scholarships and other services.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
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
