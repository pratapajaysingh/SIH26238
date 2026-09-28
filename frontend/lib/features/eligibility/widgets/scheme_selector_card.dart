import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../models/scholarship.dart';

/// SchemeSelectorCard renders the "Select a Scholarship Scheme" section and dropdown card
/// matching the exact visual target from the reference image.
class SchemeSelectorCard extends StatelessWidget {
  final List<Scholarship> schemes;
  final Scholarship? selectedScheme;
  final ValueChanged<Scholarship> onSchemeSelected;
  final bool isLoading;

  const SchemeSelectorCard({
    super.key,
    required this.schemes,
    required this.selectedScheme,
    required this.onSchemeSelected,
    this.isLoading = false,
  });

  void _showSchemePicker(BuildContext context) {
    if (schemes.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Scholarship Scheme',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: schemes.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  itemBuilder: (context, index) {
                    final item = schemes[index];
                    final isSelected = selectedScheme?.id == item.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          AssetConstants.emblemStandalone,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.account_balance_rounded,
                            size: 20,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      subtitle: Text(
                        '${item.ministry}\nGovernment of India',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF111827),
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        onSchemeSelected(item);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Select a Scholarship Scheme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          const Text(
            'Choose the scheme you want to check eligibility for.',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 12),

          // Selector Card
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('scheme_selector_card_inkwell'),
              onTap: isLoading ? null : () => _showSchemePicker(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Emblem badge container
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        AssetConstants.emblemStandalone,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.account_balance_rounded,
                          size: 26,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Scheme name & ministry
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedScheme?.name ?? 'Loading schemes...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            selectedScheme != null
                                ? '${selectedScheme!.ministry}\nGovernment of India'
                                : 'Please wait...',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Down Chevron Icon
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: Color(0xFF111827),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
