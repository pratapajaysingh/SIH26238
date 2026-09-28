import '../models/scholarship.dart';

/// ScholarshipRepository defines the contract for accessing the scholarship catalogue.
/// Conforms to documented endpoint:
/// - GET /api/v1/scholarships
abstract class ScholarshipRepository {
  /// Fetches the list of scholarships.
  Future<List<Scholarship>> getScholarships();

  /// Fetches a specific scholarship by ID.
  Future<Scholarship?> getScholarshipById(String id);

  /// Fetches the most relevant / recommended scholarship for the student dashboard.
  Future<Scholarship?> getRecommendedScholarship();
}
