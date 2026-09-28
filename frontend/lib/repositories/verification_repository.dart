import '../models/verification.dart';

/// VerificationRepository defines the contract for fetching application verification records.
/// Strictly conforms to:
/// - GET /api/v1/applications/{id}/verifications
abstract class VerificationRepository {
  /// Fetches verification records for a specific application UUID.
  Future<List<VerificationRecord>> getApplicationVerifications(String applicationId);
}
