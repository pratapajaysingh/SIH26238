import '../models/auth_user.dart';
import '../models/student_summary.dart';

/// StudentRepository defines the contract for fetching student profile and dashboard summary.
/// Conforms to documented endpoints:
/// - GET /api/v1/student/summary
/// - GET /api/v1/student/profile
abstract class StudentRepository {
  /// Fetches the unified dashboard summary for the logged-in student.
  Future<StudentSummary> getStudentSummary({String? studentId});

  /// Fetches the comprehensive student profile.
  Future<AuthUser> getStudentProfile({String? studentId});
}
