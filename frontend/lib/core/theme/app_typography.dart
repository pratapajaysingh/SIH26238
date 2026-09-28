import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTypography establishes the typographic scale for TribalSetu.
/// Conforms to the official, premium, restrained government digital service standard.
class AppTypography {
  AppTypography._();

  // Hero & Brand Typography
  static const TextStyle brandHero = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle tagline = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle description = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.45,
    letterSpacing: 0.1,
  );

  // Government Header
  static const TextStyle govtHeader = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: 0.2,
  );

  // Controls & Navigation
  static const TextStyle roleActive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.roleActiveText,
    letterSpacing: 0.1,
  );

  static const TextStyle roleInactive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.roleInactiveText,
    letterSpacing: 0.1,
  );

  static const TextStyle tabActive = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  static const TextStyle tabInactive = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: -0.1,
  );

  // Input & Buttons
  static const TextStyle inputText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle inputPlaceholder = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPlaceholder,
    letterSpacing: 0.1,
  );

  static const TextStyle countryCode = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.2,
  );

  // Action Cards (DigiLocker, APAAR)
  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.3,
  );

  // Dividers & Accents
  static const TextStyle dividerText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPlaceholder,
    letterSpacing: 1.0,
  );

  static const TextStyle languageSelector = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle bottomMotto = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.6,
  );
}
