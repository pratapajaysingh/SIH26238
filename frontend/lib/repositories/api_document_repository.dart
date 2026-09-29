import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/document.dart';
import 'document_repository.dart';

/// ApiDocumentRepository implements DocumentRepository by delegating to ApiClient.
/// Consumes:
/// - GET /api/v1/documents
/// - POST /api/v1/documents
/// - Mock DigiLocker routes on backend
class ApiDocumentRepository implements DocumentRepository {
  final ApiClient apiClient;

  ApiDocumentRepository({required this.apiClient});

  @override
  Future<List<DocumentItem>> getDocuments({String? category}) async {
    final response = await apiClient.get<List<dynamic>>(ApiConstants.documents);
    if (response.success && response.data != null) {
      final list = response.data!
          .map((item) => DocumentItem.fromJson(item as Map<String, dynamic>))
          .toList();
      if (category != null && category.isNotEmpty && category.toLowerCase() != 'all documents') {
        return list.where((d) => d.categoryDisplay.toLowerCase() == category.toLowerCase()).toList();
      }
      return list;
    }
    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to retrieve documents',
    );
  }

  @override
  Future<DocumentItem> uploadDocument({
    required String docType,
    required String docName,
    required String filePath,
    String? category,
    String? studentId,
  }) async {
    String sId = studentId ?? '';
    if (sId.isEmpty) {
      try {
        final sRes = await apiClient.get<Map<String, dynamic>>(ApiConstants.studentsMe);
        if (sRes.success && sRes.data != null && sRes.data!['id'] != null) {
          sId = sRes.data!['id'].toString();
        }
      } catch (_) {}
    }
    if (sId.isEmpty) {
      sId = '00000000-0000-0000-0000-000000000002';
    }

    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.documents,
      body: {
        'student_id': sId,
        'document_type': docType,
        'document_name': docName,
      },
    );
    if (response.success && response.data != null) {
      return DocumentItem.fromJson(response.data!);
    }
    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to upload document',
    );
  }

  @override
  Future<Map<String, dynamic>> requestDigiLockerConsent() async {
    // Prototype mock DigiLocker consent handled locally without calling nonexistent consent route
    return {
      'status': 'AUTHORIZED',
      'message': 'DigiLocker consent granted (Prototype Simulation Mode)',
    };
  }

  /// Lists mock DigiLocker documents for student from backend:
  /// GET /api/v1/students/{student_id}/digilocker/documents
  Future<List<Map<String, dynamic>>> getDigiLockerDocuments(String studentId) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.studentDigiLockerDocuments(studentId),
    );
    if (response.success && response.data != null) {
      return response.data!.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Imports a mock DigiLocker document into the student's wallet via backend:
  /// POST /api/v1/students/{student_id}/digilocker/documents/import
  Future<DocumentItem> importDigiLockerDocument({
    required String studentId,
    required String documentType,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.studentDigiLockerImport(studentId),
      body: {'document_type': documentType},
    );
    if (response.success && response.data != null) {
      return DocumentItem.fromJson(response.data!);
    }
    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to import DigiLocker document',
    );
  }
}
