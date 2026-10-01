/// ConflictCheckResult represents the response from
/// POST /api/v1/eligibility/conflict-check.
class ConflictCheckResult {
  final String studentId;
  final String scholarshipId;
  final bool eligible;
  final String status;
  final List<String> reasons;
  final String? existingApplicationId;
  final String? existingSchemeCode;
  final String evaluationMode;

  const ConflictCheckResult({
    required this.studentId,
    required this.scholarshipId,
    required this.eligible,
    required this.status,
    required this.reasons,
    this.existingApplicationId,
    this.existingSchemeCode,
    this.evaluationMode = 'MOCK',
  });

  bool get hasConflict => !eligible || status != 'ELIGIBLE';

  factory ConflictCheckResult.fromJson(Map<String, dynamic> json) {
    return ConflictCheckResult(
      studentId: (json['student_id'] ?? '').toString(),
      scholarshipId: (json['scholarship_id'] ?? '').toString(),
      eligible: json['eligible'] as bool? ?? false,
      status: (json['status'] ?? (json['eligible'] == true ? 'ELIGIBLE' : 'ACTIVE_APPLICATION_EXISTS')).toString(),
      reasons: (json['reasons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      existingApplicationId: json['existing_application_id'] as String?,
      existingSchemeCode: json['existing_scheme_code'] as String?,
      evaluationMode: (json['evaluation_mode'] ?? 'MOCK').toString(),
    );
  }
}
