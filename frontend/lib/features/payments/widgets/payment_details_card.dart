import 'package:flutter/material.dart';

/// PaymentDetailsCard renders the comprehensive 7-item metadata card:
/// 1. Sanction Order Number
/// 2. Sanction Date
/// 3. Sanctioned Amount
/// 4. Payment Method
/// 5. Bank Account
/// 6. Expected Credit Date
/// 7. Payment Reference
/// Matching the exact visual specifications from the reference image.
class PaymentDetailsCard extends StatelessWidget {
  final String sanctionOrderNumber;
  final String sanctionDate;
  final String sanctionedAmount;
  final String paymentMethod;
  final String maskedAccountNumber;
  final String bankName;
  final String expectedCreditDate;
  final String paymentReference;
  final String paymentReferenceDate;

  const PaymentDetailsCard({
    super.key,
    required this.sanctionOrderNumber,
    required this.sanctionDate,
    required this.sanctionedAmount,
    required this.paymentMethod,
    required this.maskedAccountNumber,
    required this.bankName,
    required this.expectedCreditDate,
    required this.paymentReference,
    required this.paymentReferenceDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 14),

            // 1. Sanction Order Number
            _buildRow(
              icon: Icons.savings_outlined,
              label: 'Sanction Order Number',
              valueWidget: Text(
                sanctionOrderNumber,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            _buildDivider(),

            // 2. Sanction Date
            _buildRow(
              icon: Icons.description_outlined,
              label: 'Sanction Date',
              valueWidget: Text(
                sanctionDate,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            _buildDivider(),

            // 3. Sanctioned Amount
            _buildRow(
              icon: Icons.currency_rupee_rounded,
              label: 'Sanctioned Amount',
              valueWidget: Text(
                sanctionedAmount,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            _buildDivider(),

            // 4. Payment Method
            _buildRow(
              icon: Icons.account_balance_outlined,
              label: 'Payment Method',
              valueWidget: Text(
                paymentMethod,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            _buildDivider(),

            // 5. Bank Account
            _buildRow(
              icon: Icons.credit_card_rounded,
              label: 'Bank Account',
              valueWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    maskedAccountNumber,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bankName,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            _buildDivider(),

            // 6. Expected Credit Date
            _buildRow(
              icon: Icons.calendar_today_outlined,
              label: 'Expected Credit Date',
              valueWidget: Text(
                expectedCreditDate,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            _buildDivider(),

            // 7. Payment Reference
            _buildRow(
              icon: Icons.info_rounded,
              iconColor: const Color(0xFF2563EB),
              iconBgColor: const Color(0xFFEFF6FF),
              label: 'Payment Reference',
              valueWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    paymentReference,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    paymentReferenceDate,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
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

  Widget _buildRow({
    required IconData icon,
    Color? iconColor,
    Color? iconBgColor,
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Icon Container
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBgColor ?? const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? const Color(0xFF374151),
          ),
        ),

        const SizedBox(width: 12),

        // Middle Label
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Right Value
        Flexible(
          child: valueWidget,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(
        height: 1,
        thickness: 0.8,
        color: Color(0xFFF3F4F6),
      ),
    );
  }
}
