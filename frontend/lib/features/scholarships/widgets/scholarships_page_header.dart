import 'package:flutter/material.dart';

/// ScholarshipsPageHeader renders the back navigation, page title, subtitle,
/// and the subtle "My Filters" action button.
class ScholarshipsPageHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMyFilters;

  const ScholarshipsPageHeader({
    super.key,
    required this.onBack,
    required this.onMyFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button Arrow
              GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(top: 2.0, right: 10.0, bottom: 4.0),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 22,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              // Title and Subtitle Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Find Scholarships',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Discover schemes designed for tribal students\nacross India.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // "My Filters" Pill Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onMyFilters,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: Color(0xFF374151),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'My Filters',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
