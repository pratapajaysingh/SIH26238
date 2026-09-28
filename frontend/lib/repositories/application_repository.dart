import '../models/application.dart';
import '../models/application_timeline.dart';

/// ApplicationRepository defines the contract for fetching applications and timeline events.
/// Conforms to documented endpoints:
/// - GET /api/v1/applications
/// - GET /api/v1/applications/{id}/timeline
abstract class ApplicationRepository {
  /// Fetches all applications for the student.
  Future<List<Application>> getApplications();

  /// Fetches the most relevant active application for dashboard display.
  Future<Application?> getActiveApplication();

  /// Fetches the timeline progression stages for an application.
  Future<List<ApplicationTimelineEvent>> getApplicationTimeline(String applicationId);

  /// Fetches a specific application by its ID.
  /// Consumes GET /api/v1/applications/{id}
  Future<Application?> getApplicationById(String id);

  /// Creates a new scholarship application draft.
  /// Consumes POST /api/v1/applications
  Future<Application> createApplication({
    required String schemeId,
    required String academicYear,
  });

  /// Updates an existing draft application.
  /// Consumes PUT /api/v1/applications/{id}
  Future<Application> updateApplication(
    String id,
    Map<String, dynamic> data,
  );

  /// Submits an application for institutional and state verification.
  /// Consumes POST /api/v1/applications/{id}/submit
  Future<Application> submitApplication(String id);

  /// Attaches an existing reusable document from the wallet to an application.
  /// Consumes POST /api/v1/applications/{id}/documents
  Future<bool> attachDocument(String applicationId, String documentId);

  /// Removes an attached document relationship from a draft application.
  /// Consumes DELETE /api/v1/applications/{id}/documents/{documentId}
  Future<bool> removeDocument(String applicationId, String documentId);

  /// Fetches the list of document IDs attached to the specified application.
  /// Consumes GET /api/v1/applications/{id}/documents
  Future<List<String>> getApplicationDocumentIds(String applicationId);
}
