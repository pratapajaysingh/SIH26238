import 'package:flutter/material.dart';
import '../../../core/enums/role_enum.dart';
import '../../../core/theme/app_colors.dart';

/// RoleSegmentedControl provides the high-fidelity segmented role switcher:
/// [Student] (default/active), [Admin], [Institute].
class RoleSegmentedControl extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleSegmentedControl({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    const roles = [
      UserRole.student,
      UserRole.admin,
      UserRole.institute,
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: roles.map((role) {
          final isSelected = role == selectedRole;
          return Expanded(
            child: GestureDetector(
              onTap: () => onRoleChanged(role),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF111827) : Colors.transparent,
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      role.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.white : const Color(0xFF374151),
                        letterSpacing: 0.1,
                      ),
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
}
