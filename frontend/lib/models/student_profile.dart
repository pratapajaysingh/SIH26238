/// StudentProfile represents the comprehensive student profile entity
/// conforming to the documented schema (Section 7) and GET /api/v1/student/profile.
class StudentProfile {
  final String id;
  final String? userId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String category;
  final bool isPvtg;
  final String? mobile;
  final String? email;
  final String? address;
  final String? state;
  final String? district;
  final String? pincode;
  final String? institutionId;
  final String? institutionName;
  final String? course;
  final String? academicYear;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudentProfile({
    required this.id,
    this.userId,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    required this.category,
    this.isPvtg = false,
    this.mobile,
    this.email,
    this.address,
    this.state,
    this.district,
    this.pincode,
    this.institutionId,
    this.institutionName,
    this.course,
    this.academicYear,
    this.isVerified = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Formatted date of birth: "14 Mar 2006"
  String get dateOfBirthFormatted {
    if (dateOfBirth == null) return '-';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = dateOfBirth!.day.toString().padLeft(2, '0');
    final month = months[dateOfBirth!.month - 1];
    return '$day $month ${dateOfBirth!.year}';
  }

  /// Presentation category label: "Scheduled Tribe (ST)"
  String get categoryDisplay {
    final cat = category.toUpperCase();
    if (cat == 'ST') return 'Scheduled Tribe (ST)';
    if (cat == 'PVTG') return 'Particularly Vulnerable Tribal Group (PVTG)';
    return category;
  }

  /// Presentation hero sub-label: "ST Student"
  String get studentTypeDisplay {
    return '$category Student';
  }

  /// Multi-line formatted address composed strictly from documented address fields
  String get formattedAddress {
    final line1 = address ?? '';
    final line2Parts = <String>[];
    if (district != null && district!.isNotEmpty) {
      line2Parts.add('District - $district');
    }
    final statePin = <String>[];
    if (state != null && state!.isNotEmpty) statePin.add(state!);
    if (pincode != null && pincode!.isNotEmpty) statePin.add(pincode!);
    if (statePin.isNotEmpty) {
      line2Parts.add(statePin.join(' - '));
    }

    if (line1.isNotEmpty && line2Parts.isNotEmpty) {
      return '$line1\n${line2Parts.join(', ')}';
    } else if (line1.isNotEmpty) {
      return line1;
    }
    return line2Parts.join(', ');
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String? ?? json['student_id'] as String? ?? 'TS2024S10023',
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? 'Student Beneficiary',
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth'] as String) : null,
      gender: json['gender'] as String?,
      category: json['category'] as String? ?? 'ST',
      isPvtg: json['is_pvtg'] as bool? ?? false,
      mobile: json['mobile'] as String? ?? json['mobile_number'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      state: json['state'] as String?,
      district: json['district'] as String?,
      pincode: json['pincode'] as String?,
      institutionId: json['institution_id'] as String?,
      institutionName: json['institution_name'] as String?,
      course: json['course'] as String?,
      academicYear: json['academic_year'] as String?,
      isVerified: json['is_verified'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'category': category,
      'is_pvtg': isPvtg,
      'mobile': mobile,
      'email': email,
      'address': address,
      'state': state,
      'district': district,
      'pincode': pincode,
      'institution_id': institutionId,
      if (institutionName != null) 'institution_name': institutionName,
      'course': course,
      'academic_year': academicYear,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
