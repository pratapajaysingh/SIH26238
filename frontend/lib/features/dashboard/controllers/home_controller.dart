import 'package:flutter/foundation.dart';
import '../../../models/application.dart';
import '../../../models/application_timeline.dart';
import '../../../models/scholarship.dart';
import '../../../models/student_summary.dart';
import '../../../repositories/application_repository.dart';
import '../../../repositories/notification_repository.dart';
import '../../../repositories/scholarship_repository.dart';
import '../../../repositories/student_repository.dart';

/// HomeController manages state and asynchronous data aggregation for the Student Home Dashboard.
/// Follows the Playbook architecture: Screen -> Controller -> Repository -> ApiClient.
class HomeController extends ChangeNotifier {
  final StudentRepository studentRepository;
  final ScholarshipRepository scholarshipRepository;
  final ApplicationRepository applicationRepository;
  final NotificationRepository notificationRepository;

  bool _isLoading = true;
  String? _errorMessage;

  StudentSummary? _studentSummary;
  Scholarship? _recommendedScholarship;
  Application? _activeApplication;
  List<ApplicationTimelineEvent> _timelineEvents = [];
  int _unreadNotificationsCount = 0;

  HomeController({
    required this.studentRepository,
    required this.scholarshipRepository,
    required this.applicationRepository,
    required this.notificationRepository,
  });

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StudentSummary? get studentSummary => _studentSummary;
  Scholarship? get recommendedScholarship => _recommendedScholarship;
  Application? get activeApplication => _activeApplication;
  List<ApplicationTimelineEvent> get timelineEvents => _timelineEvents;
  int get unreadNotificationsCount => _unreadNotificationsCount;

  /// Loads all required sections for the Home screen concurrently.
  /// Handles partial errors gracefully so failure of one API doesn't crash the entire screen.
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch student summary
      try {
        _studentSummary = await studentRepository.getStudentSummary();
      } catch (e) {
        debugPrint('Failed to load student summary: $e');
      }

      // 2. Fetch recommended scholarship
      try {
        _recommendedScholarship = await scholarshipRepository.getRecommendedScholarship();
      } catch (e) {
        debugPrint('Failed to load recommended scholarship: $e');
      }

      // 3. Fetch active application & timeline
      try {
        _activeApplication = await applicationRepository.getActiveApplication();
        if (_activeApplication != null) {
          _timelineEvents = await applicationRepository.getApplicationTimeline(_activeApplication!.id);
        }
      } catch (e) {
        debugPrint('Failed to load application timeline: $e');
      }

      // 4. Fetch notifications
      try {
        _unreadNotificationsCount = await notificationRepository.getUnreadCount();
      } catch (e) {
        debugPrint('Failed to load unread notifications count: $e');
      }
    } catch (e) {
      _errorMessage = 'Unable to refresh dashboard data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadDashboard();
}
