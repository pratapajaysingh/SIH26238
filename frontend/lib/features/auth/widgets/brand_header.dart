import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// BrandHeader renders the TribalSetu logo, tagline, supporting description,
/// and the subtle pagination indicator dots matching the reference design.
class BrandHeader extends StatelessWidget {
  final int activeDotIndex;
  final int totalDots;

  const BrandHeader({
    super.key,
    this.activeDotIndex = 0,
    this.totalDots = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // TribalSetu Logo + Tagline Asset
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Image.asset(
            AssetConstants.tribalSetuLogo,
            height: 68,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Column(
              children: const [
                Icon(Icons.terrain_rounded, size: 36, color: AppColors.black),
                SizedBox(height: 4),
                Text(AppStrings.appName, style: AppTypography.brandHero),
                SizedBox(height: 2),
                Text(AppStrings.tagline, style: AppTypography.tagline),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Subtitle / Mission Statement
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            AppStrings.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              height: 1.35,
              letterSpacing: 0.1,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Indicator Dots (Active Pill + Muted Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalDots, (index) {
            final isActive = index == activeDotIndex;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              height: 3.5,
              width: isActive ? 18 : 5,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF1F2937) : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}
