/// AdminDashboardData represents the aggregated metrics from
/// GET /api/v1/analytics/dashboard.
class AdminDashboardData {
  final int totalApplications;
  final int totalSanctioned;
  final int totalCompleted;
  final int totalRejected;
  final int totalDeficiency;
  final List<SchemeWiseStat> schemeWiseApplications;
  final int totalVerifications;
  final int pendingVerifications;
  final int totalManualReviews;
  final int openManualReviews;
  final int totalDisbursementEligible;
  final int totalEnrolled;
  final int totalMatched;
  final int totalUnreached;
  final double unreachedPercentage;

  const AdminDashboardData({
    required this.totalApplications,
    required this.totalSanctioned,
    required this.totalCompleted,
    required this.totalRejected,
    required this.totalDeficiency,
    required this.schemeWiseApplications,
    required this.totalVerifications,
    required this.pendingVerifications,
    required this.totalManualReviews,
    required this.openManualReviews,
    required this.totalDisbursementEligible,
    required this.totalEnrolled,
    required this.totalMatched,
    required this.totalUnreached,
    required this.unreachedPercentage,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    final vSummary = json['verification_summary'] as Map<String, dynamic>? ?? {};
    final mSummary = json['manual_review_summary'] as Map<String, dynamic>? ?? {};
    final pSummary = json['payment_summary'] as Map<String, dynamic>? ?? {};
    final uSummary = json['unreached_beneficiary_summary'] as Map<String, dynamic>? ?? {};
    final rawSchemes = json['scheme_wise_applications'] as List<dynamic>? ?? [];

    return AdminDashboardData(
      totalApplications: (json['total_applications'] as num?)?.toInt() ?? 0,
      totalSanctioned: (json['total_sanctioned'] as num?)?.toInt() ?? 0,
      totalCompleted: (json['total_completed'] as num?)?.toInt() ?? 0,
      totalRejected: (json['total_rejected'] as num?)?.toInt() ?? 0,
      totalDeficiency: (json['total_deficiency'] as num?)?.toInt() ?? 0,
      schemeWiseApplications: rawSchemes
          .map((s) => SchemeWiseStat.fromJson(s as Map<String, dynamic>))
          .toList(),
      totalVerifications: (vSummary['total'] as num?)?.toInt() ?? 0,
      pendingVerifications: (vSummary['pending'] as num?)?.toInt() ?? 0,
      totalManualReviews: (mSummary['total'] as num?)?.toInt() ?? 0,
      openManualReviews: (mSummary['open'] as num?)?.toInt() ?? 0,
      totalDisbursementEligible: (pSummary['total_disbursement_eligible'] as num?)?.toInt() ?? 0,
      totalEnrolled: (uSummary['total_enrolled'] as num?)?.toInt() ?? 0,
      totalMatched: (uSummary['total_matched'] as num?)?.toInt() ?? 0,
      totalUnreached: (uSummary['total_unreached'] as num?)?.toInt() ?? 0,
      unreachedPercentage: (uSummary['unreached_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SchemeWiseStat {
  final String scholarshipId;
  final int total;
  final int draft;
  final int submitted;
  final int inVerification;
  final int deficiency;
  final int sanctioned;
  final int rejected;
  final int completed;

  const SchemeWiseStat({
    required this.scholarshipId,
    required this.total,
    required this.draft,
    required this.submitted,
    required this.inVerification,
    required this.deficiency,
    required this.sanctioned,
    required this.rejected,
    required this.completed,
  });

  factory SchemeWiseStat.fromJson(Map<String, dynamic> json) {
    return SchemeWiseStat(
      scholarshipId: (json['scholarship_id'] ?? '').toString(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      draft: (json['draft'] as num?)?.toInt() ?? 0,
      submitted: (json['submitted'] as num?)?.toInt() ?? 0,
      inVerification: (json['in_verification'] as num?)?.toInt() ?? 0,
      deficiency: (json['deficiency'] as num?)?.toInt() ?? 0,
      sanctioned: (json['sanctioned'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
    );
  }
}
