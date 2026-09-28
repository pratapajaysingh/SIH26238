import 'package:flutter/material.dart';
import '../../../core/enums/application_status.dart';
import '../../../core/enums/payment_status.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/application.dart';
import '../../../models/application_timeline.dart';
import '../../../models/document.dart';
import '../../../models/payment.dart';
import '../../../models/verification.dart';
import '../../../repositories/application_repository.dart';
import '../../../repositories/document_repository.dart';
import '../../../repositories/payment_repository.dart';
import '../../../repositories/verification_repository.dart';

/// Available presentation sections in Application Details.
enum ApplicationDetailsTab {
  overview('Overview'),
  documents('Documents'),
  timeline('Timeline'),
  payments('Payments');

  final String label;
  const ApplicationDetailsTab(this.label);
}

/// ApplicationDetailsController manages data loading and section navigation for Application Details.
/// Conforms to:
/// - Screen -> Controller -> Repository -> ApiClient architecture
/// - GET /api/v1/applications/{id}
/// - GET /api/v1/applications/{id}/timeline
/// - GET /api/v1/applications/{id}/verifications
/// - GET /api/v1/applications/{id}/payments
/// - GET /api/v1/documents
class ApplicationDetailsController extends ChangeNotifier {
  final ApplicationRepository _applicationRepository;
  final VerificationRepository _verificationRepository;
  final PaymentRepository _paymentRepository;
  final DocumentRepository _documentRepository;
  final String _applicationId;

  ApplicationDetailsController({
    required ApplicationRepository applicationRepository,
    required VerificationRepository verificationRepository,
    required PaymentRepository paymentRepository,
    required DocumentRepository documentRepository,
    required String applicationId,
    Application? initialApplication,
  })  : _applicationRepository = applicationRepository,
        _verificationRepository = verificationRepository,
        _paymentRepository = paymentRepository,
        _documentRepository = documentRepository,
        _applicationId = applicationId,
        _application = initialApplication;

  // ── STATE ──────────────────────────────────────────────────
  Application? _application;
  List<ApplicationTimelineEvent> _timelineEvents = [];
  List<VerificationRecord> _verifications = [];
  List<PaymentRecord> _payments = [];
  List<DocumentItem> _documents = [];
  ApplicationDetailsTab _selectedTab = ApplicationDetailsTab.overview;
  bool _isLoading = false;
  String? _errorMessage;

  // ── GETTERS ────────────────────────────────────────────────
  Application? get application => _application;
  List<ApplicationTimelineEvent> get timelineEvents => _timelineEvents;
  List<VerificationRecord> get verifications => _verifications;
  List<PaymentRecord> get payments => _payments;
  List<DocumentItem> get documents => _documents;
  ApplicationDetailsTab get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get applicationId => _applicationId;

  PaymentRecord? get primaryPayment => _payments.isNotEmpty ? _payments.first : null;

  String get academicYear => _application?.academicYear ?? '2024 - 2025';

  String get appliedDate =>
      _application?.submittedAt != null ? DateFormatter.formatDate(_application!.submittedAt) : '12 Aug 2024';

  void setTab(ApplicationDetailsTab tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  /// Loads application details and all required sub-resources concurrently.
  Future<void> loadData({Application? initialApplication}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (initialApplication != null) {
        _application = initialApplication;
      }

      // 1. Load application context if not present: GET /api/v1/applications/{id}
      _application ??= await _applicationRepository.getApplicationById(_applicationId);

      // 2. Load sub-resources concurrently without redundant rebuild triggers
      final results = await Future.wait([
        // Timeline: GET /api/v1/applications/{id}/timeline
        _applicationRepository.getApplicationTimeline(_applicationId).catchError((_) => <ApplicationTimelineEvent>[]),
        // Verifications: GET /api/v1/applications/{id}/verifications
        _verificationRepository.getApplicationVerifications(_applicationId).catchError((_) => <VerificationRecord>[]),
        // Payments: GET /api/v1/applications/{id}/payments
        _paymentRepository.getApplicationPayments(_applicationId).catchError((_) => <PaymentRecord>[]),
        // Documents: GET /api/v1/documents
        _documentRepository.getDocuments().catchError((_) => <DocumentItem>[]),
      ]);

      _timelineEvents = results[0] as List<ApplicationTimelineEvent>;
      _verifications = results[1] as List<VerificationRecord>;
      _payments = results[2] as List<PaymentRecord>;
      _documents = results[3] as List<DocumentItem>;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('ApiException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    return loadData();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Derives presentation status label for application
  String getApplicationStatusLabel(ApplicationStatus? status) {
    if (status == null) return 'Under Verification';
    switch (status) {
      case ApplicationStatus.inVerification:
        return 'Under Verification';
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.draft:
        return 'Draft';
      case ApplicationStatus.deficiency:
        return 'Action Required';
      case ApplicationStatus.sanctioned:
        return 'Sanctioned';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
      case ApplicationStatus.completed:
        return 'Completed';
    }
  }

  /// Derives presentation status label for payment
  String getPaymentStatusLabel(PaymentStatus? status) {
    if (status == null) return 'Not Disbursed';
    switch (status) {
      case PaymentStatus.credited:
        return 'Credited';
      case PaymentStatus.processing:
        return 'Not Disbursed';
      case PaymentStatus.dbtInitiated:
        return 'DBT Initiated';
      case PaymentStatus.sanctioned:
        return 'Sanctioned';
      case PaymentStatus.failed:
        return 'Payment Failed';
    }
  }
}
