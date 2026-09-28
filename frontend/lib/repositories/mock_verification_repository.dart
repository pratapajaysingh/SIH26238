import '../core/enums/verification_status.dart';
import '../models/verification.dart';
import 'verification_repository.dart';

/// MockVerificationRepository provides deterministic verification data strictly matching
/// the reference image and API contract (Section 7).
class MockVerificationRepository implements VerificationRepository {
  final Duration latency;

  MockVerificationRepository({this.latency = const Duration(milliseconds: 300)});

  @override
  Future<List<VerificationRecord>> getApplicationVerifications(String applicationId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    // Return empty list if application is marked as having no verifications
    if (applicationId == 'app-empty') {
      return [];
    }

    // Default 5 verification records strictly matching reference image
    return [
      VerificationRecord(
        id: 'ver-01',
        applicationId: applicationId,
        documentId: 'doc-01',
        verificationType: 'IDENTITY',
        sourceSystem: 'UIDAI',
        status: VerificationStatus.verified,
        confidenceScore: 0.99,
        externalReference: 'UIDAI-2025-99881',
        remarks: 'Verified through UIDAI',
        verifiedAt: DateTime(2025, 12, 12, 10, 15),
        createdAt: DateTime(2025, 12, 10, 9, 30),
      ),
      VerificationRecord(
        id: 'ver-02',
        applicationId: applicationId,
        documentId: 'doc-02',
        verificationType: 'COMMUNITY',
        sourceSystem: 'State Government',
        status: VerificationStatus.verified,
        confidenceScore: 1.0,
        externalReference: 'CG-EDIST-44321',
        remarks: 'Verified through State Government',
        verifiedAt: DateTime(2025, 12, 12, 10, 20),
        createdAt: DateTime(2025, 12, 10, 9, 30),
      ),
      VerificationRecord(
        id: 'ver-03',
        applicationId: applicationId,
        documentId: 'doc-04',
        verificationType: 'ACADEMIC',
        sourceSystem: 'Education Board',
        status: VerificationStatus.verified,
        confidenceScore: 0.98,
        externalReference: 'CBSE-2024-88991',
        remarks: 'Verified through Education Board',
        verifiedAt: DateTime(2025, 12, 12, 10, 25),
        createdAt: DateTime(2025, 12, 10, 9, 30),
      ),
      VerificationRecord(
        id: 'ver-04',
        applicationId: applicationId,
        documentId: 'doc-03',
        verificationType: 'INCOME',
        sourceSystem: 'Revenue Department',
        status: VerificationStatus.pending,
        confidenceScore: null,
        externalReference: null,
        remarks: 'Awaiting verification from Revenue Dept.',
        verifiedAt: null,
        createdAt: DateTime(2025, 12, 12, 11, 10),
      ),
      VerificationRecord(
        id: 'ver-05',
        applicationId: applicationId,
        documentId: 'doc-05',
        verificationType: 'INSTITUTION',
        sourceSystem: 'AISHE / University Portal',
        status: VerificationStatus.manualReview,
        confidenceScore: 0.75,
        externalReference: 'NIT-ADM-2024-11',
        remarks: 'Flagged for manual review by AISHE',
        verifiedAt: null,
        createdAt: DateTime(2025, 12, 12, 13, 45),
      ),
    ];
  }
}
