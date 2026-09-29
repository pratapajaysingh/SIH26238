/// Scholarship represents a government scholarship scheme under MoTA.
/// Conforms to Playbook (Section 10 & 11) and Architecture documentation.
class Scholarship {
  final String id;
  final String code;
  final String name;
  final String description;
  final String ministry;
  final bool eligible;
  final String benefitAmount;
  final String educationLevel;
  final bool isPvtgSpecific;
  final String sourcePortal; // NSP, SFMP, NOS
  final String targetAudience;
  final String statusBadge;
  final bool isMostRelevant;
  final String deadline;
  final String source;
  final String lastUpdated;

  const Scholarship({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.ministry = 'Ministry of Tribal Affairs',
    required this.eligible,
    required this.benefitAmount,
    required this.educationLevel,
    this.deadline = '',
    this.isPvtgSpecific = false,
    required this.sourcePortal,
    this.targetAudience = 'ST Students',
    this.statusBadge = 'Ongoing',
    this.isMostRelevant = false,
    this.source = 'Ministry of Tribal Affairs',
    this.lastUpdated = '2026-04-01',
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    return Scholarship(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ministry: json['ministry'] as String? ?? 'Ministry of Tribal Affairs',
      eligible: json['eligible'] as bool? ?? false,
      benefitAmount: json['benefit_amount'] as String? ?? '',
      educationLevel: json['education_level'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      isPvtgSpecific: json['is_pvtg_specific'] as bool? ?? false,
      sourcePortal: json['source_portal'] as String? ?? 'NSP',
      targetAudience: json['target_audience'] as String? ?? 'ST Students',
      statusBadge: json['status_badge'] as String? ?? 'Ongoing',
      isMostRelevant: json['is_most_relevant'] as bool? ?? false,
      source: json['source'] as String? ?? 'Ministry of Tribal Affairs',
      lastUpdated: json['last_updated'] as String? ?? '2026-04-01',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'ministry': ministry,
      'eligible': eligible,
      'benefit_amount': benefitAmount,
      'education_level': educationLevel,
      'deadline': deadline,
      'is_pvtg_specific': isPvtgSpecific,
      'source_portal': sourcePortal,
      'target_audience': targetAudience,
      'status_badge': statusBadge,
      'is_most_relevant': isMostRelevant,
      'source': source,
      'last_updated': lastUpdated,
    };
  }
}
