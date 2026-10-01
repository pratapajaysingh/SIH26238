import 'package:flutter/material.dart';
import '../../../models/admin_dashboard_data.dart';

/// AdminOverviewTab displays the high-level ministry KPIs and scheme distributions.
class AdminOverviewTab extends StatelessWidget {
  final AdminDashboardData data;
  final VoidCallback onNavigateToReviews;
  final VoidCallback onNavigateToUnreached;

  const AdminOverviewTab({
    super.key,
    required this.data,
    required this.onNavigateToReviews,
    required this.onNavigateToUnreached,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'National Scholarship Operations Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Consolidated view across central and state tribal scholarship schemes.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),

          // Primary Metric Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Applications',
                  value: '${data.totalApplications}',
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFF2563EB),
                  bgLight: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Sanctioned',
                  value: '${data.totalSanctioned}',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF059669),
                  bgLight: const Color(0xFFECFDF5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Deficiencies',
                  value: '${data.totalDeficiency}',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFD97706),
                  bgLight: const Color(0xFFFFFBEB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Completed',
                  value: '${data.totalCompleted}',
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFF7C3AED),
                  bgLight: const Color(0xFFF5F3FF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Operational Action Banners
          _buildActionBanner(
            title: 'Manual Review Exceptions',
            count: data.openManualReviews,
            subtitle: '${data.openManualReviews} items awaiting nodal officer decision',
            buttonLabel: 'Open Review Queue',
            icon: Icons.rule_folder_outlined,
            color: const Color(0xFFDC2626),
            onTap: onNavigateToReviews,
          ),

          const SizedBox(height: 12),

          _buildActionBanner(
            title: 'Unreached ST Beneficiaries',
            count: data.totalUnreached,
            subtitle: '${data.unreachedPercentage}% enrolled students missing scholarship benefits',
            buttonLabel: 'View Unreached Students',
            icon: Icons.person_search_outlined,
            color: const Color(0xFFD97706),
            onTap: onNavigateToUnreached,
          ),

          const SizedBox(height: 24),

          // Payment & DBT Overview Card
          _buildPaymentCard(),

          const SizedBox(height: 24),

          // Scheme Breakdown Section
          const Text(
            'Scheme-Wise Application Distribution',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          if (data.schemeWiseApplications.isEmpty)
            const Text(
              'No scheme data available.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            )
          else
            ...data.schemeWiseApplications.map(_buildSchemeItem),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgLight,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBanner({
    required String title,
    required int count,
    required String subtitle,
    required String buttonLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'DBT Payment & Sanction Pipeline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Icon(Icons.payment_outlined, size: 18, color: Color(0xFF4B5563)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPaymentCol('Eligible', '${data.totalDisbursementEligible}'),
              _buildDivider(),
              _buildPaymentCol('Sanctioned', '${data.totalSanctioned}'),
              _buildDivider(),
              _buildPaymentCol('Credited', '${data.totalCompleted}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCol(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFE5E7EB),
    );
  }

  Widget _buildSchemeItem(SchemeWiseStat stat) {
    // Generate readable scheme title from ID or default
    final shortId = stat.scholarshipId.length > 8
        ? stat.scholarshipId.substring(stat.scholarshipId.length - 4)
        : stat.scholarshipId;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, size: 18, color: Color(0xFF4B5563)),
              const SizedBox(width: 8),
              Text(
                'Scheme #$shortId',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildBadge('Total: ${stat.total}', const Color(0xFFE5E7EB), const Color(0xFF374151)),
              const SizedBox(width: 6),
              if (stat.sanctioned > 0)
                _buildBadge('Sanctioned: ${stat.sanctioned}', const Color(0xFFD1FAE5), const Color(0xFF065F46)),
              if (stat.deficiency > 0) ...[
                const SizedBox(width: 6),
                _buildBadge('Deficiency: ${stat.deficiency}', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
