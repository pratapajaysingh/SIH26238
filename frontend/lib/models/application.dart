import '../core/enums/application_status.dart';
import 'application_timeline.dart';

/// Application represents a student's scholarship application.
/// Conforms to Playbook (Section 16).
class Application {
  final String id;
  final String applicationNumber;
  final String schemeId;
  final String schemeCode;
  final String schemeName;
  final String studentId;
  final ApplicationStatus status;
  final DateTime submittedAt;
  final String currentStage;
  final double? amountSanctioned;
  final String? remarks;
  final String? sourcePortal;
  final String? ministryName;
  final String? academicYear;
  final String? sourceSystem;
  final String? externalAppId;
  final DateTime? lastUpdatedAt;
  final List<ApplicationTimelineEvent>? timeline;

  const Application({
    required this.id,
    required this.applicationNumber,
    required this.schemeId,
    required this.schemeCode,
    required this.schemeName,
    required this.studentId,
    required this.status,
    required this.submittedAt,
    required this.currentStage,
    this.amountSanctioned,
    this.remarks,
    this.sourcePortal,
    this.ministryName,
    this.academicYear,
    this.sourceSystem,
    this.externalAppId,
    this.lastUpdatedAt,
    this.timeline,
  });

  String get displayStatus {
    switch (status) {
      case ApplicationStatus.inVerification:
        return 'Under Review';
      case ApplicationStatus.submitted:
      case ApplicationStatus.draft:
        return 'In Progress';
      case ApplicationStatus.deficiency:
        return 'Documents Required';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.completed:
      case ApplicationStatus.sanctioned:
        return 'Completed';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? json['application_id'] ?? '').toString();
    final rawAppNum = json['application_number'] ??
        json['applicationNumber'] ??
        (rawId.isNotEmpty ? 'APP-${rawId.length >= 8 ? rawId.substring(0, 8).toUpperCase() : rawId.toUpperCase()}' : 'APP-UNKNOWN');
    final rawSchemeId = (json['scholarship_id'] ?? json['scheme_id'] ?? json['scholarshipId'] ?? '').toString();
    final rawSchemeCode = (json['scholarship_code'] ?? json['scheme_code'] ?? 'SCHEME').toString();
    final rawSchemeName = (json['scholarship_name'] ?? json['scheme_name'] ?? 'Scholarship Application').toString();
    final rawStudentId = (json['student_id'] ?? '').toString();
    final rawStatus = (json['status'] ?? 'DRAFT').toString();

    DateTime parsedSubmittedAt;
    if (json['submitted_at'] != null) {
      parsedSubmittedAt = DateTime.tryParse(json['submitted_at'].toString()) ?? DateTime.now();
    } else if (json['created_at'] != null) {
      parsedSubmittedAt = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    } else {
      parsedSubmittedAt = DateTime.now();
    }

    return Application(
      id: rawId,
      applicationNumber: rawAppNum.toString(),
      schemeId: rawSchemeId,
      schemeCode: rawSchemeCode,
      schemeName: rawSchemeName,
      studentId: rawStudentId,
      status: ApplicationStatus.fromString(rawStatus),
      submittedAt: parsedSubmittedAt,
      currentStage: json['current_stage'] as String? ?? (json['status'] as String? ?? 'In Progress'),
      amountSanctioned: (json['amount_sanctioned'] as num?)?.toDouble(),
      remarks: json['remarks'] as String?,
      sourcePortal: json['source_portal'] as String? ?? 'NSP',
      ministryName: json['ministry_name'] as String?,
      academicYear: json['academic_year'] as String?,
      sourceSystem: (json['source_system'] ?? json['source_portal']) as String?,
      externalAppId: json['external_app_id'] as String?,
      lastUpdatedAt: json['last_updated_at'] != null ? DateTime.tryParse(json['last_updated_at'] as String) : null,
      timeline: json['timeline'] != null
          ? (json['timeline'] as List<dynamic>)
              .map((item) => ApplicationTimelineEvent.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_number': applicationNumber,
      'scheme_id': schemeId,
      'scheme_code': schemeCode,
      'scheme_name': schemeName,
      'student_id': studentId,
      'status': status.value,
      'submitted_at': submittedAt.toIso8601String(),
      'current_stage': currentStage,
      'amount_sanctioned': amountSanctioned,
      'remarks': remarks,
      'source_portal': sourcePortal,
      if (ministryName != null) 'ministry_name': ministryName,
      if (academicYear != null) 'academic_year': academicYear,
      if (sourceSystem != null) 'source_system': sourceSystem,
      if (externalAppId != null) 'external_app_id': externalAppId,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt!.toIso8601String(),
      if (timeline != null) 'timeline': timeline!.map((e) => e.toJson()).toList(),
    };
  }
}
