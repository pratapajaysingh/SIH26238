import '../core/enums/application_status.dart';
import '../models/application.dart';
import '../models/application_timeline.dart';
import '../models/deficiency.dart';
import 'application_repository.dart';

/// MockApplicationRepository provides deterministic application and timeline data
/// strictly matching the visual reference stages and cards:
/// 1. Post Matric Scholarship for ST Students (Under Review, TS2024PMS10023)
/// 2. Top Class Education Scheme for ST Students (In Progress, TS2024TCS00456)
/// 3. National Fellowship for ST Students (Documents Required, TS2024NF07890)
/// 4. Pre Matric Scholarship for ST Students (Rejected, TS2023PRE11223)
/// 5. National Overseas Scholarship for ST Students (Completed, TS2023NOS55678)
class MockApplicationRepository implements ApplicationRepository {
  final Duration latency;

  MockApplicationRepository({this.latency = const Duration(milliseconds: 300)});

  static final List<ApplicationTimelineEvent> _timelineCard1 = [
    ApplicationTimelineEvent(
      id: 'evt-1-1',
      applicationId: 'app-2024-st-01',
      stage: 'Applied',
      title: 'Application Submitted Online',
      description: 'Submitted successfully with DigiLocker verified documents.',
      status: 'COMPLETED',
      date: DateTime(2024, 9, 12),
      dateFormatted: '12 Sep 2024',
      stageIndex: 0,
    ),
    ApplicationTimelineEvent(
      id: 'evt-1-2',
      applicationId: 'app-2024-st-01',
      stage: 'Under Review',
      title: 'Institute Verification',
      description: 'Academic credentials under scrutiny by designated nodal officer.',
      status: 'IN_PROGRESS',
      date: DateTime(2024, 9, 18),
      dateFormatted: '18 Sep 2024',
      stageIndex: 1,
    ),
    const ApplicationTimelineEvent(
      id: 'evt-1-3',
      applicationId: 'app-2024-st-01',
      stage: 'Verification',
      title: 'State & Ministry Verification',
      description: 'Departmental approval and sanction generation.',
      status: 'PENDING',
      date: null,
      dateFormatted: '-',
      stageIndex: 2,
    ),
    const ApplicationTimelineEvent(
      id: 'evt-1-4',
      applicationId: 'app-2024-st-01',
      stage: 'Payment',
      title: 'Aadhaar DBT Disbursal',
      description: 'Direct Benefit Transfer credited to linked bank account.',
      status: 'PENDING',
      date: null,
      dateFormatted: '-',
      stageIndex: 3,
    ),
  ];

  static final List<ApplicationTimelineEvent> _timelineCard2 = [
    ApplicationTimelineEvent(
      id: 'evt-2-1',
      applicationId: 'app-2024-st-02',
      stage: 'Applied',
      title: 'Application Submitted',
      description: 'Submitted through National Scholarship Portal.',
      status: 'COMPLETED',
      date: DateTime(2024, 8, 3),
      dateFormatted: '03 Aug 2024',
      stageIndex: 0,
    ),
    ApplicationTimelineEvent(
      id: 'evt-2-2',
      applicationId: 'app-2024-st-02',
      stage: 'Document Review',
      title: 'Document Verification',
      description: 'Institute verification in progress.',
      status: 'IN_PROGRESS',
      date: DateTime(2024, 8, 10),
      dateFormatted: '10 Aug 2024',
      stageIndex: 1,
    ),
    const ApplicationTimelineEvent(
      id: 'evt-2-3',
      applicationId: 'app-2024-st-02',
      stage: 'Verification',
      title: 'Ministry Scrutiny',
      description: 'Awaiting state nodal authority verification.',
      status: 'PENDING',
      date: null,
      dateFormatted: '-',
      stageIndex: 2,
    ),
    const ApplicationTimelineEvent(
      id: 'evt-2-4',
      applicationId: 'app-2024-st-02',
      stage: 'Payment',
      title: 'DBT Payment',
      description: 'Sanction and disbursal to student bank account.',
      status: 'PENDING',
      date: null,
      dateFormatted: '-',
      stageIndex: 3,
    ),
  ];

  static final List<ApplicationTimelineEvent> _timelineCard3 = [
    ApplicationTimelineEvent(
      id: 'evt-3-1',
      applicationId: 'app-2024-st-03',
      stage: 'Applied',
      title: 'Application Submitted',
      description: 'Fellowship registration completed.',
      status: 'COMPLETED',
      date: DateTime(2024, 6, 21),
      dateFormatted: '21 Jun 2024',
      stageIndex: 0,
    ),
    const ApplicationTimelineEvent(
      id: 'evt-3-2',
      applicationId: 'app-2024-st-03',
      stage: 'Document Review Pending',
      title: 'Deficiency Noticed',
      description: 'Income Certificate and Caste Certificate re-upload requested.',
      status: 'DEFICIENCY',
      date: null,
      dateFormatted: '-',
      stageIndex: 1,
    ),
    const ApplicationTimelineEvent(
      id: 'evt-3-3',
      applicationId: 'app-2024-st-03',
      stage: 'Verification',
      title: 'Expert Committee Review',
      description: 'Pending document correction.',
      status: 'PENDING',
      date: null,
      dateFormatted: '-',
      stageIndex: 2,
    ),
    const ApplicationTimelineEvent(
      id: 'evt-3-4',
      applicationId: 'app-2024-st-03',
      stage: 'Payment',
      title: 'Fellowship Grant Disbursal',
      description: 'Monthly fellowship release via PFMS.',
      status: 'PENDING',
      date: null,
      dateFormatted: '-',
      stageIndex: 3,
    ),
  ];

  static final List<ApplicationTimelineEvent> _timelineCard4 = [
    ApplicationTimelineEvent(
      id: 'evt-4-1',
      applicationId: 'app-2023-st-04',
      stage: 'Applied',
      title: 'Application Submitted',
      description: 'Pre-matric online submission completed.',
      status: 'COMPLETED',
      date: DateTime(2024, 1, 10),
      dateFormatted: '10 Jan 2024',
      stageIndex: 0,
    ),
    ApplicationTimelineEvent(
      id: 'evt-4-2',
      applicationId: 'app-2023-st-04',
      stage: 'Under Review',
      title: 'Ineligible Family Income',
      description: 'Family income certificate exceeds the scheme threshold.',
      status: 'REJECTED',
      date: DateTime(2024, 1, 25),
      dateFormatted: '25 Jan 2024',
      stageIndex: 1,
    ),
    const ApplicationTimelineEvent(
      id: 'evt-4-3',
      applicationId: 'app-2023-st-04',
      stage: 'Verification',
      title: 'Verification Terminated',
      description: 'Application rejected during scrutiny.',
      status: 'PENDING',
      date: null,
      dateFormatted: '-',
      stageIndex: 2,
    ),
    const ApplicationTimelineEvent(
      id: 'evt-4-4',
      applicationId: 'app-2023-st-04',
      stage: 'Payment',
      title: 'Not Sanctioned',
      description: 'Disbursement cancelled.',
      status: 'PENDING',
      date: null,
      dateFormatted: '-',
      stageIndex: 3,
    ),
  ];

  static final List<ApplicationTimelineEvent> _timelineCard5 = [
    ApplicationTimelineEvent(
      id: 'evt-5-1',
      applicationId: 'app-2023-st-05',
      stage: 'Applied',
      title: 'Application Submitted',
      description: 'International scholarship application with admission offer.',
      status: 'COMPLETED',
      date: DateTime(2023, 11, 15),
      dateFormatted: '15 Nov 2023',
      stageIndex: 0,
    ),
    ApplicationTimelineEvent(
      id: 'evt-5-2',
      applicationId: 'app-2023-st-05',
      stage: 'Under Review',
      title: 'Document & Visa Scrutiny',
      description: 'University admission and passport verification verified.',
      status: 'COMPLETED',
      date: DateTime(2023, 11, 28),
      dateFormatted: '28 Nov 2023',
      stageIndex: 1,
    ),
    ApplicationTimelineEvent(
      id: 'evt-5-3',
      applicationId: 'app-2023-st-05',
      stage: 'Verification',
      title: 'MoTA Committee Sanction',
      description: 'Sanction letter issued and verified.',
      status: 'COMPLETED',
      date: DateTime(2023, 12, 10),
      dateFormatted: '10 Dec 2023',
      stageIndex: 2,
    ),
    ApplicationTimelineEvent(
      id: 'evt-5-4',
      applicationId: 'app-2023-st-05',
      stage: 'Payment',
      title: 'Tuition & Allowance Disbursal',
      description: 'First installment disbursed to university account.',
      status: 'COMPLETED',
      date: DateTime(2023, 12, 22),
      dateFormatted: '22 Dec 2023',
      stageIndex: 3,
    ),
  ];

  static final Application _activeApplication = Application(
    id: 'app-2024-st-01',
    applicationNumber: 'TS2024S10023',
    schemeId: 'scheme-pms-st-01',
    schemeCode: 'POST_MATRIC',
    schemeName: 'Post Matric Scholarship for ST Students',
    ministryName: 'Ministry of Tribal Affairs',
    studentId: 'TS2024S10023',
    status: ApplicationStatus.inVerification,
    submittedAt: DateTime(2024, 9, 12),
    currentStage: 'Under Review',
    amountSanctioned: 48000.0,
    sourcePortal: 'NSP',
    timeline: _timelineCard1,
  );

  static final List<Application> _allApplications = [
    Application(
      id: 'app-2024-st-01',
      applicationNumber: 'TS2024PMS10023',
      schemeId: 'scheme-pms-st-01',
      schemeCode: 'POST_MATRIC',
      schemeName: 'Post Matric Scholarship for ST Students',
      ministryName: 'Ministry of Tribal Affairs',
      studentId: 'TS2024S10023',
      status: ApplicationStatus.inVerification,
      submittedAt: DateTime(2024, 9, 12),
      lastUpdatedAt: DateTime(2025, 12, 12, 16, 30),
      currentStage: 'Under Review',
      amountSanctioned: 48000.0,
      sourcePortal: 'NSP',
      timeline: _timelineCard1,
    ),
    Application(
      id: 'app-2024-st-02',
      applicationNumber: 'TS2024TCS00456',
      schemeId: 'scheme-tcs-st-02',
      schemeCode: 'TOP_CLASS',
      schemeName: 'Top Class Education Scheme for ST Students',
      ministryName: 'Ministry of Education',
      studentId: 'TS2024S10023',
      status: ApplicationStatus.submitted,
      submittedAt: DateTime(2024, 8, 3),
      currentStage: 'Document Review',
      amountSanctioned: null,
      sourcePortal: 'NSP',
      timeline: _timelineCard2,
    ),
    Application(
      id: 'app-2024-st-03',
      applicationNumber: 'TS2024NF07890',
      schemeId: 'scheme-nf-st-03',
      schemeCode: 'NATIONAL_FELLOWSHIP',
      schemeName: 'National Fellowship for ST Students',
      ministryName: 'Ministry of Tribal Affairs',
      studentId: 'TS2024S10023',
      status: ApplicationStatus.deficiency,
      submittedAt: DateTime(2024, 6, 21),
      currentStage: 'Document Review Pending',
      amountSanctioned: null,
      sourcePortal: 'National Fellowship Portal',
      timeline: _timelineCard3,
    ),
    Application(
      id: 'app-2023-st-04',
      applicationNumber: 'TS2023PRE11223',
      schemeId: 'scheme-pre-st-04',
      schemeCode: 'PRE_MATRIC',
      schemeName: 'Pre Matric Scholarship for ST Students',
      ministryName: 'Ministry of Social Justice',
      studentId: 'TS2024S10023',
      status: ApplicationStatus.rejected,
      submittedAt: DateTime(2024, 1, 10),
      currentStage: 'Under Review',
      amountSanctioned: null,
      sourcePortal: 'State Welfare Portal',
      timeline: _timelineCard4,
    ),
    Application(
      id: 'app-2023-st-05',
      applicationNumber: 'TS2023NOS55678',
      schemeId: 'scheme-nos-st-05',
      schemeCode: 'NATIONAL_OVERSEAS',
      schemeName: 'National Overseas Scholarship for ST Students',
      ministryName: 'Ministry of Tribal Affairs',
      studentId: 'TS2024S10023',
      status: ApplicationStatus.completed,
      submittedAt: DateTime(2023, 11, 15),
      currentStage: 'Payment Disbursed',
      amountSanctioned: 2400000.0,
      sourcePortal: 'MoTA Overseas Portal',
      timeline: _timelineCard5,
    ),
  ];

  static final Application _referencePaymentApplication = Application(
    id: 'app-2026-st-01',
    applicationNumber: 'TS2026ST000123',
    schemeId: 'scheme-pms-st-01',
    schemeCode: 'POST_MATRIC',
    schemeName: 'Post Matric Scholarship for ST Students',
    ministryName: 'Ministry of Tribal Affairs, Government of India',
    studentId: 'TS2024S10023',
    status: ApplicationStatus.sanctioned,
    submittedAt: DateTime(2026, 1, 5),
    lastUpdatedAt: DateTime(2026, 1, 10),
    currentStage: 'Payment Processing',
    amountSanctioned: 48000.0,
    sourcePortal: 'NSP',
    timeline: _timelineCard1,
  );

  @override
  Future<List<Application>> getApplications() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    return List<Application>.from(_allApplications);
  }

  @override
  Future<Application?> getActiveApplication() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    return _activeApplication;
  }

  @override
  Future<List<ApplicationTimelineEvent>> getApplicationTimeline(String applicationId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    switch (applicationId) {
      case 'app-2024-st-01':
        return _timelineCard1;
      case 'app-2024-st-02':
        return _timelineCard2;
      case 'app-2024-st-03':
        return _timelineCard3;
      case 'app-2023-st-04':
        return _timelineCard4;
      case 'app-2023-st-05':
        return _timelineCard5;
      default:
        return _timelineCard1;
    }
  }

  @override
  Future<Application?> getApplicationById(String id) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (id == 'app-2026-st-01' || id == 'TS2026ST000123') {
      return _referencePaymentApplication;
    }
    final combined = [..._dynamicApplications, ..._allApplications];
    try {
      return combined.firstWhere((a) => a.id == id || a.applicationNumber == id);
    } catch (_) {
      // If not found by exact ID, return first matching or active application
      return combined.isNotEmpty ? combined.first : null;
    }
  }

  static final List<Application> _dynamicApplications = [];
  static final Map<String, Set<String>> _applicationDocumentsMap = {};

  @override
  Future<Application> createApplication({
    required String schemeId,
    required String academicYear,
  }) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    String schemeCode = 'POST_MATRIC';
    String schemeName = 'Post Matric Scholarship for ST Students';
    String ministry = 'Ministry of Tribal Affairs';

    if (schemeId.contains('top-class') || schemeId.contains('tcs')) {
      schemeCode = 'TOP_CLASS';
      schemeName = 'Top Class Education Scheme for ST Students';
      ministry = 'Ministry of Education';
    } else if (schemeId.contains('nfst') || schemeId.contains('fellowship')) {
      schemeCode = 'NATIONAL_FELLOWSHIP';
      schemeName = 'National Fellowship for ST Students';
      ministry = 'University Grants Commission';
    } else if (schemeId.contains('pre-matric')) {
      schemeCode = 'PRE_MATRIC';
      schemeName = 'Pre Matric Scholarship for ST Students';
      ministry = 'Ministry of Social Justice';
    } else if (schemeId.contains('nos') || schemeId.contains('overseas')) {
      schemeCode = 'NATIONAL_OVERSEAS';
      schemeName = 'National Overseas Scholarship for ST Candidates';
      ministry = 'Ministry of Tribal Affairs';
    }

    final newApp = Application(
      id: 'app-draft-${DateTime.now().millisecondsSinceEpoch}',
      applicationNumber: 'TS-2026-${(100000 + _dynamicApplications.length + 1)}',
      schemeId: schemeId,
      schemeCode: schemeCode,
      schemeName: schemeName,
      ministryName: ministry,
      studentId: 'TS2024S10023',
      status: ApplicationStatus.draft,
      submittedAt: DateTime(2026, 1, 15),
      currentStage: 'Draft',
      academicYear: academicYear,
      sourcePortal: 'NSP',
      timeline: const [],
    );

    _dynamicApplications.insert(0, newApp);
    return newApp;
  }

  @override
  Future<Application> updateApplication(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    final existing = await getApplicationById(id);
    if (existing == null) {
      throw Exception('Application $id not found for update');
    }

    final updated = Application(
      id: existing.id,
      applicationNumber: existing.applicationNumber,
      schemeId: data['scheme_id'] as String? ?? existing.schemeId,
      schemeCode: existing.schemeCode,
      schemeName: existing.schemeName,
      ministryName: existing.ministryName,
      studentId: existing.studentId,
      status: existing.status,
      submittedAt: existing.submittedAt,
      currentStage: existing.currentStage,
      amountSanctioned: (data['amount_sanctioned'] as num?)?.toDouble() ?? existing.amountSanctioned,
      remarks: data['remarks'] as String? ?? existing.remarks,
      academicYear: data['academic_year'] as String? ?? existing.academicYear,
      sourcePortal: existing.sourcePortal,
      lastUpdatedAt: DateTime.now(),
      timeline: existing.timeline,
    );

    final idx = _dynamicApplications.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _dynamicApplications[idx] = updated;
    } else {
      _dynamicApplications.add(updated);
    }
    return updated;
  }

  @override
  Future<Application> submitApplication(String id) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    final existing = await getApplicationById(id);
    if (existing == null) {
      throw Exception('Application $id not found for submission');
    }

    final submitted = Application(
      id: existing.id,
      applicationNumber: existing.applicationNumber,
      schemeId: existing.schemeId,
      schemeCode: existing.schemeCode,
      schemeName: existing.schemeName,
      ministryName: existing.ministryName,
      studentId: existing.studentId,
      status: ApplicationStatus.submitted,
      submittedAt: DateTime.now(),
      currentStage: 'Institute Verification',
      amountSanctioned: existing.amountSanctioned,
      remarks: 'Application submitted successfully for institutional scrutiny.',
      academicYear: existing.academicYear,
      sourcePortal: existing.sourcePortal,
      lastUpdatedAt: DateTime.now(),
      timeline: [
        ApplicationTimelineEvent(
          id: 'evt-sub-${DateTime.now().millisecondsSinceEpoch}',
          applicationId: existing.id,
          stage: 'Applied',
          title: 'Application Submitted Online',
          description: 'Submitted successfully with verified student documents.',
          status: 'COMPLETED',
          date: DateTime.now(),
          dateFormatted: 'Today',
          stageIndex: 0,
        ),
        ApplicationTimelineEvent(
          id: 'evt-sub-2',
          applicationId: existing.id,
          stage: 'Under Review',
          title: 'Institute Verification',
          description: 'Awaiting nodal officer verification at the institution.',
          status: 'IN_PROGRESS',
          date: null,
          dateFormatted: '-',
          stageIndex: 1,
        ),
      ],
    );

    final idx = _dynamicApplications.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _dynamicApplications[idx] = submitted;
    } else {
      _dynamicApplications.add(submitted);
    }
    return submitted;
  }

  @override
  Future<bool> attachDocument(String applicationId, String documentId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    _applicationDocumentsMap.putIfAbsent(applicationId, () => <String>{}).add(documentId);
    return true;
  }

  @override
  Future<bool> removeDocument(String applicationId, String documentId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (_applicationDocumentsMap.containsKey(applicationId)) {
      _applicationDocumentsMap[applicationId]!.remove(documentId);
    }
    return true;
  }

  @override
  Future<List<ApplicationDeficiency>> getApplicationDeficiencies(String applicationId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    // Return sample deficiency for Card 3 or seed demo application
    if (applicationId == 'app-2024-st-03' || applicationId.contains('00000000-0000-0000-0000-000000000020')) {
      return [
        ApplicationDeficiency(
          id: 'def-rec-$applicationId',
          applicationId: applicationId,
          deficiencyType: 'DOCUMENT_MISMATCH',
          type: 'DOCUMENT_MISMATCH',
          category: 'VERIFICATION',
          documentId: 'doc-02',
          documentName: 'ST Caste Certificate',
          documentType: 'MOCK_ST_CERTIFICATE',
          verificationId: 'verif-02',
          status: 'MISMATCH',
          severity: 'HIGH',
          message: 'Document verification mismatch requires correction or review',
          reason: 'Document verification mismatch requires correction or review',
        ),
      ];
    }
    return [];
  }

  @override
  Future<Application> transitionApplicationStatus(
    String id,
    String status, {
    String? message,
  }) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    final existing = await getApplicationById(id);
    if (existing != null) {
      final updated = Application(
        id: existing.id,
        applicationNumber: existing.applicationNumber,
        schemeId: existing.schemeId,
        schemeCode: existing.schemeCode,
        schemeName: existing.schemeName,
        studentId: existing.studentId,
        status: ApplicationStatus.fromString(status),
        submittedAt: existing.submittedAt,
        currentStage: status,
        amountSanctioned: existing.amountSanctioned,
        remarks: message ?? existing.remarks,
        sourcePortal: existing.sourcePortal,
        ministryName: existing.ministryName,
        academicYear: existing.academicYear,
        sourceSystem: existing.sourceSystem,
        externalAppId: existing.externalAppId,
        lastUpdatedAt: DateTime.now(),
        timeline: existing.timeline,
      );
      final idx = _dynamicApplications.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _dynamicApplications[idx] = updated;
      } else {
        _dynamicApplications.add(updated);
      }
      return updated;
    }
    throw Exception('Application not found');
  }

  @override
  Future<List<String>> getApplicationDocumentIds(String applicationId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (_applicationDocumentsMap.containsKey(applicationId)) {
      return _applicationDocumentsMap[applicationId]!.toList();
    }
    // Default attached documents for canonical applications
    return ['doc-01', 'doc-10', 'doc-02'];
  }
}
