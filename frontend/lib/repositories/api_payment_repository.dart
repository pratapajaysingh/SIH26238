import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/payment.dart';
import 'payment_repository.dart';

/// ApiPaymentRepository implements PaymentRepository by consuming:
/// - GET /api/v1/applications/{id}/payments
class ApiPaymentRepository implements PaymentRepository {
  final ApiClient apiClient;

  ApiPaymentRepository({required this.apiClient});

  @override
  Future<List<PaymentRecord>> getApplicationPayments(String applicationId) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.applicationPayments(applicationId),
    );

    if (response.success && response.data != null) {
      final list = response.data!;
      return list
          .map((item) => PaymentRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to retrieve payment records',
    );
  }
}
