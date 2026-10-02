import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/admin_dashboard_data.dart';
import '../models/manual_review_item.dart';
import '../models/unreached_beneficiary_item.dart';
import 'admin_repository.dart';

/// ApiAdminRepository connects directly to the FastAPI analytics and manual review endpoints.
class ApiAdminRepository implements AdminRepository {
  final ApiClient apiClient;

  ApiAdminRepository({required this.apiClient});

  @override
  Future<AdminDashboardData> getDashboardAnalytics() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.analyticsDashboard,
    );

    if (response.success && response.data != null) {
      return AdminDashboardData.fromJson(response.data!);
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to load ministry dashboard analytics',
    );
  }

  @override
  Future<List<ManualReviewItem>> getManualReviewQueue() async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.manualReviews,
    );

    if (response.success && response.data != null) {
      return response.data!
          .map((item) => ManualReviewItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to load manual review queue',
    );
  }

  @override
  Future<ManualReviewItem> decideManualReview(
    String reviewId, {
    required String action,
    String? remarks,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.manualReviewDecide(reviewId),
      body: {
        'action': action,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      },
    );

    if (response.success && response.data != null) {
      return ManualReviewItem.fromJson(response.data!);
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to record manual review decision',
    );
  }

  @override
  Future<List<UnreachedBeneficiaryItem>> getUnreachedBeneficiaries({bool all = false}) async {
    final endpoint = all ? ApiConstants.analyticsUnreachedAll : ApiConstants.analyticsUnreached;
    final response = await apiClient.get<Map<String, dynamic>>(endpoint);

    if (response.success && response.data != null) {
      final rawList = response.data!['results'] as List<dynamic>? ?? [];
      return rawList
          .map((item) => UnreachedBeneficiaryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to load unreached student records',
    );
  }

  @override
  Future<bool> sendOutreachNotification({
    String? demoId,
    String? studentId,
    String? title,
    String? message,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.analyticsOutreach,
      body: {
        'demo_id': ?demoId,
        'student_id': ?studentId,
        'title': ?title,
        'message': ?message,
      },
    );

    return response.success;
  }
}
