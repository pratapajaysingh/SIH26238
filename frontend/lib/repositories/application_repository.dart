import '../models/application.dart';
import '../models/application_timeline.dart';
import '../models/deficiency.dart';

/// ApplicationRepository defines the contract for fetching applications, timeline events, and deficiencies.
/// Conforms to documented endpoints:
/// - GET /api/v1/applications/me
/// - POST /api/v1/applications
/// - GET /api/v1/applications/{id}/status
/// - GET /api/v1/applications/{id}/timeline
/// - GET /api/v1/applications/{id}/deficiencies
/// - POST /api/v1/applications/{id}/transition
abstract class ApplicationRepository {
  /// Fetches all applications for the authenticated student.
  Future<List<Application>> getApplications();

  /// Fetches the most relevant active application for dashboard display.
  Future<Application?> getActiveApplication();

  /// Fetches the timeline progression stages for an application.
  Future<List<ApplicationTimelineEvent>> getApplicationTimeline(String applicationId);

  /// Fetches flagged document mismatches or deficiencies for an application.
  Future<List<ApplicationDeficiency>> getApplicationDeficiencies(String applicationId);

  /// Fetches a specific application by its ID.
  Future<Application?> getApplicationById(String id);

  /// Creates a new scholarship application draft.
  Future<Application> createApplication({
    required String schemeId,
    required String academicYear,
    String? studentId,
  });

  /// Updates an existing draft application.
  Future<Application> updateApplication(
    String id,
    Map<String, dynamic> data,
  );

  /// Executes a status transition on an application (e.g. DRAFT -> SUBMITTED).
  Future<Application> transitionApplicationStatus(
    String id,
    String status, {
    String? message,
  });

  /// Submits an application for institutional and state verification.
  Future<Application> submitApplication(String id);

  /// Attaches an existing reusable document from the wallet to an application.
  Future<bool> attachDocument(String applicationId, String documentId);

  /// Removes an attached document relationship from a draft application.
  Future<bool> removeDocument(String applicationId, String documentId);

  /// Fetches the list of document IDs attached to the specified application.
  Future<List<String>> getApplicationDocumentIds(String applicationId);
}
