import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

/// EmailInputField renders the input container for entering student/user email addresses.
class EmailInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool hasError;
  final bool isEnabled;

  const EmailInputField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hasError = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.white : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? AppColors.statusError : const Color(0xFFE5E7EB),
          width: 1.1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Email Icon Prefix
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Icon(
              Icons.mail_outline_rounded,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ),

          // Vertical Divider
          Container(
            height: 20,
            width: 1,
            color: const Color(0xFFE5E7EB),
          ),

          const SizedBox(width: 12),

          // Email Input Text Field
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEnabled,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: true,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted?.call(),
              decoration: const InputDecoration(
                hintText: AppStrings.emailPlaceholder,
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(right: 14),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
