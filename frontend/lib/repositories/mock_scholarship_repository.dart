import '../models/scholarship.dart';
import 'scholarship_repository.dart';

/// MockScholarshipRepository provides deterministic scheme data matching the official 5 MoTA schemes.
/// Conforms to Playbook (Section 10 & 11) and Architecture documentation.
class MockScholarshipRepository implements ScholarshipRepository {
  final Duration latency;

  MockScholarshipRepository({this.latency = const Duration(milliseconds: 300)});

  static const List<Scholarship> _schemes = [
    Scholarship(
      id: 'scheme-pms-st-01',
      code: 'POST_MATRIC',
      name: 'Post Matric Scholarship for ST Students',
      description: 'Financial support for higher education of ST students across India.',
      ministry: 'Ministry of Tribal Affairs',
      eligible: true,
      benefitAmount: 'Upto ₹48,000',
      educationLevel: 'Post Matric',
      deadline: '31 Oct 2024',
      isPvtgSpecific: false,
      sourcePortal: 'NSP',
      isMostRelevant: true,
      statusBadge: 'Ongoing',
    ),
    Scholarship(
      id: 'scheme-top-class-02',
      code: 'TOP_CLASS',
      name: 'Top Class Education Scheme for ST Students',
      description: 'Support for pursuing professional and technical courses at top institutions.',
      ministry: 'Ministry of Education',
      eligible: true,
      benefitAmount: 'Upto ₹2,00,000',
      educationLevel: 'Top Class',
      deadline: '15 Oct 2024',
      isPvtgSpecific: false,
      sourcePortal: 'NSP',
      statusBadge: 'Closing Soon',
    ),
    Scholarship(
      id: 'scheme-nfst-03',
      code: 'NATIONAL_FELLOWSHIP_ST',
      name: 'National Fellowship for ST Students',
      description: 'Fellowship support for M.Phil and Ph.D. research programs under UGC.',
      ministry: 'Ministry of Tribal Affairs',
      eligible: true,
      benefitAmount: 'Upto ₹31,000/month',
      educationLevel: 'M.Phil / Ph.D.',
      deadline: '30 Nov 2024',
      isPvtgSpecific: false,
      sourcePortal: 'SFMP',
      statusBadge: 'Ongoing',
    ),
    Scholarship(
      id: 'scheme-pre-matric-04',
      code: 'PRE_MATRIC',
      name: 'Pre Matric Scholarship for ST Students',
      description: 'Financial assistance for class 9 and 10 students from ST communities.',
      ministry: 'Ministry of Social Justice',
      eligible: true,
      benefitAmount: 'Upto ₹6,000',
      educationLevel: 'Pre Matric',
      deadline: '15 Nov 2024',
      isPvtgSpecific: false,
      sourcePortal: 'NSP',
      statusBadge: 'Ongoing',
    ),
    Scholarship(
      id: 'scheme-medical-05',
      code: 'MEDICAL_ST',
      name: 'Scholarship for ST Students in Medical Courses',
      description: 'Support for ST students pursuing MBBS, BDS and allied medical courses.',
      ministry: 'Ministry of Health & Family Welfare',
      eligible: true,
      benefitAmount: 'Upto ₹1,00,000',
      educationLevel: 'Post Matric',
      deadline: '20 Nov 2024',
      isPvtgSpecific: false,
      sourcePortal: 'NSP',
      statusBadge: 'Ongoing',
    ),
    Scholarship(
      id: 'scheme-nos-06',
      code: 'NATIONAL_OVERSEAS',
      name: 'National Overseas Scholarship for ST Candidates',
      description: 'Financial assistance for higher studies abroad in prestigious universities.',
      ministry: 'Ministry of Tribal Affairs',
      eligible: false,
      benefitAmount: 'Full Tuition + Living',
      educationLevel: 'National Overseas',
      deadline: '31 Dec 2024',
      isPvtgSpecific: false,
      sourcePortal: 'NOS',
      statusBadge: 'Ongoing',
    ),
  ];

  @override
  Future<List<Scholarship>> getScholarships() async {
    await Future.delayed(latency);
    return _schemes;
  }

  @override
  Future<Scholarship?> getScholarshipById(String id) async {
    await Future.delayed(latency);
    try {
      return _schemes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Scholarship?> getRecommendedScholarship() async {
    await Future.delayed(latency);
    return _schemes.first; // Post Matric Scholarship for ST Students
  }
}
