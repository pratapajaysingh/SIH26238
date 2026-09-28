import '../core/enums/role_enum.dart';
import '../models/auth_user.dart';
import '../models/student_summary.dart';
import 'student_repository.dart';

/// MockStudentRepository provides deterministic mock data matching the reference design.
/// Conforms to documented response formats for:
/// - GET /api/v1/student/summary
/// - GET /api/v1/student/profile
class MockStudentRepository implements StudentRepository {
  final Duration latency;

  MockStudentRepository({this.latency = const Duration(milliseconds: 300)});

  @override
  Future<StudentSummary> getStudentSummary({String? studentId}) async {
    await Future.delayed(latency);
    return const StudentSummary(
      studentId: 'TS2024S10023',
      name: 'Aarav Singh',
      greeting: 'Good Morning',
      motivationalQuote: 'Keep going! Your dreams matter.',
      category: 'ST',
      state: 'Odisha',
      district: 'Mayurbhanj',
      unreadNotificationsCount: 1,
      activeApplicationId: 'app-2024-st-01',
      activeApplicationNumber: 'TS2024S10023',
      activeApplicationStage: 'Under Review',
      recommendedScholarshipId: 'scheme-pms-st-01',
    );
  }

  @override
  Future<AuthUser> getStudentProfile({String? studentId}) async {
    await Future.delayed(latency);
    return const AuthUser(
      id: 'TS2024S10023',
      name: 'Aarav Singh',
      mobileNumber: '+91 9876543210',
      role: UserRole.student,
      maskedAadhaar: 'XXXX-XXXX-4819',
      apaarId: 'APAAR-2024-901824',
      isAadhaarVerified: true,
      category: 'ST',
      state: 'Odisha',
      district: 'Mayurbhanj',
    );
  }
}
