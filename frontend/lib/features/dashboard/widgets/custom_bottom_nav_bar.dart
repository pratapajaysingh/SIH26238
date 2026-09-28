import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';

/// CustomBottomNavBar faithfully implements the bottom navigation bar from the visual reference.
/// Features:
/// - Fixed white bar with rounded top corners
/// - Elevated dark circular JAGO assistant button in center
/// - Home tab with active underline indicator
/// - Scholarships, Applications, and Profile tabs
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onJagoTap;

  const CustomBottomNavBar({
    super.key,
    this.selectedIndex = 0,
    required this.onItemSelected,
    this.onJagoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 4 Regular Tabs Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    // Tab 0: Home
                    Expanded(
                      child: _buildNavItem(
                        index: 0,
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isSelected: selectedIndex == 0,
                      ),
                    ),

                    // Tab 1: Scholarships
                    Expanded(
                      child: _buildNavItem(
                        index: 1,
                        icon: Icons.description_outlined,
                        label: 'Scholarships',
                        isSelected: selectedIndex == 1,
                      ),
                    ),

                    // Center Placeholder Gap for elevated JAGO button
                    const SizedBox(width: 64),

                    // Tab 2: Applications
                    Expanded(
                      child: _buildNavItem(
                        index: 2,
                        icon: Icons.assignment_outlined,
                        label: 'Applications',
                        isSelected: selectedIndex == 2,
                      ),
                    ),

                    // Tab 3: Profile
                    Expanded(
                      child: _buildNavItem(
                        index: 3,
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        isSelected: selectedIndex == 3,
                      ),
                    ),
                  ],
                ),
              ),

              // Elevated Center JAGO Button
              Positioned(
                top: -14,
                child: GestureDetector(
                  onTap: onJagoTap ?? () => onItemSelected(4),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AssetConstants.jagoRobotWhite,
                          width: 22,
                          height: 22,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.smart_toy_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'JAGO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 23,
            color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 3),
          // Active Indicator Underline
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5,
            width: isSelected ? 26 : 0,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF111827) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
