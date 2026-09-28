import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/document.dart';
import 'document_repository.dart';

/// ApiDocumentRepository implements DocumentRepository by delegating to ApiClient.
/// Consumes:
/// - GET /api/v1/documents
/// - POST /api/v1/documents
/// - POST /api/v1/documents/digilocker/consent
class ApiDocumentRepository implements DocumentRepository {
  final ApiClient apiClient;

  ApiDocumentRepository({required this.apiClient});

  @override
  Future<List<DocumentItem>> getDocuments({String? category}) async {
    String endpoint = ApiConstants.documents;
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all documents') {
      endpoint = '$endpoint?category=${Uri.encodeComponent(category)}';
    }
    final response = await apiClient.get(endpoint);
    if (response.success && response.data != null) {
      final list = response.data as List<dynamic>;
      return list
          .map((item) => DocumentItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<DocumentItem> uploadDocument({
    required String docType,
    required String docName,
    required String filePath,
    String? category,
  }) async {
    final response = await apiClient.post(
      ApiConstants.documents,
      body: {
        'doc_type': docType,
        'doc_name': docName,
        'file_path': filePath,
        'category': ?category,
        'source': 'UPLOAD',
      },
    );
    if (response.success && response.data != null) {
      return DocumentItem.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception(response.message);
  }

  @override
  Future<Map<String, dynamic>> requestDigiLockerConsent() async {
    final response = await apiClient.post(ApiConstants.documentsDigiLockerConsent);
    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception(response.message);
  }
}
