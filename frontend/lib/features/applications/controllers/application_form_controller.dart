import 'package:flutter/foundation.dart';
import '../../../models/application.dart';
import '../../../models/document.dart';
import '../../../models/scholarship.dart';
import '../../../models/student_profile.dart';
import '../../../repositories/application_repository.dart';
import '../../../repositories/document_repository.dart';
import '../../../repositories/profile_repository.dart';

/// ApplicationFormController manages the multi-step scholarship application lifecycle:
/// Draft Creation -> Pre-filled Profile -> Document Selection -> Review -> Submission Confirmation.
/// Follows strict Screen -> Controller -> Repository -> ApiClient pattern.
class ApplicationFormController extends ChangeNotifier {
  final ApplicationRepository applicationRepository;
  final ProfileRepository profileRepository;
  final DocumentRepository documentRepository;

  ApplicationFormController({
    required this.applicationRepository,
    required this.profileRepository,
    required this.documentRepository,
  });

  // ── STATE ──────────────────────────────────────────────────
  Application? _application;
  Scholarship? _scholarship;
  StudentProfile? _studentProfile;
  List<DocumentItem> _walletDocuments = [];
  final Set<String> _attachedDocumentIds = {};

  int _currentStep = 0; // 0: Details, 1: Documents, 2: Review, 3: Confirmation
  bool _isLoading = false;
  bool _isSavingDraft = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _feedbackMessage;

  String _academicYear = '2026-27';
  String _additionalRemarks = '';
  bool _declarationAccepted = false;

  // ── GETTERS ────────────────────────────────────────────────
  Application? get application => _application;
  Scholarship? get scholarship => _scholarship;
  StudentProfile? get studentProfile => _studentProfile;
  List<DocumentItem> get walletDocuments => List.unmodifiable(_walletDocuments);
  Set<String> get attachedDocumentIds => Set.unmodifiable(_attachedDocumentIds);

  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  bool get isSavingDraft => _isSavingDraft;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get feedbackMessage => _feedbackMessage;

  String get academicYear => _academicYear;
  String get additionalRemarks => _additionalRemarks;
  bool get declarationAccepted => _declarationAccepted;

  List<DocumentItem> get attachedDocuments {
    return _walletDocuments
        .where((doc) => _attachedDocumentIds.contains(doc.id))
        .toList();
  }

  // ── METHODS ────────────────────────────────────────────────

  void setAcademicYear(String year) {
    _academicYear = year;
    notifyListeners();
  }

  void setAdditionalRemarks(String remarks) {
    _additionalRemarks = remarks;
    notifyListeners();
  }

  void setDeclarationAccepted(bool accepted) {
    _declarationAccepted = accepted;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initializes the application flow for a scholarship scheme.
  Future<void> initialize({
    required Scholarship scheme,
    Application? existingApplication,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _scholarship = scheme;
    notifyListeners();

    try {
      // 1. Load or prefill student profile
      try {
        _studentProfile = await profileRepository.getProfile();
      } catch (_) {
        // Fallback or optional profile
      }

      // 2. Load reusable documents from wallet
      try {
        _walletDocuments = await documentRepository.getDocuments();
      } catch (_) {
        _walletDocuments = [];
      }

      // 3. Obtain draft application context
      if (existingApplication != null) {
        _application = existingApplication;
      } else {
        // Create new draft application: POST /api/v1/applications
        _application = await applicationRepository.createApplication(
          schemeId: scheme.id,
          academicYear: _academicYear,
        );
      }

      // 4. Fetch attached document IDs for this application
      if (_application != null) {
        final docIds = await applicationRepository.getApplicationDocumentIds(_application!.id);
        _attachedDocumentIds.clear();
        _attachedDocumentIds.addAll(docIds);

        // If no documents were attached yet, pre-select relevant verified documents from wallet
        if (_attachedDocumentIds.isEmpty) {
          for (final doc in _walletDocuments) {
            if (doc.categoryDisplay == 'Identity' ||
                doc.categoryDisplay == 'Academic' ||
                doc.categoryDisplay == 'Caste') {
              _attachedDocumentIds.add(doc.id);
            }
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Toggles attachment of a reusable document to the application.
  Future<void> toggleDocumentAttachment(String documentId) async {
    if (_application == null) return;
    final isAttached = _attachedDocumentIds.contains(documentId);

    try {
      if (isAttached) {
        // DELETE /api/v1/applications/{id}/documents/{documentId}
        final success = await applicationRepository.removeDocument(
          _application!.id,
          documentId,
        );
        if (success) {
          _attachedDocumentIds.remove(documentId);
          _feedbackMessage = 'Document removed from application.';
        }
      } else {
        // POST /api/v1/applications/{id}/documents
        final success = await applicationRepository.attachDocument(
          _application!.id,
          documentId,
        );
        if (success) {
          _attachedDocumentIds.add(documentId);
          _feedbackMessage = 'Document attached from wallet.';
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Saves the current draft with updated fields.
  Future<bool> saveDraft() async {
    if (_application == null) return false;
    _isSavingDraft = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await applicationRepository.updateApplication(
        _application!.id,
        {
          'academic_year': _academicYear,
          'remarks': _additionalRemarks,
        },
      );
      _application = updated;
      _isSavingDraft = false;
      _feedbackMessage = 'Draft saved successfully.';
      notifyListeners();
      return true;
    } catch (e) {
      _isSavingDraft = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Steps forward in multi-step wizard.
  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Steps backward in multi-step wizard.
  void previousStep() {
    if (_currentStep > 0 && _currentStep < 3) {
      _currentStep--;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Submits the application. Enforces submission safety and prevents duplicate calls.
  Future<bool> submitApplication() async {
    if (_application == null) return false;
    if (_isSubmitting) return false; // Prevent duplicate submit

    if (!_declarationAccepted) {
      _errorMessage = 'Please accept the declaration before submitting your application.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // POST /api/v1/applications/{id}/submit
      final submitted = await applicationRepository.submitApplication(_application!.id);
      _application = submitted;
      _isSubmitting = false;
      _currentStep = 3; // Advance to Confirmation screen
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
