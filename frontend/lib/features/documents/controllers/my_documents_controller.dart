import 'package:flutter/foundation.dart';
import '../../../models/document.dart';
import '../../../repositories/document_repository.dart';

/// MyDocumentsController manages state and business logic for the Document Wallet.
/// Follows the strict Screen -> Controller -> Repository -> ApiClient pattern.
class MyDocumentsController extends ChangeNotifier {
  final DocumentRepository documentRepository;

  MyDocumentsController({required this.documentRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String? _actionFeedbackMessage;
  String? get actionFeedbackMessage => _actionFeedbackMessage;

  List<DocumentItem> _documents = [];
  List<DocumentItem> get documents => List.unmodifiable(_documents);

  String _selectedCategory = 'All Documents';
  String get selectedCategory => _selectedCategory;

  static const List<String> categories = [
    'All Documents',
    'Identity',
    'Academic',
    'Income',
    'Caste',
    'Other',
  ];

  /// Returns documents filtered by the selected category tab.
  List<DocumentItem> get filteredDocuments {
    if (_selectedCategory == 'All Documents') {
      return List.unmodifiable(_documents);
    }
    return List.unmodifiable(
      _documents.where((d) => d.categoryDisplay.toLowerCase() == _selectedCategory.toLowerCase()),
    );
  }

  /// Initial load or reload of all wallet documents.
  Future<void> loadDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await documentRepository.getDocuments();
      _documents = items;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Changes the category filter pill.
  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  /// Initiates DigiLocker consent linking.
  Future<bool> fetchFromDigiLocker() async {
    _isActionLoading = true;
    _actionFeedbackMessage = null;
    notifyListeners();

    try {
      final result = await documentRepository.requestDigiLockerConsent();
      _isActionLoading = false;
      _actionFeedbackMessage = result['message'] as String? ?? 'DigiLocker sync initiated.';
      notifyListeners();
      return true;
    } catch (e) {
      _isActionLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Uploads a document file and prepends/appends to wallet.
  Future<bool> uploadDocument({
    required String docType,
    required String docName,
    required String filePath,
    String? category,
  }) async {
    _isActionLoading = true;
    _actionFeedbackMessage = null;
    notifyListeners();

    try {
      final newDoc = await documentRepository.uploadDocument(
        docType: docType,
        docName: docName,
        filePath: filePath,
        category: category,
      );
      _documents = [..._documents, newDoc];
      _isActionLoading = false;
      _actionFeedbackMessage = '${newDoc.docName} uploaded successfully.';
      notifyListeners();
      return true;
    } catch (e) {
      _isActionLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Clears any transient feedback notification.
  void clearActionFeedback() {
    _actionFeedbackMessage = null;
    notifyListeners();
  }

  /// Pull-to-refresh hook.
  Future<void> refresh() => loadDocuments();
}
