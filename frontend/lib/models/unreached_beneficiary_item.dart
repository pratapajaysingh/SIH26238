/// UnreachedBeneficiaryItem represents an enrolled ST student from
/// GET /api/v1/analytics/unreached-beneficiaries (+ /all).
class UnreachedBeneficiaryItem {
  final String demoId;
  final String institutionCode;
  final String institutionName;
  final String educationLevel;
  final String enrollmentSource;
  final String state;
  final String matchedStatus; // UNREACHED or MATCHED
  final String scholarshipBenefitStatus;
  final String? scholarshipCode;
  final String? possibleReason;
  final String? nextAction;
  final bool outreachSent;

  const UnreachedBeneficiaryItem({
    required this.demoId,
    required this.institutionCode,
    required this.institutionName,
    required this.educationLevel,
    required this.enrollmentSource,
    required this.state,
    required this.matchedStatus,
    required this.scholarshipBenefitStatus,
    this.scholarshipCode,
    this.possibleReason,
    this.nextAction,
    this.outreachSent = false,
  });

  bool get isUnreached => matchedStatus == 'UNREACHED';

  factory UnreachedBeneficiaryItem.fromJson(Map<String, dynamic> json) {
    return UnreachedBeneficiaryItem(
      demoId: (json['demo_id'] ?? '').toString(),
      institutionCode: (json['institution_code'] ?? '').toString(),
      institutionName: (json['institution_name'] ?? 'Government Institution').toString(),
      educationLevel: (json['education_level'] ?? '').toString(),
      enrollmentSource: (json['enrollment_source'] ?? 'UDISE+').toString(),
      state: (json['state'] ?? 'India').toString(),
      matchedStatus: (json['matched_status'] ?? 'UNREACHED').toString(),
      scholarshipBenefitStatus: (json['scholarship_benefit_status'] ?? 'NONE').toString(),
      scholarshipCode: json['scholarship_code'] as String?,
      possibleReason: json['possible_reason'] as String?,
      nextAction: json['next_action'] as String?,
      outreachSent: false,
    );
  }

  UnreachedBeneficiaryItem copyWith({
    String? demoId,
    String? institutionCode,
    String? institutionName,
    String? educationLevel,
    String? enrollmentSource,
    String? state,
    String? matchedStatus,
    String? scholarshipBenefitStatus,
    String? scholarshipCode,
    String? possibleReason,
    String? nextAction,
    bool? outreachSent,
  }) {
    return UnreachedBeneficiaryItem(
      demoId: demoId ?? this.demoId,
      institutionCode: institutionCode ?? this.institutionCode,
      institutionName: institutionName ?? this.institutionName,
      educationLevel: educationLevel ?? this.educationLevel,
      enrollmentSource: enrollmentSource ?? this.enrollmentSource,
      state: state ?? this.state,
      matchedStatus: matchedStatus ?? this.matchedStatus,
      scholarshipBenefitStatus: scholarshipBenefitStatus ?? this.scholarshipBenefitStatus,
      scholarshipCode: scholarshipCode ?? this.scholarshipCode,
      possibleReason: possibleReason ?? this.possibleReason,
      nextAction: nextAction ?? this.nextAction,
      outreachSent: outreachSent ?? this.outreachSent,
    );
  }
}
