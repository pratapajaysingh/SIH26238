import '../models/verification.dart';

/// VerificationRepository defines the contract for fetching application verification records.
/// Strictly conforms to:
/// - GET /api/v1/applications/{id}/verifications
/// - POST /api/v1/applications/{id}/verifications
/// - POST /api/v1/verifications/{id}/execute
abstract class VerificationRepository {
  /// Fetches verification records for a specific application UUID.
  Future<List<VerificationRecord>> getApplicationVerifications(String applicationId);

  /// Creates a verification record on an application for a document.
  Future<VerificationRecord> createVerification({
    required String applicationId,
    required String documentId,
  });

  /// Executes verification processing for a verification record.
  Future<Map<String, dynamic>> executeVerification(String verificationId);
}
