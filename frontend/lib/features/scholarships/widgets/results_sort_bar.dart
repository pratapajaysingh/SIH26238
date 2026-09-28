import 'package:flutter/material.dart';

/// ResultsSortBar renders the result count and the sort dropdown control.
/// Left: "42 Scholarships Found"
/// Right: "Sort by: Most Relevant ⌄"
class ResultsSortBar extends StatelessWidget {
  final int count;
  final String selectedSort;
  final List<String> sortOptions;
  final ValueChanged<String> onSortChanged;

  const ResultsSortBar({
    super.key,
    required this.count,
    required this.selectedSort,
    this.sortOptions = const ['Most Relevant', 'Name (A-Z)', 'Deadline'],
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dynamic Result Count
          Expanded(
            child: Text(
              '$count Scholarships Found',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Clean Rounded Sort Control
          PopupMenuButton<String>(
            onSelected: onSortChanged,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Colors.white,
            elevation: 4,
            itemBuilder: (context) {
              return sortOptions.map((opt) {
                final isSelected = opt == selectedSort;
                return PopupMenuItem<String>(
                  value: opt,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        opt,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF111827) : const Color(0xFF4B5563),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF111827),
                        ),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sort by: ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 95),
                    child: Text(
                      selectedSort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 15,
                    color: Color(0xFF111827),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
