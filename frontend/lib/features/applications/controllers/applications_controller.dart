import 'package:flutter/foundation.dart';
import '../../../core/enums/application_status.dart';
import '../../../models/application.dart';
import '../../../repositories/application_repository.dart';

/// ApplicationsFilter defines the selectable filter tabs matching the visual reference.
enum ApplicationsFilter {
  all('All'),
  inProgress('In Progress'),
  underReview('Under Review'),
  completed('Completed');

  final String label;
  const ApplicationsFilter(this.label);
}

/// ApplicationsController manages state and business logic for the "My Applications" screen.
/// Follows Clean Architecture: UI -> Controller -> Repository.
class ApplicationsController extends ChangeNotifier {
  final ApplicationRepository _applicationRepository;

  ApplicationsController({required ApplicationRepository applicationRepository})
      : _applicationRepository = applicationRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ApplicationsFilter _selectedFilter = ApplicationsFilter.all;
  ApplicationsFilter get selectedFilter => _selectedFilter;

  List<Application> _applications = [];
  List<Application> get allApplications => List.unmodifiable(_applications);

  List<Application> get filteredApplications {
    switch (_selectedFilter) {
      case ApplicationsFilter.all:
        return _applications;

      case ApplicationsFilter.inProgress:
        return _applications.where((app) {
          return app.status == ApplicationStatus.submitted ||
              app.status == ApplicationStatus.draft ||
              app.status == ApplicationStatus.deficiency;
        }).toList();

      case ApplicationsFilter.underReview:
        return _applications.where((app) {
          return app.status == ApplicationStatus.inVerification;
        }).toList();

      case ApplicationsFilter.completed:
        return _applications.where((app) {
          return app.status == ApplicationStatus.completed ||
              app.status == ApplicationStatus.sanctioned;
        }).toList();
    }
  }

  /// Sets active filter tab and notifies listeners.
  void setFilter(ApplicationsFilter filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  /// Loads student applications from repository.
  Future<void> loadApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _applicationRepository.getApplications();

      // Ensure timeline is populated for each application
      final List<Application> populated = [];
      for (final app in results) {
        if (app.timeline == null || app.timeline!.isEmpty) {
          try {
            final timeline = await _applicationRepository.getApplicationTimeline(app.id);
            populated.add(Application(
              id: app.id,
              applicationNumber: app.applicationNumber,
              schemeId: app.schemeId,
              schemeCode: app.schemeCode,
              schemeName: app.schemeName,
              studentId: app.studentId,
              status: app.status,
              submittedAt: app.submittedAt,
              currentStage: app.currentStage,
              amountSanctioned: app.amountSanctioned,
              remarks: app.remarks,
              sourcePortal: app.sourcePortal,
              ministryName: app.ministryName,
              timeline: timeline,
            ));
          } catch (_) {
            populated.add(app);
          }
        } else {
          populated.add(app);
        }
      }

      _applications = populated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load applications. Please try again.';
      notifyListeners();
    }
  }

  /// Refreshes applications data.
  Future<void> refresh() => loadApplications();
}
