import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/asset_constants.dart';

/// BottomBrandingBar renders the bottom institutional motto
/// and the tribal landscape illustration along the lower edge of the screen.
class BottomBrandingBar extends StatelessWidget {
  final double landscapeHeight;

  const BottomBrandingBar({
    super.key,
    this.landscapeHeight = 135,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Education • Opportunity • Empowerment
        const Padding(
          padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
          child: Text(
            AppStrings.bottomMotto,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Bottom Tribal Landscape Illustration
        SizedBox(
          width: double.infinity,
          height: landscapeHeight,
          child: Image.asset(
            AssetConstants.bottomTribalLandscape,
            fit: BoxFit.fill,
            alignment: Alignment.bottomCenter,
            errorBuilder: (context, error, stackTrace) => const SizedBox(height: 60),
          ),
        ),
      ],
    );
  }
}
