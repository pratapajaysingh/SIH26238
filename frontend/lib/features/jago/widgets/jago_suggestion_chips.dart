import 'package:flutter/material.dart';

/// JagoSuggestionChips renders the horizontal row of prompt shortcut chips:
/// - "Tell me about Post Matric >"
/// - "Am I eligible? >"
/// - "What documents are required? >"
class JagoSuggestionChips extends StatelessWidget {
  final List<String> chips;
  final ValueChanged<String> onChipSelected;

  const JagoSuggestionChips({
    super.key,
    required this.chips,
    required this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        cacheExtent: 500,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];

          return GestureDetector(
            onTap: () => onChipSelected(chip),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chip,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: Color(0xFF1E293B),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
