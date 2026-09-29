import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/network/api_response.dart';
import '../models/payment.dart';
import 'payment_repository.dart';

/// ApiPaymentRepository implements PaymentRepository by consuming:
/// - GET /api/v1/applications/{id}/payment-status
/// - Fallback alias: GET /api/v1/applications/{id}/payments
class ApiPaymentRepository implements PaymentRepository {
  final ApiClient apiClient;

  ApiPaymentRepository({required this.apiClient});

  @override
  Future<List<PaymentRecord>> getApplicationPayments(String applicationId) async {
    ApiResponse<dynamic> response;
    try {
      response = await apiClient.get<dynamic>(
        ApiConstants.applicationPaymentStatus(applicationId),
      );
    } catch (_) {
      // Fallback alias
      response = await apiClient.get<dynamic>(
        ApiConstants.applicationPayments(applicationId),
      );
    }

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => PaymentRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        return [PaymentRecord.fromJson(data)];
      }
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to retrieve payment records',
    );
  }
}
