import 'package:flutter/material.dart';

/// JagoAskAboutSection renders the "You can also ask about" section with 6 cards:
/// 1. Scholarship Schemes (graduation cap)
/// 2. Eligibility Criteria (document with checklist)
/// 3. Required Documents (documents list)
/// 4. Application Process (Rupee icon)
/// 5. Important Deadlines (calendar)
/// 6. General Queries (question mark)
class JagoAskAboutSection extends StatelessWidget {
  final List<Map<String, String>> options;
  final ValueChanged<String> onPromptSelected;

  const JagoAskAboutSection({
    super.key,
    required this.options,
    required this.onPromptSelected,
  });

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'school':
        return Icons.school_rounded;
      case 'criteria':
        return Icons.description_rounded;
      case 'documents':
        return Icons.assignment_rounded;
      case 'process':
        return Icons.currency_rupee_rounded;
      case 'deadlines':
        return Icons.calendar_month_rounded;
      case 'queries':
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'You can also ask about',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.2,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Horizontal Row of 6 Cards
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = options[index];
              final title = item['title'] ?? '';
              final prompt = item['prompt'] ?? title;
              final iconType = item['icon'] ?? '';

              return GestureDetector(
                onTap: () => onPromptSelected(prompt),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // White circular icon badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(iconType),
                          size: 15,
                          color: const Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Card Label
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                          height: 1.15,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
