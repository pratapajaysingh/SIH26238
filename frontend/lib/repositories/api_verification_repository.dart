import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/verification.dart';
import 'verification_repository.dart';

/// ApiVerificationRepository implements VerificationRepository by consuming:
/// - GET /api/v1/applications/{id}/verifications
/// - POST /api/v1/applications/{id}/verifications
/// - POST /api/v1/verifications/{id}/execute
class ApiVerificationRepository implements VerificationRepository {
  final ApiClient apiClient;

  ApiVerificationRepository({required this.apiClient});

  @override
  Future<List<VerificationRecord>> getApplicationVerifications(String applicationId) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.applicationVerifications(applicationId),
    );

    if (response.success && response.data != null) {
      return response.data!
          .map((item) => VerificationRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to retrieve verification records',
    );
  }

  @override
  Future<VerificationRecord> createVerification({
    required String applicationId,
    required String documentId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.applicationVerifications(applicationId),
      body: {'document_id': documentId},
    );
    if (response.success && response.data != null) {
      return VerificationRecord.fromJson(response.data!);
    }
    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to create verification record',
    );
  }

  @override
  Future<Map<String, dynamic>> executeVerification(String verificationId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.verificationExecute(verificationId),
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to execute verification',
    );
  }
}
