import 'package:flutter/material.dart';

/// ProfileInfoRowItem models a single metadata row inside a profile section card.
class ProfileInfoRowItem {
  final IconData icon;
  final String label;
  final String value;
  final bool isVerified;
  final bool isMultiLine;
  final VoidCallback? onTap;

  const ProfileInfoRowItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isVerified = false,
    this.isMultiLine = false,
    this.onTap,
  });
}

/// ProfileInfoSectionCard renders a grouped metadata card (Personal, Contact, Academic)
/// with matching icons, labels, values, verified pills, and chevrons.
class ProfileInfoSectionCard extends StatelessWidget {
  final String title;
  final List<ProfileInfoRowItem> items;

  const ProfileInfoSectionCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final labelWidth = screenWidth < 380 ? 106.0 : 124.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 8),

          // Card Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isLast = index == items.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          crossAxisAlignment: item.isMultiLine
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
                          children: [
                            // 1. Icon Container
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                item.icon,
                                size: 16,
                                color: const Color(0xFF111827),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 2. Field Label
                            SizedBox(
                              width: labelWidth,
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                  fontSize: 11.8,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            // 3. Field Value + Verified Pill
                            Expanded(
                              child: Row(
                                crossAxisAlignment: item.isMultiLine
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.value,
                                      style: const TextStyle(
                                        fontSize: 11.8,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                  if (item.isVerified) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE6F4EA),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Verified',
                                        style: TextStyle(
                                          fontSize: 9.0,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF15803D),
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 6),

                            // 4. Right Chevron
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF3F4F6),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
