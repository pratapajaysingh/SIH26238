import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/auth_user.dart';
import '../models/student_summary.dart';
import 'student_repository.dart';

/// ApiStudentRepository implements StudentRepository by delegating to ApiClient.
/// Consumes:
/// - GET /api/v1/student/summary
/// - GET /api/v1/student/profile
class ApiStudentRepository implements StudentRepository {
  final ApiClient apiClient;

  ApiStudentRepository({required this.apiClient});

  @override
  Future<StudentSummary> getStudentSummary({String? studentId}) async {
    final endpoint = studentId != null
        ? '${ApiConstants.studentSummary}?student_id=$studentId'
        : ApiConstants.studentSummary;

    final response = await apiClient.get(endpoint);
    if (response.success && response.data != null) {
      return StudentSummary.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception(response.message);
  }

  @override
  Future<AuthUser> getStudentProfile({String? studentId}) async {
    final endpoint = studentId != null
        ? '${ApiConstants.studentProfile}?student_id=$studentId'
        : ApiConstants.studentProfile;

    final response = await apiClient.get(endpoint);
    if (response.success && response.data != null) {
      return AuthUser.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception(response.message);
  }
}
