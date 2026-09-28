import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/eligibility_check_result.dart';
import 'eligibility_repository.dart';

/// ApiEligibilityRepository implements EligibilityRepository by delegating to ApiClient.
/// Consumes:
/// - POST /api/v1/eligibility/check
/// Request body:
/// ```json
/// {
///   "student_id": "uuid",
///   "scheme_id": "uuid"
/// }
/// ```
class ApiEligibilityRepository implements EligibilityRepository {
  final ApiClient apiClient;

  ApiEligibilityRepository({required this.apiClient});

  @override
  Future<EligibilityCheckResult> checkEligibility({
    required String studentId,
    required String schemeId,
  }) async {
    final response = await apiClient.post<EligibilityCheckResult>(
      ApiConstants.eligibilityCheck,
      body: {
        'student_id': studentId,
        'scheme_id': schemeId,
      },
      fromJson: (json) =>
          EligibilityCheckResult.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to evaluate eligibility',
    );
  }
}
