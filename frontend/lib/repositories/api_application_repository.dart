import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/application.dart';
import '../models/application_timeline.dart';
import 'application_repository.dart';

/// ApiApplicationRepository implements ApplicationRepository by consuming:
/// - GET /api/v1/applications
/// - GET /api/v1/applications/{id}/timeline
class ApiApplicationRepository implements ApplicationRepository {
  final ApiClient apiClient;

  ApiApplicationRepository({required this.apiClient});

  @override
  Future<List<Application>> getApplications() async {
    final response = await apiClient.get(ApiConstants.applications);
    if (response.success && response.data != null) {
      final list = response.data as List<dynamic>;
      return list
          .map((item) => Application.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<Application?> getActiveApplication() async {
    final applications = await getApplications();
    if (applications.isEmpty) return null;
    return applications.first;
  }

  @override
  Future<List<ApplicationTimelineEvent>> getApplicationTimeline(String applicationId) async {
    final response = await apiClient.get('${ApiConstants.applications}/$applicationId/timeline');
    if (response.success && response.data != null) {
      final list = response.data as List<dynamic>;
      return list
          .map((item) => ApplicationTimelineEvent.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<Application?> getApplicationById(String id) async {
    final response = await apiClient.get<Application>(
      '${ApiConstants.applications}/$id',
      fromJson: (json) => Application.fromJson(json as Map<String, dynamic>),
    );
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }

  @override
  Future<Application> createApplication({
    required String schemeId,
    required String academicYear,
  }) async {
    final response = await apiClient.post(
      ApiConstants.applications,
      body: {
        'scheme_id': schemeId,
        'academic_year': academicYear,
      },
    );
    if (response.success && response.data != null) {
      final map = response.data as Map<String, dynamic>;
      // If server returned partial { application_id, application_number, status }
      if (!map.containsKey('scheme_name')) {
        map['id'] = map['application_id'] ?? map['id'];
        map['scheme_id'] = schemeId;
        map['scheme_code'] = 'POST_MATRIC';
        map['scheme_name'] = 'Scholarship Application';
        map['student_id'] = 'student';
        map['submitted_at'] = DateTime.now().toIso8601String();
        map['current_stage'] = 'Draft';
        map['academic_year'] = academicYear;
      }
      return Application.fromJson(map);
    }
    throw Exception(response.message);
  }

  @override
  Future<Application> updateApplication(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      '${ApiConstants.applications}/$id',
      body: data,
    );
    if (response.success && response.data != null) {
      return Application.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception(response.message);
  }

  @override
  Future<Application> submitApplication(String id) async {
    final response = await apiClient.post(
      ApiConstants.applicationSubmit(id),
    );
    if (response.success && response.data != null) {
      return Application.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception(response.message);
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
    final response = await apiClient.delete(
      ApiConstants.applicationDocument(applicationId, documentId),
    );
    return response.success;
  }

  @override
  Future<List<String>> getApplicationDocumentIds(String applicationId) async {
    final response = await apiClient.get(
      ApiConstants.applicationDocuments(applicationId),
    );
    if (response.success && response.data != null) {
      final list = response.data as List<dynamic>;
      return list.map((e) => (e is Map ? e['document_id'] ?? e['id'] : e).toString()).toList();
    }
    return [];
  }
}
