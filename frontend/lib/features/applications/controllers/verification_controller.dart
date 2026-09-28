import 'package:flutter/material.dart';
import '../../../models/application.dart';
import '../../../models/application_timeline.dart';
import '../../../models/document.dart';
import '../../../models/verification.dart';
import '../../../repositories/application_repository.dart';
import '../../../repositories/document_repository.dart';
import '../../../repositories/verification_repository.dart';

/// VerificationController manages data loading and state for the Application Verification screen.
/// Strictly conforms to:
/// - Screen -> Controller -> Repository -> ApiClient architecture
/// - GET /api/v1/applications/{id}/verifications
/// - Context resolution via ApplicationRepository and DocumentRepository
class VerificationController extends ChangeNotifier {
  final VerificationRepository _verificationRepository;
  final ApplicationRepository _applicationRepository;
  final DocumentRepository _documentRepository;
  final String _applicationId;

  VerificationController({
    required VerificationRepository verificationRepository,
    required ApplicationRepository applicationRepository,
    required DocumentRepository documentRepository,
    required String applicationId,
    Application? initialApplication,
  })  : _verificationRepository = verificationRepository,
        _applicationRepository = applicationRepository,
        _documentRepository = documentRepository,
        _applicationId = applicationId,
        _application = initialApplication;

  // ── STATE ──────────────────────────────────────────────────
  Application? _application;
  List<VerificationRecord> _verifications = [];
  Map<String, DocumentItem> _documentsMap = {};
  List<ApplicationTimelineEvent> _timelineEvents = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── GETTERS ────────────────────────────────────────────────
  Application? get application => _application;
  List<VerificationRecord> get verifications => _verifications;
  Map<String, DocumentItem> get documentsMap => _documentsMap;
  List<ApplicationTimelineEvent> get timelineEvents => _timelineEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get applicationId => _applicationId;

  /// Authoritative last updated timestamp from backend models (no client-side fabrication).
  DateTime? get lastUpdatedAt {
    if (_application?.lastUpdatedAt != null) {
      return _application!.lastUpdatedAt;
    }
    // Check if any verification record has a verifiedAt timestamp
    DateTime? latest;
    for (final v in _verifications) {
      if (v.verifiedAt != null) {
        if (latest == null || v.verifiedAt!.isAfter(latest)) {
          latest = v.verifiedAt;
        }
      }
    }
    return latest;
  }

  /// Loads application verification data and associated context efficiently without N+1 requests.
  Future<void> loadData({Application? initialApplication}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (initialApplication != null) {
        _application = initialApplication;
      }

      // 1. Load application context if not provided
      _application ??= await _applicationRepository.getApplicationById(_applicationId);

      // 2. Fetch verification records via primary API: GET /api/v1/applications/{id}/verifications
      _verifications = await _verificationRepository.getApplicationVerifications(_applicationId);

      // 3. Load documents catalog once to resolve document_id locally
      try {
        final docs = await _documentRepository.getDocuments();
        _documentsMap = {for (final d in docs) d.id: d};
      } catch (_) {
        // Document resolution failure shouldn't crash the verification screen
      }

      // 4. Resolve timeline events if available
      if (_application?.timeline != null && _application!.timeline!.isNotEmpty) {
        _timelineEvents = _application!.timeline!;
      } else {
        try {
          _timelineEvents = await _applicationRepository.getApplicationTimeline(_applicationId);
        } catch (_) {
          // Timeline fallback
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('ApiException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh action
  Future<void> refresh() async {
    return loadData();
  }

  /// Clears error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Resolves the human-readable document name for a verification record.
  String getDocumentName(VerificationRecord record) {
    if (record.documentId != null && _documentsMap.containsKey(record.documentId)) {
      final doc = _documentsMap[record.documentId]!;
      if (doc.docType == 'ST_CERTIFICATE' || doc.id == 'doc-02' || doc.docName == 'Caste Certificate') {
        return 'Caste Certificate (ST)';
      }
      if (doc.docType == 'INCOME_CERTIFICATE' || doc.id == 'doc-03' || doc.docName == 'Income Certificate') {
        return 'Annual Family Income Certificate';
      }
      return doc.docName;
    }

    // Fallback mapping based on canonical verification type
    switch (record.verificationType?.toUpperCase()) {
      case 'IDENTITY':
        return 'Aadhaar Card';
      case 'COMMUNITY':
        return 'Caste Certificate (ST)';
      case 'ACADEMIC':
        return 'Class 12 Marksheet';
      case 'INCOME':
        return 'Annual Family Income Certificate';
      case 'INSTITUTION':
        return 'Institution Admission Proof';
      default:
        return record.stageName.isNotEmpty ? record.stageName : 'Document';
    }
  }

  /// Resolves the subtitle / verification source for a verification record.
  String getDocumentSubtitle(VerificationRecord record) {
    if (record.remarks != null && record.remarks!.isNotEmpty) {
      return record.remarks!;
    }
    if (record.sourceSystem != null && record.sourceSystem!.isNotEmpty) {
      return 'Verified through ${record.sourceSystem}';
    }
    return '';
  }
}
