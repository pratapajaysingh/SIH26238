import '../core/enums/role_enum.dart';

/// AuthUser models the authenticated user in TribalSetu.
class AuthUser {
  final String id;
  final String name;
  final String mobileNumber;
  final UserRole role;
  final String? maskedAadhaar;
  final String? apaarId;
  final bool isAadhaarVerified;
  final bool isPvtg; // Particularly Vulnerable Tribal Group flag
  final String category; // ST, PVTG
  final String state;
  final String district;
  final String? email;

  const AuthUser({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.role,
    this.maskedAadhaar,
    this.apaarId,
    this.isAadhaarVerified = false,
    this.isPvtg = false,
    this.category = 'ST',
    this.state = 'Odisha',
    this.district = 'Mayurbhanj',
    this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? 'Student Beneficiary',
      mobileNumber: json['mobile_number'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'STUDENT'),
      maskedAadhaar: json['masked_aadhaar'] as String?,
      apaarId: json['apaar_id'] as String?,
      isAadhaarVerified: json['is_aadhaar_verified'] as bool? ?? false,
      isPvtg: json['is_pvtg'] as bool? ?? false,
      category: json['category'] as String? ?? 'ST',
      state: json['state'] as String? ?? 'Odisha',
      district: json['district'] as String? ?? 'Mayurbhanj',
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile_number': mobileNumber,
      'role': role.value,
      'masked_aadhaar': maskedAadhaar,
      'apaar_id': apaarId,
      'is_aadhaar_verified': isAadhaarVerified,
      'is_pvtg': isPvtg,
      'category': category,
      'state': state,
      'district': district,
      if (email != null) 'email': email,
    };
  }
}
