import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/student_profile.dart';
import 'profile_repository.dart';

/// ApiProfileRepository implements ProfileRepository by delegating to ApiClient.
/// Consumes:
/// - GET /api/v1/students/me
/// - Fallback: GET /api/v1/users/me
class ApiProfileRepository implements ProfileRepository {
  final ApiClient apiClient;

  ApiProfileRepository({required this.apiClient});

  @override
  Future<StudentProfile> getProfile() async {
    // 1. Try GET /api/v1/students/me
    try {
      final response = await apiClient.get<Map<String, dynamic>>(ApiConstants.studentsMe);
      if (response.success && response.data != null) {
        return StudentProfile.fromJson(response.data!);
      }
    } catch (_) {}

    // 2. Fallback: GET /api/v1/users/me
    try {
      final userRes = await apiClient.get<Map<String, dynamic>>(ApiConstants.usersMe);
      if (userRes.success && userRes.data != null) {
        return StudentProfile.fromJson(userRes.data!);
      }
    } catch (_) {}

    throw ApiException('Failed to retrieve student profile');
  }
}
