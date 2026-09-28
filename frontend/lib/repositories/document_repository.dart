import '../models/document.dart';

/// DocumentRepository defines the contract for fetching and managing student documents.
/// Conforms to documented endpoints:
/// - GET /api/v1/documents
/// - POST /api/v1/documents
/// - POST /api/v1/documents/digilocker/consent
abstract class DocumentRepository {
  /// Fetches all documents associated with the authenticated student, optionally filtered by category.
  Future<List<DocumentItem>> getDocuments({String? category});

  /// Uploads or registers a new document reference from the device.
  Future<DocumentItem> uploadDocument({
    required String docType,
    required String docName,
    required String filePath,
    String? category,
  });

  /// Initiates DigiLocker OAuth / consent linking flow to import verified documents.
  Future<Map<String, dynamic>> requestDigiLockerConsent();
}
