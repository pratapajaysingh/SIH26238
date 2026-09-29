/// ApplicationDeficiency models document mismatch or review issues flagged on an application.
/// Follows GET /api/v1/applications/{id}/deficiencies.
class ApplicationDeficiency {
  final String id;
  final String applicationId;
  final String deficiencyType;
  final String type;
  final String category;
  final String? documentId;
  final String? documentName;
  final String? documentType;
  final String? verificationId;
  final String status;
  final String severity;
  final String message;
  final String reason;

  const ApplicationDeficiency({
    required this.id,
    required this.applicationId,
    required this.deficiencyType,
    required this.type,
    required this.category,
    this.documentId,
    this.documentName,
    this.documentType,
    this.verificationId,
    required this.status,
    required this.severity,
    required this.message,
    required this.reason,
  });

  factory ApplicationDeficiency.fromJson(Map<String, dynamic> json) {
    return ApplicationDeficiency(
      id: (json['id'] ?? '').toString(),
      applicationId: (json['application_id'] ?? '').toString(),
      deficiencyType: (json['deficiency_type'] ?? json['type'] ?? 'DOCUMENT_MISMATCH').toString(),
      type: (json['type'] ?? json['deficiency_type'] ?? 'DOCUMENT_MISMATCH').toString(),
      category: (json['category'] ?? 'VERIFICATION').toString(),
      documentId: json['document_id'] as String?,
      documentName: json['document_name'] as String?,
      documentType: json['document_type'] as String?,
      verificationId: json['verification_id'] as String?,
      status: (json['status'] ?? 'MISMATCH').toString(),
      severity: (json['severity'] ?? 'HIGH').toString(),
      message: (json['message'] ?? json['reason'] ?? '').toString(),
      reason: (json['reason'] ?? json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'deficiency_type': deficiencyType,
      'type': type,
      'category': category,
      if (documentId != null) 'document_id': documentId,
      if (documentName != null) 'document_name': documentName,
      if (documentType != null) 'document_type': documentType,
      if (verificationId != null) 'verification_id': verificationId,
      'status': status,
      'severity': severity,
      'message': message,
      'reason': reason,
    };
  }
}
