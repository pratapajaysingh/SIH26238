import 'package:flutter/foundation.dart';
import '../../../models/admin_dashboard_data.dart';
import '../../../models/manual_review_item.dart';
import '../../../models/unreached_beneficiary_item.dart';
import '../../../repositories/admin_repository.dart';

/// AdminController manages state for the Ministry of Tribal Affairs (MoTA)
/// Admin Dashboard, Manual Review Exception Queue, and Unreached Student Outreach.
class AdminController extends ChangeNotifier {
  final AdminRepository adminRepository;

  AdminController({required this.adminRepository});

  // State
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  AdminDashboardData? _dashboardData;
  List<ManualReviewItem> _manualReviews = [];
  List<UnreachedBeneficiaryItem> _unreachedStudents = [];
  bool _showAllEnrolled = false;
  int _activeTabIndex = 0; // 0: Overview, 1: Manual Review, 2: Unreached Beneficiaries

  // Action states
  bool _isActionInProgress = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isActionInProgress => _isActionInProgress;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  AdminDashboardData? get dashboardData => _dashboardData;
  List<ManualReviewItem> get manualReviews => _manualReviews;
  List<UnreachedBeneficiaryItem> get unreachedStudents => _unreachedStudents;
  bool get showAllEnrolled => _showAllEnrolled;
  int get activeTabIndex => _activeTabIndex;

  void setActiveTab(int index) {
    if (_activeTabIndex != index) {
      _activeTabIndex = index;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Initial load of all admin datasets
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        adminRepository.getDashboardAnalytics(),
        adminRepository.getManualReviewQueue(),
        adminRepository.getUnreachedBeneficiaries(all: _showAllEnrolled),
      ]);

      _dashboardData = results[0] as AdminDashboardData;
      _manualReviews = results[1] as List<ManualReviewItem>;
      _unreachedStudents = results[2] as List<UnreachedBeneficiaryItem>;
    } catch (e) {
      _errorMessage = 'Failed to load ministry data: ${e.toString().replaceAll("Exception: ", "")}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes dashboard metrics
  Future<void> refreshDashboard() async {
    try {
      _dashboardData = await adminRepository.getDashboardAnalytics();
      notifyListeners();
    } catch (_) {}
  }

  /// Refreshes manual review queue
  Future<void> refreshManualReviews() async {
    try {
      _manualReviews = await adminRepository.getManualReviewQueue();
      notifyListeners();
    } catch (_) {}
  }

  /// Approves or rejects a manual verification review
  Future<bool> decideReview({
    required String reviewId,
    required String action, // "APPROVE" or "REJECT"
    String? remarks,
  }) async {
    _isActionInProgress = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await adminRepository.decideManualReview(
        reviewId,
        action: action,
        remarks: remarks,
      );

      final idx = _manualReviews.indexWhere((r) => r.id == reviewId);
      if (idx != -1) {
        _manualReviews[idx] = updated;
      }

      final actionWord = action.toUpperCase() == 'APPROVE' ? 'approved' : 'rejected';
      _successMessage = 'Manual review record $actionWord successfully.';
      await refreshDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to resolve review: ${e.toString().replaceAll("Exception: ", "")}';
      return false;
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }

  /// Toggles between all enrolled students and unreached beneficiaries only
  Future<void> toggleShowAllEnrolled(bool showAll) async {
    _showAllEnrolled = showAll;
    _isLoading = true;
    notifyListeners();

    try {
      _unreachedStudents = await adminRepository.getUnreachedBeneficiaries(all: _showAllEnrolled);
    } catch (e) {
      _errorMessage = 'Failed to filter students: ${e.toString().replaceAll("Exception: ", "")}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends awareness outreach notification to an unreached student
  Future<bool> sendOutreach({
    required String demoId,
    String? title,
    String? message,
  }) async {
    _isActionInProgress = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final success = await adminRepository.sendOutreachNotification(
        demoId: demoId,
        title: title ?? 'Scholarship Awareness Notice — Ministry of Tribal Affairs',
        message: message ??
            'You have been identified as potentially eligible for MoTA scholarship schemes. Open TribalSetu to verify details and submit an application.',
      );

      if (success) {
        final idx = _unreachedStudents.indexWhere((s) => s.demoId == demoId);
        if (idx != -1) {
          _unreachedStudents[idx] = _unreachedStudents[idx].copyWith(outreachSent: true);
        }
        _successMessage = 'Awareness outreach notification dispatched successfully.';
        return true;
      } else {
        _errorMessage = 'Failed to dispatch outreach notice. Please try again.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error dispatching outreach: ${e.toString().replaceAll("Exception: ", "")}';
      return false;
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }
}
