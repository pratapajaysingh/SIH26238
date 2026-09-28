/// EligibilityCheckResult represents the documented response contract for
/// POST /api/v1/eligibility/check conforming to the Team Development & Integration Playbook (Section 7 & 11).
class EligibilityCheckResult {
  final String scheme;
  final bool eligible;
  final List<String> missingItems;
  final String rulesVersion;

  const EligibilityCheckResult({
    required this.scheme,
    required this.eligible,
    this.missingItems = const [],
    this.rulesVersion = '2026.1',
  });

  factory EligibilityCheckResult.fromJson(Map<String, dynamic> json) {
    return EligibilityCheckResult(
      scheme: json['scheme'] as String? ?? '',
      eligible: json['eligible'] as bool? ?? false,
      missingItems: (json['missing_items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      rulesVersion: json['rules_version'] as String? ?? '2026.1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheme': scheme,
      'eligible': eligible,
      'missing_items': missingItems,
      'rules_version': rulesVersion,
    };
  }
}
