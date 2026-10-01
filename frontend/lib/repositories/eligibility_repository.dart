import '../models/conflict_check_result.dart';
import '../models/eligibility_check_result.dart';

/// EligibilityRepository defines the abstract contract for evaluating scheme eligibility.
/// Strictly conforms to Team Development & Integration Playbook:
/// - POST /api/v1/eligibility/check
/// - POST /api/v1/eligibility/conflict-check
abstract class EligibilityRepository {
  /// Evaluates scheme eligibility for the given student and scholarship scheme.
  Future<EligibilityCheckResult> checkEligibility({
    required String studentId,
    required String schemeId,
  });

  /// Evaluates one-scheme-at-a-time policy and returns existing conflicting applications if any.
  Future<ConflictCheckResult> checkConflict({
    required String studentId,
    required String schemeId,
  });
}

