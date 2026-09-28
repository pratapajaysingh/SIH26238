import '../core/enums/verification_status.dart';

/// VerificationRecord represents one verification checkpoint in an application.
/// Conforms to Database Schema & API Contract (Section 7):
/// - id, application_id, document_id, verification_type, source_system,
///   status, confidence_score, external_reference, remarks, verified_at, created_at.
class VerificationRecord {
  final String id;
  final String applicationId;
  final String? documentId;
  final String? verificationType;
  final String? sourceSystem;
  final VerificationStatus status;
  final double? confidenceScore;
  final String? externalReference;
  final String? remarks;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final String stageName;
  final String? verifiedBy;
  final List<String> mismatchFields;

  const VerificationRecord({
    required this.id,
    required this.applicationId,
    this.documentId,
    this.verificationType,
    this.sourceSystem,
    required this.status,
    this.confidenceScore,
    this.externalReference,
    this.remarks,
    this.verifiedAt,
    this.createdAt,
    this.stageName = '',
    this.verifiedBy,
    this.mismatchFields = const [],
  });

  factory VerificationRecord.fromJson(Map<String, dynamic> json) {
    return VerificationRecord(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      documentId: json['document_id'] as String?,
      verificationType: json['verification_type'] as String?,
      sourceSystem: json['source_system'] as String?,
      status: VerificationStatus.fromString(json['status'] as String? ?? 'PENDING'),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      externalReference: json['external_reference'] as String?,
      remarks: json['remarks'] as String?,
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      stageName: json['stage_name'] as String? ?? '',
      verifiedBy: json['verified_by'] as String?,
      mismatchFields: (json['mismatch_fields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      if (documentId != null) 'document_id': documentId,
      if (verificationType != null) 'verification_type': verificationType,
      if (sourceSystem != null) 'source_system': sourceSystem,
      'status': status.value,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (externalReference != null) 'external_reference': externalReference,
      if (remarks != null) 'remarks': remarks,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'stage_name': stageName,
      if (verifiedBy != null) 'verified_by': verifiedBy,
      'mismatch_fields': mismatchFields,
    };
  }
}
