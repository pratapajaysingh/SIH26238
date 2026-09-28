import '../models/eligibility_check_result.dart';

/// EligibilityRepository defines the abstract contract for evaluating scheme eligibility.
/// Strictly conforms to Team Development & Integration Playbook:
/// - POST /api/v1/eligibility/check
abstract class EligibilityRepository {
  /// Evaluates scheme eligibility for the given student and scholarship scheme.
  Future<EligibilityCheckResult> checkEligibility({
    required String studentId,
    required String schemeId,
  });
}
