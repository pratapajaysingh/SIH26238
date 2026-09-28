/// StudentSummary models the aggregated summary payload for the student dashboard.
/// Follows documented endpoint GET /api/v1/student/summary.
class StudentSummary {
  final String studentId;
  final String name;
  final String greeting;
  final String motivationalQuote;
  final String? avatarUrl;
  final String category;
  final String state;
  final String district;
  final int unreadNotificationsCount;
  final String? activeApplicationId;
  final String? activeApplicationNumber;
  final String? activeApplicationStage;
  final String? recommendedScholarshipId;

  const StudentSummary({
    required this.studentId,
    required this.name,
    this.greeting = 'Good Morning',
    this.motivationalQuote = 'Keep going! Your dreams matter.',
    this.avatarUrl,
    this.category = 'ST',
    this.state = 'Odisha',
    this.district = 'Mayurbhanj',
    this.unreadNotificationsCount = 1,
    this.activeApplicationId,
    this.activeApplicationNumber,
    this.activeApplicationStage,
    this.recommendedScholarshipId,
  });

  /// Dynamically computes the student's uppercase initials (e.g. Aarav Singh -> AS)
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0].substring(0, 1).toUpperCase() : 'ST';
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  factory StudentSummary.fromJson(Map<String, dynamic> json) {
    return StudentSummary(
      studentId: json['student_id'] as String? ?? 'TS2024S10023',
      name: json['name'] as String? ?? 'Aarav Singh',
      greeting: json['greeting'] as String? ?? 'Good Morning',
      motivationalQuote: json['motivational_quote'] as String? ??
          'Keep going! Your dreams matter.',
      avatarUrl: json['avatar_url'] as String?,
      category: json['category'] as String? ?? 'ST',
      state: json['state'] as String? ?? 'Odisha',
      district: json['district'] as String? ?? 'Mayurbhanj',
      unreadNotificationsCount:
          json['unread_notifications_count'] as int? ?? 1,
      activeApplicationId: json['active_application_id'] as String?,
      activeApplicationNumber: json['active_application_number'] as String?,
      activeApplicationStage: json['active_application_stage'] as String?,
      recommendedScholarshipId: json['recommended_scholarship_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'greeting': greeting,
      'motivational_quote': motivationalQuote,
      'avatar_url': avatarUrl,
      'category': category,
      'state': state,
      'district': district,
      'unread_notifications_count': unreadNotificationsCount,
      'active_application_id': activeApplicationId,
      'active_application_number': activeApplicationNumber,
      'active_application_stage': activeApplicationStage,
      'recommended_scholarship_id': recommendedScholarshipId,
    };
  }
}
