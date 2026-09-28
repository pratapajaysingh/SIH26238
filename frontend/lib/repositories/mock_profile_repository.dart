import '../models/student_profile.dart';
import 'profile_repository.dart';

/// MockProfileRepository provides deterministic mock profile data matching the reference image.
/// Conforms strictly to GET /api/v1/student/profile schema.
class MockProfileRepository implements ProfileRepository {
  final Duration latency;

  MockProfileRepository({this.latency = const Duration(milliseconds: 300)});

  static final StudentProfile _profile = StudentProfile(
    id: 'TS2024S10023',
    userId: 'usr-st-aarav-01',
    fullName: 'Aarav Singh',
    dateOfBirth: DateTime(2006, 3, 14),
    gender: 'Male',
    category: 'ST',
    isPvtg: false,
    mobile: '+91 98765 43210',
    email: 'aaravsingh@example.com',
    address: 'Village - Karanpur, Block - Bishrampur',
    district: 'Surguja',
    state: 'Chhattisgarh',
    pincode: '497226',
    institutionId: 'INST-CG-042',
    institutionName: 'Government College, Ambikapur',
    course: 'B.Sc. (1st Year)',
    academicYear: '2024 - 2025',
    isVerified: true,
  );

  @override
  Future<StudentProfile> getProfile() async {
    await Future.delayed(latency);
    return _profile;
  }
}
