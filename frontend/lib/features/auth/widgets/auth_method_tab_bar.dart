import 'package:flutter/material.dart';
import '../../../core/enums/auth_method_enum.dart';

/// AuthMethodTabBar renders the [Mobile Number] and [Aadhaar] selection tabs
/// with an active underline indicator matching the reference design.
class AuthMethodTabBar extends StatelessWidget {
  final AuthMethod selectedMethod;
  final ValueChanged<AuthMethod> onMethodChanged;

  const AuthMethodTabBar({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Mobile Number Tab
        Expanded(
          child: _buildTab(
            method: AuthMethod.mobile,
            icon: Icons.phone_outlined,
            activeIcon: Icons.phone,
            label: 'Mobile Number',
          ),
        ),

        const SizedBox(width: 8),

        // Aadhaar Tab
        Expanded(
          child: _buildTab(
            method: AuthMethod.aadhaar,
            icon: Icons.fingerprint_outlined,
            activeIcon: Icons.fingerprint,
            label: 'Aadhaar',
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required AuthMethod method,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = method == selectedMethod;

    return GestureDetector(
      onTap: () => onMethodChanged(method),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 18,
                    color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Underline Indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5,
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
