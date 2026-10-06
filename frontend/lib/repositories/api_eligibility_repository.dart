import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/conflict_check_result.dart';
import '../models/eligibility_check_result.dart';
import 'eligibility_repository.dart';

/// ApiEligibilityRepository implements EligibilityRepository by delegating to ApiClient.
/// Consumes:
/// - POST /api/v1/eligibility/check
/// - POST /api/v1/eligibility/conflict-check
class ApiEligibilityRepository implements EligibilityRepository {
  final ApiClient apiClient;

  ApiEligibilityRepository({required this.apiClient});

  @override
  Future<EligibilityCheckResult> checkEligibility({
    required String studentId,
    required String schemeId,
  }) async {
    // In live mode, resolve the authentic student ID directly from GET /students/me
    final sRes = await apiClient.get<Map<String, dynamic>>(ApiConstants.studentsMe);
    if (!sRes.success || sRes.data == null || sRes.data!['id'] == null || sRes.data!['id'].toString().isEmpty) {
      throw ApiException(
        sRes.message.isNotEmpty
            ? sRes.message
            : 'Active student record not found for authenticated user',
      );
    }
    final String effectiveStudentId = sRes.data!['id'].toString();

    // Scheme ID must be the API's own ID; no guessing or fallback
    if (schemeId.trim().isEmpty) {
      throw ApiException('Scheme ID is required for eligibility check');
    }
    final String effectiveSchemeId = schemeId;

    final response = await apiClient.post<EligibilityCheckResult>(
      ApiConstants.eligibilityCheck,
      body: {
        'student_id': effectiveStudentId,
        'scholarship_id': effectiveSchemeId,
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

  @override
  Future<ConflictCheckResult> checkConflict({
    required String studentId,
    required String schemeId,
  }) async {
    // In live mode, resolve the authentic student ID directly from GET /students/me
    final sRes = await apiClient.get<Map<String, dynamic>>(ApiConstants.studentsMe);
    if (!sRes.success || sRes.data == null || sRes.data!['id'] == null || sRes.data!['id'].toString().isEmpty) {
      throw ApiException(
        sRes.message.isNotEmpty
            ? sRes.message
            : 'Active student record not found for authenticated user',
      );
    }
    final String effectiveStudentId = sRes.data!['id'].toString();

    // Scheme ID must be the API's own ID; no guessing or fallback
    if (schemeId.trim().isEmpty) {
      throw ApiException('Scheme ID is required for conflict check');
    }
    final String effectiveSchemeId = schemeId;

    final response = await apiClient.post<ConflictCheckResult>(
      ApiConstants.eligibilityConflictCheck,
      body: {
        'student_id': effectiveStudentId,
        'scholarship_id': effectiveSchemeId,
      },
      fromJson: (json) =>
          ConflictCheckResult.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to evaluate scheme conflicts',
    );
  }
}
