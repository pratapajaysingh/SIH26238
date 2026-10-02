import '../models/conflict_check_result.dart';
import '../models/eligibility_check_result.dart';
import 'eligibility_repository.dart';

/// MockEligibilityRepository provides deterministic mock responses conforming strictly
/// to the documented response contract for POST /api/v1/eligibility/check.
class MockEligibilityRepository implements EligibilityRepository {
  final Duration latency;

  MockEligibilityRepository({this.latency = const Duration(milliseconds: 300)});

  @override
  Future<EligibilityCheckResult> checkEligibility({
    required String studentId,
    required String schemeId,
  }) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    // National Overseas Scholarship is configured as not eligible to exercise the alternative branch
    if (schemeId == 'scheme-nos-06' || schemeId.toLowerCase().contains('overseas')) {
      return const EligibilityCheckResult(
        scheme: 'NATIONAL_OVERSEAS',
        eligible: false,
        missingItems: [
          'Valid Passport with 6-month validity',
          'Unconditional Offer Letter from Accredited Foreign University',
        ],
        rulesVersion: '2026.1',
      );
    }

    // Map known scheme IDs to standard codes
    final String schemeCode;
    switch (schemeId) {
      case 'scheme-top-class-02':
        schemeCode = 'TOP_CLASS';
        break;
      case 'scheme-nfst-03':
        schemeCode = 'NATIONAL_FELLOWSHIP_ST';
        break;
      case 'scheme-pre-matric-04':
        schemeCode = 'PRE_MATRIC';
        break;
      case 'scheme-medical-05':
        schemeCode = 'MEDICAL_ST';
        break;
      default:
        schemeCode = 'POST_MATRIC';
    }

    // Default eligible result matching the visual reference image
    return EligibilityCheckResult(
      scheme: schemeCode,
      eligible: true,
      missingItems: const [],
      rulesVersion: '2026.1',
    );
  }

  @override
  Future<ConflictCheckResult> checkConflict({
    required String studentId,
    required String schemeId,
  }) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    // Student 2 (Rani Marandi) or explicit eligible test
    if (studentId.contains('2') ||
        studentId == '00000000-0000-0000-0000-000000000002' ||
        schemeId == 'scheme-pre-matric-04' ||
        schemeId == 'no-conflict') {
      return ConflictCheckResult(
        studentId: studentId,
        scholarshipId: schemeId,
        eligible: true,
        status: 'ELIGIBLE',
        reasons: const ['No conflicting applications found; student may apply'],
        evaluationMode: 'MOCK',
      );
    }

    // Duplicate check for Post Matric
    if (schemeId == 'scheme-pms-st-01' || schemeId == 'POST_MATRIC') {
      return const ConflictCheckResult(
        studentId: 'TS2024S10023',
        scholarshipId: 'scheme-pms-st-01',
        eligible: false,
        status: 'DUPLICATE_APPLICATION',
        reasons: [
          'An active application already exists for this scheme (status: UNDER_REVIEW). You cannot submit a duplicate application for the same scheme.',
        ],
        existingApplicationId: 'app-2024-st-01',
        existingSchemeCode: 'POST_MATRIC',
        evaluationMode: 'MOCK',
      );
    }

    // Pending deficiency check for National Fellowship
    if (schemeId == 'scheme-nfst-03' || schemeId == 'NATIONAL_FELLOWSHIP_ST') {
      return const ConflictCheckResult(
        studentId: 'TS2024S10023',
        scholarshipId: 'scheme-nfst-03',
        eligible: false,
        status: 'PENDING_DEFICIENCY',
        reasons: [
          "Existing application for scheme 'NATIONAL_FELLOWSHIP_ST' has pending deficiency action required. Please resolve document discrepancies before applying.",
        ],
        existingApplicationId: 'app-2024-st-03',
        existingSchemeCode: 'NATIONAL_FELLOWSHIP_ST',
        evaluationMode: 'MOCK',
      );
    }

    // Default: Active application conflict with existing Post-Matric application
    return const ConflictCheckResult(
      studentId: 'TS2024S10023',
      scholarshipId: 'scheme-top-class-02',
      eligible: false,
      status: 'ACTIVE_APPLICATION_EXISTS',
      reasons: [
        'Student already has an active application for Post-Matric Scholarship (Application ID: app-2024-st-01). Under Ministry of Tribal Affairs guidelines, a student may only avail one scholarship scheme at a time.',
      ],
      existingApplicationId: 'app-2024-st-01',
      existingSchemeCode: 'POST_MATRIC',
      evaluationMode: 'MOCK',
    );
  }
}

