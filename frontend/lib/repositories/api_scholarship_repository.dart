import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/scholarship.dart';
import 'scholarship_repository.dart';

/// ApiScholarshipRepository implements ScholarshipRepository by consuming GET /api/v1/scholarships.
class ApiScholarshipRepository implements ScholarshipRepository {
  final ApiClient apiClient;

  ApiScholarshipRepository({required this.apiClient});

  @override
  Future<List<Scholarship>> getScholarships() async {
    final response = await apiClient.get<List<dynamic>>(ApiConstants.scholarships);
    if (response.success && response.data != null) {
      final list = response.data!;
      return list
          .map((item) => Scholarship.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to retrieve scholarships',
    );
  }

  @override
  Future<Scholarship?> getScholarshipById(String id) async {
    final scholarships = await getScholarships();
    try {
      return scholarships.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Scholarship?> getRecommendedScholarship() async {
    final scholarships = await getScholarships();
    if (scholarships.isEmpty) return null;
    return scholarships.firstWhere((s) => s.eligible, orElse: () => scholarships.first);
  }
}
