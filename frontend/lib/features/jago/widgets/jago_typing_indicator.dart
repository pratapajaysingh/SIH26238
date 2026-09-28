import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';

/// JagoTypingIndicator displays a polite assistant loading state with the JAGO avatar
/// and 3 animated pulsing dots while waiting for the API response.
class JagoTypingIndicator extends StatefulWidget {
  const JagoTypingIndicator({super.key});

  @override
  State<JagoTypingIndicator> createState() => _JagoTypingIndicatorState();
}

class _JagoTypingIndicatorState extends State<JagoTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JAGO Robot Avatar
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                AssetConstants.jagoRobot,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.smart_toy_rounded,
                  size: 18,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Typing Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: const Color(0xFFF1F3F5),
                width: 0.8,
              ),
            ),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.25;
                    final progress = (_animController.value - delay) % 1.0;
                    final bounce = (progress < 0.5)
                        ? (progress * 2)
                        : (2 - progress * 2);

                    return Container(
                      margin: EdgeInsets.only(
                        left: index > 0 ? 4 : 0,
                        bottom: bounce * 4,
                      ),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFF94A3B8),
                          const Color(0xFF111827),
                          bounce,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
