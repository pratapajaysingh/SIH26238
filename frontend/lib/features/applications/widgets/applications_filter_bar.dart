import 'package:flutter/material.dart';
import '../controllers/applications_controller.dart';

/// ApplicationsFilterBar renders the 4-segment pill filter control:
/// [ All | In Progress | Under Review | Completed ]
/// Active tab has solid black capsule background and white text.
class ApplicationsFilterBar extends StatelessWidget {
  final ApplicationsFilter selectedFilter;
  final ValueChanged<ApplicationsFilter> onFilterSelected;

  const ApplicationsFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 42,
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: ApplicationsFilter.values.map((filter) {
            final isSelected = filter == selectedFilter;
            return Expanded(
              child: GestureDetector(
                onTap: () => onFilterSelected(filter),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF111827) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF4B5563),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
