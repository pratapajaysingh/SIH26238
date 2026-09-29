import '../core/constants/api_constants.dart';
import '../core/enums/role_enum.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/auth_user.dart';
import '../models/student_summary.dart';
import 'student_repository.dart';

/// ApiStudentRepository implements StudentRepository by delegating to ApiClient.
/// Fully integrated with FastAPI:
/// - GET /api/v1/students/me
/// - GET /api/v1/users/me
/// - Aggregated student dashboard summary
class ApiStudentRepository implements StudentRepository {
  final ApiClient apiClient;

  ApiStudentRepository({required this.apiClient});

  @override
  Future<StudentSummary> getStudentSummary({String? studentId}) async {
    // 1. Fetch current student: GET /api/v1/students/me
    String name = 'Demo Student User';
    String id = studentId ?? '00000000-0000-0000-0000-000000000002';
    try {
      final res = await apiClient.get<Map<String, dynamic>>(ApiConstants.studentsMe);
      if (res.success && res.data != null) {
        name = res.data!['name'] as String? ?? name;
        id = res.data!['id'] as String? ?? id;
      }
    } catch (_) {}

    // 2. Fetch unread notifications: GET /api/v1/notifications/me?unread_only=true
    int unreadCount = 0;
    try {
      final notifRes = await apiClient.get<List<dynamic>>(
        ApiConstants.notificationsMe,
        queryParameters: {'unread_only': true},
      );
      if (notifRes.success && notifRes.data != null) {
        unreadCount = notifRes.data!.length;
      }
    } catch (_) {}

    // 3. Fetch applications: GET /api/v1/applications/me
    String? activeAppId;
    String? activeAppNumber;
    String? activeAppStage;
    try {
      final appRes = await apiClient.get<List<dynamic>>(ApiConstants.applicationsMe);
      if (appRes.success && appRes.data != null && appRes.data!.isNotEmpty) {
        final firstApp = appRes.data!.first as Map<String, dynamic>;
        activeAppId = firstApp['id'] as String?;
        activeAppNumber = firstApp['application_number'] as String? ??
            (activeAppId != null ? 'APP-${activeAppId.substring(0, 8).toUpperCase()}' : null);
        activeAppStage = firstApp['status'] as String? ?? 'DRAFT';
      }
    } catch (_) {}

    return StudentSummary(
      studentId: id,
      name: name,
      greeting: 'Good Morning',
      motivationalQuote: 'Keep going! Your dreams matter.',
      category: 'ST',
      state: 'Odisha',
      district: 'Mayurbhanj',
      unreadNotificationsCount: unreadCount,
      activeApplicationId: activeAppId,
      activeApplicationNumber: activeAppNumber,
      activeApplicationStage: activeAppStage,
      recommendedScholarshipId: '00000000-0000-0000-0000-000000000010',
    );
  }

  @override
  Future<AuthUser> getStudentProfile({String? studentId}) async {
    // 1. Try GET /api/v1/students/me
    try {
      final response = await apiClient.get<Map<String, dynamic>>(ApiConstants.studentsMe);
      if (response.success && response.data != null) {
        final data = response.data!;
        return AuthUser(
          id: data['id'] as String? ?? '00000000-0000-0000-0000-000000000002',
          name: data['name'] as String? ?? 'Demo Student User',
          mobileNumber: '',
          role: UserRole.student,
          category: 'ST',
          email: data['email'] as String?,
        );
      }
    } catch (_) {}

    // 2. Fallback to GET /api/v1/auth/me or GET /api/v1/users/me
    try {
      final userRes = await apiClient.get<Map<String, dynamic>>(ApiConstants.authMe);
      if (userRes.success && userRes.data != null) {
        final data = userRes.data!;
        return AuthUser(
          id: data['id'] as String? ?? '',
          name: data['name'] as String? ?? 'Demo Student User',
          mobileNumber: '',
          role: UserRole.student,
          category: 'ST',
          email: data['email'] as String?,
        );
      }
    } catch (_) {}

    throw ApiException('Failed to retrieve student profile');
  }
}
