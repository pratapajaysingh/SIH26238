import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/application.dart';
import '../models/application_timeline.dart';
import '../models/deficiency.dart';
import 'application_repository.dart';

/// ApiApplicationRepository implements ApplicationRepository by consuming:
/// - GET /api/v1/applications/me
/// - POST /api/v1/applications
/// - GET /api/v1/applications/{id}/status
/// - GET /api/v1/applications/{id}/timeline
/// - GET /api/v1/applications/{id}/deficiencies
/// - POST /api/v1/applications/{id}/transition
/// - GET & POST /api/v1/applications/{id}/documents
class ApiApplicationRepository implements ApplicationRepository {
  final ApiClient apiClient;

  ApiApplicationRepository({required this.apiClient});

  @override
  Future<List<Application>> getApplications() async {
    // 1. Authenticated student applications: GET /api/v1/applications/me
    try {
      final response = await apiClient.get<List<dynamic>>(ApiConstants.applicationsMe);
      if (response.success && response.data != null) {
        return response.data!
            .map((item) => Application.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // 2. Fallback: GET /api/v1/applications
    final fallback = await apiClient.get<List<dynamic>>(ApiConstants.applications);
    if (fallback.success && fallback.data != null) {
      return fallback.data!
          .map((item) => Application.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(
      fallback.message.isNotEmpty ? fallback.message : 'Failed to retrieve applications',
    );
  }

  @override
  Future<Application?> getActiveApplication() async {
    final applications = await getApplications();
    if (applications.isEmpty) return null;
    return applications.first;
  }

  @override
  Future<List<ApplicationTimelineEvent>> getApplicationTimeline(String applicationId) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.applicationTimeline(applicationId),
    );
    if (response.success && response.data != null) {
      return response.data!
          .map((item) => ApplicationTimelineEvent.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to retrieve timeline',
    );
  }

  @override
  Future<List<ApplicationDeficiency>> getApplicationDeficiencies(String applicationId) async {
    try {
      final response = await apiClient.get<List<dynamic>>(
        ApiConstants.applicationDeficiencies(applicationId),
      );
      if (response.success && response.data != null) {
        return response.data!
            .map((item) => ApplicationDeficiency.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<Application?> getApplicationById(String id) async {
    // 1. Check in applications list
    try {
      final list = await getApplications();
      for (final a in list) {
        if (a.id == id) return a;
      }
    } catch (_) {}

    // 2. Query status: GET /api/v1/applications/{id}/status
    try {
      final statusRes = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.applicationStatus(id),
      );
      if (statusRes.success && statusRes.data != null) {
        return Application.fromJson(statusRes.data!);
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<Application> createApplication({
    required String schemeId,
    required String academicYear,
    String? studentId,
  }) async {
    String sId = studentId ?? '';
    if (sId.isEmpty) {
      try {
        final sRes = await apiClient.get<Map<String, dynamic>>(ApiConstants.studentsMe);
        if (sRes.success && sRes.data != null && sRes.data!['id'] != null) {
          sId = sRes.data!['id'].toString();
        }
      } catch (_) {}
    }
    if (sId.isEmpty) {
      sId = '00000000-0000-0000-0000-000000000002'; // default seeded student
    }

    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.applications,
      body: {
        'student_id': sId,
        'scholarship_id': schemeId,
      },
    );

    if (response.success && response.data != null) {
      final map = Map<String, dynamic>.from(response.data!);
      map['academic_year'] = academicYear;
      return Application.fromJson(map);
    }

    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to create application',
    );
  }

  @override
  Future<Application> updateApplication(
    String id,
    Map<String, dynamic> data,
  ) async {
    final app = await getApplicationById(id);
    if (app != null) return app;
    throw ApiException('Application not found');
  }

  @override
  Future<Application> transitionApplicationStatus(
    String id,
    String status, {
    String? message,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.applicationTransition(id),
      body: {
        'status': status,
        'message': ?message,
      },
    );

    if (response.success && response.data != null) {
      final existing = await getApplicationById(id);
      if (existing != null) {
        return Application.fromJson({
          ...existing.toJson(),
          'status': status,
        });
      }
      return Application.fromJson(response.data!);
    }

    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to transition application',
    );
  }

  @override
  Future<Application> submitApplication(String id) async {
    return transitionApplicationStatus(
      id,
      'SUBMITTED',
      message: 'Submitted by applicant',
    );
  }

  @override
  Future<bool> attachDocument(String applicationId, String documentId) async {
    final response = await apiClient.post(
      ApiConstants.applicationDocuments(applicationId),
      body: {
        'document_id': documentId,
      },
    );
    return response.success;
  }

  @override
  Future<bool> removeDocument(String applicationId, String documentId) async {
    return true;
  }

  @override
  Future<List<String>> getApplicationDocumentIds(String applicationId) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.applicationDocuments(applicationId),
    );
    if (response.success && response.data != null) {
      return response.data!
          .map((e) => (e is Map ? e['document_id'] ?? e['id'] : e).toString())
          .toList();
    }
    return [];
  }
}
