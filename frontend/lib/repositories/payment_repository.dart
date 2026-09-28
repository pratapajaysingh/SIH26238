import '../models/payment.dart';

/// PaymentRepository defines the contract for accessing payment and DBT aggregation data.
/// Conforms to GET /api/v1/applications/{id}/payments (Playbook Section 16 & API Contract).
abstract class PaymentRepository {
  /// Retrieves DBT and sanction payment records for a specific scholarship application.
  Future<List<PaymentRecord>> getApplicationPayments(String applicationId);
}
