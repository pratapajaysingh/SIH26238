import '../core/enums/payment_status.dart';
import '../models/payment.dart';
import 'payment_repository.dart';

/// MockPaymentRepository provides deterministic payment and DBT aggregation data
/// conforming to the database schema and API contract (GET /api/v1/applications/{id}/payments).
class MockPaymentRepository implements PaymentRepository {
  final Duration latency;

  MockPaymentRepository({this.latency = const Duration(milliseconds: 300)});

  @override
  Future<List<PaymentRecord>> getApplicationPayments(String applicationId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    if (applicationId == 'app-empty') {
      return [];
    }

    if (applicationId == 'app-2023-st-05') {
      return [
        PaymentRecord(
          id: 'pay-05',
          applicationId: applicationId,
          studentId: 'TS2024S10023',
          schemeId: 'scheme-nos-st-05',
          schemeName: 'National Overseas Scholarship for ST Students',
          amount: 2400000.0,
          status: PaymentStatus.credited,
          transactionRef: 'PFMS202312229988',
          paymentDate: DateTime(2023, 12, 22),
          sourceSystem: 'PFMS',
          bankName: 'State Bank of India',
          maskedAccountNumber: 'XXXXXX5432',
          createdAt: DateTime(2023, 12, 10),
          updatedAt: DateTime(2023, 12, 22),
        ),
      ];
    }

    // Default payment record matching reference image ("Payment Processing" state)
    return [
      PaymentRecord(
        id: 'pay-01',
        applicationId: applicationId,
        studentId: 'TS2024S10023',
        schemeId: 'scheme-pms-st-01',
        schemeName: 'Post Matric Scholarship for ST Students',
        amount: 48000.0,
        status: PaymentStatus.processing,
        transactionRef: 'TRI-PAY-2026-001234',
        paymentDate: null,
        sourceSystem: 'DBT',
        externalPaymentId: 'TRI-2026-0009876',
        bankName: 'State Bank of India',
        maskedAccountNumber: 'XXXX XXXX 1234',
        createdAt: DateTime(2026, 1, 10),
        updatedAt: DateTime(2026, 1, 10),
      ),
    ];
  }
}
