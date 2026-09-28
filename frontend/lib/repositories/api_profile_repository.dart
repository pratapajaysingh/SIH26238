import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/student_profile.dart';
import 'profile_repository.dart';

/// ApiProfileRepository implements ProfileRepository by delegating to ApiClient.
/// Consumes:
/// - GET /api/v1/student/profile
class ApiProfileRepository implements ProfileRepository {
  final ApiClient apiClient;

  ApiProfileRepository({required this.apiClient});

  @override
  Future<StudentProfile> getProfile() async {
    final response = await apiClient.get(ApiConstants.studentProfile);
    if (response.success && response.data != null) {
      return StudentProfile.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception(response.message);
  }
}
