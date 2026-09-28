import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';

/// JagoIntroHeader renders the "Meet JAGO" title section with robot icon,
/// subtitle, and descriptive explanation matching the reference image.
class JagoIntroHeader extends StatelessWidget {
  const JagoIntroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with Robot Icon and Titles
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // JAGO Robot Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  AssetConstants.jagoRobot,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.smart_toy_rounded,
                    size: 40,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Meet ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              letterSpacing: -0.4,
                            ),
                          ),
                          TextSpan(
                            text: 'JAGO',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Your AI Guide for Scholarships',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Descriptive Subtitle
          const Text(
            'Ask anything about schemes, eligibility, documents,\napplications or your scholarship journey.',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.35,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
