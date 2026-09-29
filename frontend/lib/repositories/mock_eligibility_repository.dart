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
}
