import 'package:flutter/material.dart';
import '../../../core/enums/payment_status.dart';

/// PaymentProcessingCalloutCard renders the warm yellow status banner:
/// - Left circular amber badge with hourglass icon
/// - "Payment Processing" bold title
/// - Explanatory message regarding DBT transfer
class PaymentProcessingCalloutCard extends StatelessWidget {
  final PaymentStatus status;

  const PaymentProcessingCalloutCard({
    super.key,
    this.status = PaymentStatus.processing,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: config.borderColor,
            width: 1.1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Icon Circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: config.iconContainerColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                config.icon,
                color: config.iconColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    config.description,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4B5563),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _CalloutConfig _getConfig(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.credited:
        return const _CalloutConfig(
          backgroundColor: Color(0xFFECFDF5),
          borderColor: Color(0xFFA7F3D0),
          iconContainerColor: Color(0xFF6EE7B7),
          iconColor: Color(0xFF065F46),
          icon: Icons.check_circle_rounded,
          title: 'Amount Credited',
          description:
              'Your scholarship amount has been successfully transferred to your bank account via Direct Benefit Transfer.',
        );

      case PaymentStatus.failed:
        return const _CalloutConfig(
          backgroundColor: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFECACA),
          iconContainerColor: Color(0xFFFCA5A5),
          iconColor: Color(0xFF991B1B),
          icon: Icons.error_outline_rounded,
          title: 'Payment Failed',
          description:
              'Direct Benefit Transfer could not be completed. Please ensure your bank account is active and linked with Aadhaar.',
        );

      case PaymentStatus.sanctioned:
        return const _CalloutConfig(
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFEF08A),
          iconContainerColor: Color(0xFFFDE047),
          iconColor: Color(0xFF78350F),
          icon: Icons.hourglass_top_rounded,
          title: 'Sanction Order Released',
          description:
              'Your scholarship amount has been sanctioned and is scheduled for DBT processing to your bank account.',
        );

      case PaymentStatus.processing:
      case PaymentStatus.dbtInitiated:
        return const _CalloutConfig(
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFEF08A),
          iconContainerColor: Color(0xFFFDE047),
          iconColor: Color(0xFF78350F),
          icon: Icons.hourglass_top_rounded,
          title: 'Payment Processing',
          description:
              'Your scholarship amount has been sanctioned and is currently being processed for DBT transfer to your bank account.',
        );
    }
  }
}

class _CalloutConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconContainerColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;

  const _CalloutConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconContainerColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
  });
}
