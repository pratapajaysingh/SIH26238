import 'package:flutter/foundation.dart';
import '../../../models/scholarship.dart';
import '../../../repositories/scholarship_repository.dart';

/// ScholarshipsController manages search, category filtering, sorting,
/// and data-fetching for the Find Scholarships discovery screen.
/// Follows documented architecture: UI -> Controller -> Repository -> ApiClient.
class ScholarshipsController extends ChangeNotifier {
  final ScholarshipRepository scholarshipRepository;

  bool _isLoading = true;
  String? _errorMessage;

  List<Scholarship> _allScholarships = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedSort = 'Most Relevant';

  static const List<String> categories = [
    'All',
    'Post Matric',
    'Pre Matric',
    'Top Class',
    'National Fellowship',
    'National Overseas',
  ];

  static const List<String> sortOptions = [
    'Most Relevant',
    'Name (A-Z)',
    'Deadline',
  ];

  ScholarshipsController({required this.scholarshipRepository});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedSort => _selectedSort;
  List<Scholarship> get allScholarships => List.unmodifiable(_allScholarships);

  /// Returns the presentation-filtered and sorted list of scholarships
  List<Scholarship> get filteredScholarships {
    List<Scholarship> list = List.from(_allScholarships);

    // 1. Category Filter
    if (_selectedCategory != 'All') {
      final categoryLower = _selectedCategory.toLowerCase();
      list = list.where((s) {
        final levelLower = s.educationLevel.toLowerCase();
        final codeLower = s.code.toLowerCase();
        final nameLower = s.name.toLowerCase();

        if (categoryLower == 'post matric') {
          return levelLower.contains('post matric') || codeLower.contains('post_matric');
        } else if (categoryLower == 'pre matric') {
          return levelLower.contains('pre matric') || codeLower.contains('pre_matric');
        } else if (categoryLower == 'top class') {
          return levelLower.contains('top class') || codeLower.contains('top_class');
        } else if (categoryLower == 'national fellowship') {
          return levelLower.contains('fellowship') || codeLower.contains('fellowship');
        } else if (categoryLower == 'national overseas') {
          return levelLower.contains('overseas') || codeLower.contains('overseas');
        }
        return nameLower.contains(categoryLower);
      }).toList();
    }

    // 2. Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final queryLower = _searchQuery.trim().toLowerCase();
      list = list.where((s) {
        return s.name.toLowerCase().contains(queryLower) ||
            s.description.toLowerCase().contains(queryLower) ||
            s.ministry.toLowerCase().contains(queryLower) ||
            s.educationLevel.toLowerCase().contains(queryLower) ||
            s.benefitAmount.toLowerCase().contains(queryLower);
      }).toList();
    }

    // 3. Presentation Sort
    if (_selectedSort == 'Most Relevant') {
      list.sort((a, b) {
        if (a.isMostRelevant && !b.isMostRelevant) return -1;
        if (!a.isMostRelevant && b.isMostRelevant) return 1;
        return 0;
      });
    } else if (_selectedSort == 'Name (A-Z)') {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else if (_selectedSort == 'Deadline') {
      list.sort((a, b) => a.deadline.compareTo(b.deadline));
    }

    return list;
  }

  /// Dynamic result count
  int get resultCount => filteredScholarships.length;

  /// Loads scholarship catalogue from repository
  Future<void> loadScholarships() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allScholarships = await scholarshipRepository.getScholarships();
    } catch (e) {
      _errorMessage = 'Unable to load scholarships. Please check your connection and try again.';
      debugPrint('Error loading scholarships: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSort(String sort) {
    if (_selectedSort == sort) return;
    _selectedSort = sort;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _selectedSort = 'Most Relevant';
    notifyListeners();
  }

  Future<void> refresh() => loadScholarships();
}
