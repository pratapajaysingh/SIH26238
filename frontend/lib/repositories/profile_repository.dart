import '../models/student_profile.dart';

/// ProfileRepository defines the contract for fetching student profile.
/// Conforms to documented endpoint:
/// - GET /api/v1/student/profile
abstract class ProfileRepository {
  /// Fetches the authenticated student's profile.
  Future<StudentProfile> getProfile();
}
