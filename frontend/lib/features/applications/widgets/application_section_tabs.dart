import 'package:flutter/material.dart';
import '../controllers/application_details_controller.dart';

/// ApplicationSectionTabs renders the 4 segmented tabs:
/// Overview | Documents | Timeline | Payments
class ApplicationSectionTabs extends StatelessWidget {
  final ApplicationDetailsTab selectedTab;
  final ValueChanged<ApplicationDetailsTab> onTabSelected;

  const ApplicationSectionTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: ApplicationDetailsTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          final isFirst = tab == ApplicationDetailsTab.values.first;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isFirst ? 0 : 6.0),
              child: Material(
                color: isSelected ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onTabSelected(tab),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getTabIcon(tab),
                          size: 14,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            tab.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getTabIcon(ApplicationDetailsTab tab) {
    switch (tab) {
      case ApplicationDetailsTab.overview:
        return Icons.article_rounded;
      case ApplicationDetailsTab.documents:
        return Icons.description_outlined;
      case ApplicationDetailsTab.timeline:
        return Icons.access_time_rounded;
      case ApplicationDetailsTab.payments:
        return Icons.credit_card_rounded;
    }
  }
}
