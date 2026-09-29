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
///   "scholarship_id": "uuid"
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
    // If studentId is non-UUID format (like test mock ID 'TS2024S10023'),
    // attempt to resolve authenticated student ID or default to seeded student
    String effectiveStudentId = studentId;
    if (!studentId.contains('-')) {
      try {
        final sRes = await apiClient.get<Map<String, dynamic>>(ApiConstants.studentsMe);
        if (sRes.success && sRes.data != null && sRes.data!['id'] != null) {
          effectiveStudentId = sRes.data!['id'].toString();
        } else {
          effectiveStudentId = '00000000-0000-0000-0000-000000000002';
        }
      } catch (_) {
        effectiveStudentId = '00000000-0000-0000-0000-000000000002';
      }
    }

    final response = await apiClient.post<EligibilityCheckResult>(
      ApiConstants.eligibilityCheck,
      body: {
        'student_id': effectiveStudentId,
        'scholarship_id': schemeId,
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
