/// EligibilityCheckResult represents the response contract for
/// POST /api/v1/eligibility/check.
class EligibilityCheckResult {
  final String scheme;
  final String? scholarshipId;
  final String? studentId;
  final bool eligible;
  final List<String> missingItems;
  final List<String> reasons;
  final String evaluationMode;
  final String rulesVersion;

  const EligibilityCheckResult({
    required this.scheme,
    this.scholarshipId,
    this.studentId,
    required this.eligible,
    this.missingItems = const [],
    this.reasons = const [],
    this.evaluationMode = 'MOCK',
    this.rulesVersion = '2026.1',
  });

  bool get isMock => evaluationMode.toUpperCase() == 'MOCK';

  factory EligibilityCheckResult.fromJson(Map<String, dynamic> json) {
    final rawReasons = (json['reasons'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['missing_items'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    return EligibilityCheckResult(
      scheme: (json['scheme'] ?? json['scholarship_id'] ?? '').toString(),
      scholarshipId: json['scholarship_id'] as String?,
      studentId: json['student_id'] as String?,
      eligible: json['eligible'] as bool? ?? false,
      missingItems: rawReasons,
      reasons: rawReasons,
      evaluationMode: json['evaluation_mode'] as String? ?? 'MOCK',
      rulesVersion: json['rules_version'] as String? ?? '2026.1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheme': scheme,
      if (scholarshipId != null) 'scholarship_id': scholarshipId,
      if (studentId != null) 'student_id': studentId,
      'eligible': eligible,
      'missing_items': missingItems,
      'reasons': reasons,
      'evaluation_mode': evaluationMode,
      'rules_version': rulesVersion,
    };
  }
}
