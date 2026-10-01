import '../models/admin_dashboard_data.dart';
import '../models/manual_review_item.dart';
import '../models/unreached_beneficiary_item.dart';

/// AdminRepository defines the abstract contract for Ministry of Tribal Affairs
/// analytics, manual exception review, and unreached student outreach.
abstract class AdminRepository {
  /// Fetches ministry-side overview analytics
  Future<AdminDashboardData> getDashboardAnalytics();

  /// Fetches the queue of pending manual verification reviews
  Future<List<ManualReviewItem>> getManualReviewQueue();

  /// Approves or rejects a manual verification review
  Future<ManualReviewItem> decideManualReview(
    String reviewId, {
    required String action, // "APPROVE" or "REJECT"
    String? remarks,
  });

  /// Fetches unreached ST students or all enrolled students
  Future<List<UnreachedBeneficiaryItem>> getUnreachedBeneficiaries({bool all = false});

  /// Dispatches an awareness outreach notification to an unreached student
  Future<bool> sendOutreachNotification({
    String? demoId,
    String? studentId,
    String? title,
    String? message,
  });
}
