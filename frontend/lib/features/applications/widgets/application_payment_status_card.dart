import 'package:flutter/material.dart';
import '../../../core/enums/payment_status.dart';
import '../../../models/payment.dart';

/// ApplicationPaymentStatusCard renders the "Payment / DBT Status" card on the Overview tab:
/// - Rupee icon in light orange circle
/// - Title & explanatory subtitle
/// - Status pill ("Not Disbursed" or payment status)
/// - Subtitle note ("Payment will be initiated after final approval.")
class ApplicationPaymentStatusCard extends StatelessWidget {
  final PaymentRecord? payment;
  final VoidCallback? onTap;

  const ApplicationPaymentStatusCard({
    super.key,
    this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(payment?.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Left Rupee Circle Badge
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                '₹',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB45309),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Middle Content: Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Payment / DBT Status',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: -0.1,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Your scholarship amount will be transferred directly to your bank account after approval.',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right Status Pill and Subtext
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: statusConfig.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusConfig.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusConfig.textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Payment will be initiated\nafter final approval.',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  ({Color background, Color textColor, String label}) _getStatusConfig(PaymentStatus? status) {
    if (status == null || status == PaymentStatus.processing) {
      return (
        background: const Color(0xFFFEF3C7),
        textColor: const Color(0xFFD97706),
        label: 'Not Disbursed',
      );
    }
    switch (status) {
      case PaymentStatus.credited:
        return (
          background: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF15803D),
          label: 'Credited',
        );
      case PaymentStatus.dbtInitiated:
        return (
          background: const Color(0xFFDBEAFE),
          textColor: const Color(0xFF1D4ED8),
          label: 'DBT Initiated',
        );
      case PaymentStatus.sanctioned:
        return (
          background: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF15803D),
          label: 'Sanctioned',
        );
      case PaymentStatus.failed:
        return (
          background: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFDC2626),
          label: 'Failed',
        );
      default:
        return (
          background: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFD97706),
          label: 'Not Disbursed',
        );
    }
  }
}
