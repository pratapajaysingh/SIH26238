/// ManualReviewItem represents an item in the exception review queue
/// from GET /api/v1/manual-reviews.
class ManualReviewItem {
  final String id;
  final String applicationId;
  final String verificationId;
  final String status; // OPEN, RESOLVED, REJECTED
  final String? studentName;
  final String? schemeName;
  final String? documentName;
  final String? reason;
  final String? remarks;

  const ManualReviewItem({
    required this.id,
    required this.applicationId,
    required this.verificationId,
    required this.status,
    this.studentName,
    this.schemeName,
    this.documentName,
    this.reason,
    this.remarks,
  });

  bool get isOpen => status.toUpperCase() == 'OPEN';
  bool get isResolved => status.toUpperCase() == 'RESOLVED' || status.toUpperCase() == 'APPROVED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  factory ManualReviewItem.fromJson(Map<String, dynamic> json) {
    return ManualReviewItem(
      id: (json['id'] ?? '').toString(),
      applicationId: (json['application_id'] ?? '').toString(),
      verificationId: (json['verification_id'] ?? '').toString(),
      status: (json['status'] ?? 'OPEN').toString(),
      studentName: json['student_name'] as String?,
      schemeName: json['scheme_name'] as String?,
      documentName: json['document_name'] as String?,
      reason: json['reason'] as String?,
      remarks: json['remarks'] as String?,
    );
  }

  ManualReviewItem copyWith({
    String? id,
    String? applicationId,
    String? verificationId,
    String? status,
    String? studentName,
    String? schemeName,
    String? documentName,
    String? reason,
    String? remarks,
  }) {
    return ManualReviewItem(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      verificationId: verificationId ?? this.verificationId,
      status: status ?? this.status,
      studentName: studentName ?? this.studentName,
      schemeName: schemeName ?? this.schemeName,
      documentName: documentName ?? this.documentName,
      reason: reason ?? this.reason,
      remarks: remarks ?? this.remarks,
    );
  }
}
