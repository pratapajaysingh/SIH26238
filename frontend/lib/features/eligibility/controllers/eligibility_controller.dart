import 'package:flutter/material.dart';
import '../../../models/eligibility_check_result.dart';
import '../../../models/scholarship.dart';
import '../../../repositories/eligibility_repository.dart';
import '../../../repositories/scholarship_repository.dart';

/// EligibilityController manages state and business flow for the Check Eligibility feature.
/// Strictly conforms to:
/// - Screen -> Controller -> Repository -> ApiClient architecture
/// - POST /api/v1/eligibility/check
/// - GET /api/v1/scholarships
class EligibilityController extends ChangeNotifier {
  final EligibilityRepository _eligibilityRepository;
  final ScholarshipRepository _scholarshipRepository;
  final String _studentId;

  EligibilityController({
    required EligibilityRepository eligibilityRepository,
    required ScholarshipRepository scholarshipRepository,
    String studentId = 'TS2024S10023',
    Scholarship? initialScheme,
  })  : _eligibilityRepository = eligibilityRepository,
        _scholarshipRepository = scholarshipRepository,
        _studentId = studentId,
        _selectedScheme = initialScheme;

  // ── STATE ──────────────────────────────────────────────────
  List<Scholarship> _scholarships = [];
  Scholarship? _selectedScheme;
  bool _isLoadingSchemes = false;
  bool _isChecking = false;
  EligibilityCheckResult? _result;
  String? _errorMessage;
  int _currentStep = 1;

  // ── GETTERS ────────────────────────────────────────────────
  List<Scholarship> get scholarships => _scholarships;
  Scholarship? get selectedScheme => _selectedScheme;
  bool get isLoadingSchemes => _isLoadingSchemes;
  bool get isChecking => _isChecking;
  EligibilityCheckResult? get result => _result;
  String? get errorMessage => _errorMessage;
  int get currentStep => _currentStep;
  String get studentId => _studentId;

  /// Loads the scholarship schemes catalog.
  Future<void> loadSchemes({
    Scholarship? preselectedScheme,
    String? preselectedSchemeId,
  }) async {
    _isLoadingSchemes = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _scholarships = await _scholarshipRepository.getScholarships();

      if (preselectedScheme != null) {
        _selectedScheme = preselectedScheme;
      } else if (preselectedSchemeId != null) {
        try {
          _selectedScheme = _scholarships.firstWhere(
            (s) => s.id == preselectedSchemeId,
          );
        } catch (_) {
          _selectedScheme = _scholarships.isNotEmpty ? _scholarships.first : null;
        }
      } else if (_selectedScheme == null && _scholarships.isNotEmpty) {
        // Default to first scheme (Post Matric Scholarship for ST Students) matching reference
        _selectedScheme = _scholarships.first;
      }
    } catch (e) {
      _errorMessage = 'Unable to load scholarship schemes. Please try again.';
    } finally {
      _isLoadingSchemes = false;
      notifyListeners();
    }
  }

  /// Selects a scholarship scheme and resets any previous evaluation result.
  void selectScheme(Scholarship scheme) {
    if (_selectedScheme?.id == scheme.id) return;
    _selectedScheme = scheme;
    _result = null;
    _errorMessage = null;
    _currentStep = 1;
    notifyListeners();
  }

  /// Evaluates scheme eligibility for the selected scheme and authenticated student.
  /// Strict contract:
  /// POST /api/v1/eligibility/check
  /// Body: {"student_id": "...", "scheme_id": "..."}
  Future<void> checkEligibility() async {
    // Prevent duplicate concurrent requests
    if (_isChecking) return;

    if (_selectedScheme == null) {
      _errorMessage = 'Please select a scholarship scheme first.';
      notifyListeners();
      return;
    }

    _isChecking = true;
    _errorMessage = null;
    _currentStep = 3;
    notifyListeners();

    try {
      final res = await _eligibilityRepository.checkEligibility(
        studentId: _studentId,
        schemeId: _selectedScheme!.id,
      );

      _result = res;
      _currentStep = 4;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('ApiException: ', '');
      _currentStep = 1;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Clears error message and resets step
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets result back to step 1
  void reset() {
    _result = null;
    _errorMessage = null;
    _currentStep = 1;
    notifyListeners();
  }
}
