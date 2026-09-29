import '../core/enums/payment_status.dart';

/// PaymentRecord represents a DBT payment/sanction aggregation item.
/// Follows database schema & API contract:
/// GET /api/v1/applications/{id}/payments
class PaymentRecord {
  final String id;
  final String applicationId;
  final String? studentId;
  final String? schemeId;
  final String schemeName;
  final double amount;
  final PaymentStatus status;
  final String? transactionRef;
  final DateTime? paymentDate;
  final String? sourceSystem;
  final String? externalPaymentId;
  final String? bankName;
  final String? maskedAccountNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? message;
  final String? disbursementMode;
  final String? evaluationMode;

  const PaymentRecord({
    required this.id,
    required this.applicationId,
    this.studentId,
    this.schemeId,
    this.schemeName = 'Scholarship Grant',
    required this.amount,
    required this.status,
    this.transactionRef,
    this.paymentDate,
    this.sourceSystem,
    this.externalPaymentId,
    this.bankName,
    this.maskedAccountNumber,
    this.createdAt,
    this.updatedAt,
    this.message,
    this.disbursementMode,
    this.evaluationMode,
  });

  // Backward-compatibility getters
  String? get dbtReferenceNumber => transactionRef;
  DateTime? get transactionDate => paymentDate;
  PaymentStatus get paymentStatus => status;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['payment_status'] ?? json['status'] ?? 'PROCESSING').toString();
    final rawDate = json['payment_date'] ?? json['transaction_date'] ?? json['created_at'];
    final rawRef = json['payment_reference'] ?? json['transaction_ref'] ?? json['dbt_reference_number'];
    final rawId = (json['id'] ?? json['application_id'] ?? 'PAY-001').toString();
    final rawAppId = (json['application_id'] ?? json['id'] ?? '').toString();

    return PaymentRecord(
      id: rawId,
      applicationId: rawAppId,
      studentId: json['student_id'] as String?,
      schemeId: json['scheme_id'] as String?,
      schemeName: json['scheme_name'] as String? ?? 'Scholarship Grant',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: PaymentStatus.fromString(rawStatus),
      transactionRef: rawRef as String?,
      paymentDate: rawDate != null ? DateTime.tryParse(rawDate.toString()) : null,
      sourceSystem: json['source_system'] as String? ?? json['disbursement_mode'] as String?,
      externalPaymentId: json['external_payment_id'] as String?,
      bankName: json['bank_name'] as String?,
      maskedAccountNumber: json['masked_account_number'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      message: json['message'] as String?,
      disbursementMode: json['disbursement_mode'] as String?,
      evaluationMode: json['evaluation_mode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      if (studentId != null) 'student_id': studentId,
      if (schemeId != null) 'scheme_id': schemeId,
      'scheme_name': schemeName,
      'amount': amount,
      'status': status.value,
      'payment_status': status.value,
      if (transactionRef != null) 'transaction_ref': transactionRef,
      if (paymentDate != null) 'payment_date': paymentDate!.toIso8601String(),
      if (sourceSystem != null) 'source_system': sourceSystem,
      if (externalPaymentId != null) 'external_payment_id': externalPaymentId,
      if (bankName != null) 'bank_name': bankName,
      if (maskedAccountNumber != null) 'masked_account_number': maskedAccountNumber,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
