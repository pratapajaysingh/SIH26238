import 'package:flutter/material.dart';

/// AppColors defines the authoritative color palette for TribalSetu.
/// Conforms to the visual specification: Black, White, Off-white, Soft grey,
/// subtle neutral gradients, and minimal official accent usage.
class AppColors {
  AppColors._();

  // Core Monochromes
  static const Color black = Color(0xFF111827);
  static const Color pureBlack = Color(0xFF000000);
  static const Color darkCharcoal = Color(0xFF1F2937);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF9FAFB);
  static const Color background = Color(0xFFFFFFFF);

  // Greys & Neutrals
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color divider = Color(0xFFE5E7EB);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textPlaceholder = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Interactive States
  static const Color activeTabUnderline = Color(0xFF111827);
  static const Color roleSelectorBackground = Color(0xFFF3F4F6);
  static const Color roleActiveBackground = Color(0xFF111827);
  static const Color roleActiveText = Color(0xFFFFFFFF);
  static const Color roleInactiveText = Color(0xFF4B5563);

  // Action Cards
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color digilockerBrand = Color(0xFF5B3EE4);

  // Status & Notification Accents (minimal and restrained)
  static const Color statusSuccess = Color(0xFF15803D);
  static const Color statusWarning = Color(0xFFB45309);
  static const Color statusError = Color(0xFFB91C1C);
  static const Color statusInfo = Color(0xFF1D4ED8);
}
