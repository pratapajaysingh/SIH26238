import '../models/admin_dashboard_data.dart';
import '../models/manual_review_item.dart';
import '../models/notification_item.dart';
import '../models/unreached_beneficiary_item.dart';
import 'admin_repository.dart';
import 'mock_notification_repository.dart';

/// MockAdminRepository provides realistic demo data for offline testing and mock mode.
class MockAdminRepository implements AdminRepository {
  final Duration latency;

  MockAdminRepository({this.latency = const Duration(milliseconds: 250)});

  final List<ManualReviewItem> _mockReviews = [
    const ManualReviewItem(
      id: '00000000-0000-0000-0000-000000000040',
      applicationId: '00000000-0000-0000-0000-000000000023',
      verificationId: '00000000-0000-0000-0000-000000000052',
      status: 'OPEN',
      studentName: 'Sunita Soren',
      schemeName: 'Post-Matric Scholarship for ST Students',
      documentName: 'Income Certificate',
      reason: 'Mismatch between income self-declaration and State e-District portal certificate',
    ),
    const ManualReviewItem(
      id: '00000000-0000-0000-0000-000000000041',
      applicationId: '00000000-0000-0000-0000-000000000021',
      verificationId: '00000000-0000-0000-0000-000000000053',
      status: 'OPEN',
      studentName: 'Arjun Munda',
      schemeName: 'National Fellowship for ST Students (NFST)',
      documentName: 'UGC-NET Marksheet',
      reason: 'Roll number format mismatch against NTA mock database',
    ),
  ];

  final List<UnreachedBeneficiaryItem> _mockUnreached = [
    const UnreachedBeneficiaryItem(
      demoId: 'ENROL-ST-002',
      institutionCode: 'INST-GOV-202',
      institutionName: 'Tribal Welfare College, Bhubaneswar',
      educationLevel: 'B.A. First Year',
      enrollmentSource: 'AISHE',
      state: 'Odisha',
      matchedStatus: 'UNREACHED',
      scholarshipBenefitStatus: 'NONE',
      possibleReason: 'Enrolled via AISHE but no active scholarship application found',
      nextAction: 'Send awareness notification and assist with application via JAGO',
    ),
    const UnreachedBeneficiaryItem(
      demoId: 'ENROL-ST-003',
      institutionCode: 'INST-GOV-303',
      institutionName: 'Central University of Gujarat',
      educationLevel: 'M.Phil',
      enrollmentSource: 'OTR',
      state: 'Gujarat',
      matchedStatus: 'UNREACHED',
      scholarshipBenefitStatus: 'NONE',
      possibleReason: 'Student may be eligible for NFST fellowship but not yet registered',
      nextAction: 'Send awareness notification and assist with application via JAGO',
    ),
    const UnreachedBeneficiaryItem(
      demoId: 'ENROL-ST-005',
      institutionCode: 'INST-GOV-505',
      institutionName: 'Government School, Imphal',
      educationLevel: 'Class 10',
      enrollmentSource: 'UDISE+',
      state: 'Manipur',
      matchedStatus: 'UNREACHED',
      scholarshipBenefitStatus: 'NONE',
      possibleReason: 'Student may be eligible for Pre-Matric Scholarship but not yet registered',
      nextAction: 'Send awareness notification and assist with application via JAGO',
    ),
    const UnreachedBeneficiaryItem(
      demoId: 'ENROL-ST-001',
      institutionCode: 'INST-GOV-101',
      institutionName: 'Government Higher Secondary School, Ranchi',
      educationLevel: 'Class 11',
      enrollmentSource: 'UDISE+',
      state: 'Jharkhand',
      matchedStatus: 'MATCHED',
      scholarshipBenefitStatus: 'SANCTIONED',
      scholarshipCode: 'POST_MATRIC',
      nextAction: 'No action needed — student is receiving benefits',
    ),
    const UnreachedBeneficiaryItem(
      demoId: 'ENROL-ST-004',
      institutionCode: 'INST-PVT-404',
      institutionName: 'IIT Kharagpur',
      educationLevel: 'B.Tech Third Year',
      enrollmentSource: 'APAAR',
      state: 'West Bengal',
      matchedStatus: 'MATCHED',
      scholarshipBenefitStatus: 'SUBMITTED',
      scholarshipCode: 'TOP_CLASS_EDUCATION',
      nextAction: 'No action needed — student is receiving benefits',
    ),
  ];

  @override
  Future<AdminDashboardData> getDashboardAnalytics() async {
    await Future.delayed(latency);
    return const AdminDashboardData(
      totalApplications: 5,
      totalSanctioned: 2,
      totalCompleted: 1,
      totalRejected: 0,
      totalDeficiency: 2,
      schemeWiseApplications: [
        SchemeWiseStat(
          scholarshipId: '00000000-0000-0000-0000-000000000010',
          total: 2,
          draft: 1,
          submitted: 0,
          inVerification: 0,
          deficiency: 1,
          sanctioned: 0,
          rejected: 0,
          completed: 0,
        ),
        SchemeWiseStat(
          scholarshipId: '00000000-0000-0000-0000-000000000011',
          total: 1,
          draft: 0,
          submitted: 0,
          inVerification: 0,
          deficiency: 0,
          sanctioned: 1,
          rejected: 0,
          completed: 0,
        ),
        SchemeWiseStat(
          scholarshipId: '00000000-0000-0000-0000-000000000014',
          total: 1,
          draft: 0,
          submitted: 0,
          inVerification: 0,
          deficiency: 0,
          sanctioned: 0,
          rejected: 0,
          completed: 1,
        ),
      ],
      totalVerifications: 4,
      pendingVerifications: 1,
      totalManualReviews: 2,
      openManualReviews: 2,
      totalDisbursementEligible: 3,
      totalEnrolled: 5,
      totalMatched: 2,
      totalUnreached: 3,
      unreachedPercentage: 60.0,
    );
  }

  @override
  Future<List<ManualReviewItem>> getManualReviewQueue() async {
    await Future.delayed(latency);
    return List.unmodifiable(_mockReviews);
  }

  @override
  Future<ManualReviewItem> decideManualReview(
    String reviewId, {
    required String action,
    String? remarks,
  }) async {
    await Future.delayed(latency);
    final idx = _mockReviews.indexWhere((r) => r.id == reviewId);
    final resolvedStatus = action.toUpperCase() == 'APPROVE' ? 'RESOLVED' : 'REJECTED';
    if (idx != -1) {
      final updated = _mockReviews[idx].copyWith(
        status: resolvedStatus,
        remarks: remarks,
      );
      _mockReviews[idx] = updated;
      return updated;
    }
    return ManualReviewItem(
      id: reviewId,
      applicationId: 'mock-app',
      verificationId: 'mock-verif',
      status: resolvedStatus,
      remarks: remarks,
    );
  }

  @override
  Future<List<UnreachedBeneficiaryItem>> getUnreachedBeneficiaries({bool all = false}) async {
    await Future.delayed(latency);
    if (all) {
      return List.unmodifiable(_mockUnreached);
    }
    return _mockUnreached.where((s) => s.isUnreached).toList();
  }

  @override
  Future<bool> sendOutreachNotification({
    String? demoId,
    String? studentId,
    String? title,
    String? message,
  }) async {
    await Future.delayed(latency);
    MockNotificationRepository.addNotification(
      NotificationItem(
        id: 'notif-outreach-${DateTime.now().millisecondsSinceEpoch}',
        userId: studentId ?? 'TS2024S10023',
        title: title ?? 'Ministry Outreach: ST Scholarship Awareness',
        message: message ??
            'Awareness Outreach: You are enrolled in higher education under AISHE records but have no active scholarship application. Apply now for your eligible ST Post-Matric Scholarship on TribalSetu!',
        type: 'SYSTEM',
        applicationId: null,
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );
    return true;
  }
}
