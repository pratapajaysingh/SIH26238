import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/verification.dart';
import 'verification_repository.dart';

/// ApiVerificationRepository implements VerificationRepository by consuming:
/// - GET /api/v1/applications/{id}/verifications
class ApiVerificationRepository implements VerificationRepository {
  final ApiClient apiClient;

  ApiVerificationRepository({required this.apiClient});

  @override
  Future<List<VerificationRecord>> getApplicationVerifications(String applicationId) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.applicationVerifications(applicationId),
    );

    if (response.success && response.data != null) {
      final list = response.data!;
      return list
          .map((item) => VerificationRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to retrieve verification records',
    );
  }
}
