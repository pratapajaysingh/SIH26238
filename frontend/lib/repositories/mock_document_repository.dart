import '../core/enums/document_status.dart';
import '../models/document.dart';
import 'document_repository.dart';

/// MockDocumentRepository provides deterministic mock document data matching the reference image.
/// Conforms to GET /api/v1/documents, POST /api/v1/documents, and POST /api/v1/documents/digilocker/consent.
class MockDocumentRepository implements DocumentRepository {
  final Duration latency;
  final List<DocumentItem>? initialDocuments;

  MockDocumentRepository({
    this.latency = const Duration(milliseconds: 300),
    this.initialDocuments,
  }) {
    if (initialDocuments != null) {
      _documents = List<DocumentItem>.from(initialDocuments!);
    } else {
      _documents = List<DocumentItem>.from(_canonicalDocuments);
    }
  }

  late final List<DocumentItem> _documents;

  /// Canonical 6 documents in exact visual order of the reference image:
  /// 1. Aadhaar Card (Identity, Verified, Issued on 12 Jan 2020, DigiLocker)
  /// 2. 10th Mark Sheet (Academic, Verified, Issued on 20 May 2018, DigiLocker)
  /// 3. 12th Mark Sheet (Academic, Verified, Issued on 15 May 2020, DigiLocker)
  /// 4. Income Certificate (Income, Pending, Issued on 10 Mar 2024, Uploaded)
  /// 5. Caste Certificate (Caste, Verified, Issued on 05 Feb 2021, DigiLocker)
  /// 6. Domicile Certificate (Other, Rejected, Issued on 18 Jun 2023, Uploaded)
  static final List<DocumentItem> _canonicalDocuments = [
    DocumentItem(
      id: 'doc-01',
      studentId: 'TS2024S10023',
      docType: 'AADHAAR',
      docName: 'Aadhaar Card',
      category: 'Identity',
      source: 'DIGILOCKER',
      status: DocumentStatus.verified,
      issuedBy: 'UIDAI',
      issuedAt: DateTime(2020, 1, 12),
      verifiedAt: DateTime(2024, 8, 15),
      docUri: 'https://digilocker.gov.in/doc/aadhaar',
    ),
    DocumentItem(
      id: 'doc-10',
      studentId: 'TS2024S10023',
      docType: 'MARK_SHEET_10',
      docName: '10th Mark Sheet',
      category: 'Academic',
      source: 'DIGILOCKER',
      status: DocumentStatus.verified,
      issuedBy: 'State Education Board',
      issuedAt: DateTime(2018, 5, 20),
      verifiedAt: DateTime(2024, 8, 15),
      docUri: 'https://digilocker.gov.in/doc/10th',
    ),
    DocumentItem(
      id: 'doc-12',
      studentId: 'TS2024S10023',
      docType: 'MARK_SHEET_12',
      docName: '12th Mark Sheet',
      category: 'Academic',
      source: 'DIGILOCKER',
      status: DocumentStatus.verified,
      issuedBy: 'Central Board of Secondary Education',
      issuedAt: DateTime(2020, 5, 15),
      verifiedAt: DateTime(2024, 8, 15),
      docUri: 'https://digilocker.gov.in/doc/12th',
    ),
    DocumentItem(
      id: 'doc-03',
      studentId: 'TS2024S10023',
      docType: 'INCOME_CERTIFICATE',
      docName: 'Income Certificate',
      category: 'Income',
      source: 'UPLOAD',
      status: DocumentStatus.pending,
      issuedBy: 'Tehsildar Office, Surguja',
      issuedAt: DateTime(2024, 3, 10),
      verifiedAt: null,
      docUri: 'https://tribalsetu.gov.in/storage/doc-income.pdf',
    ),
    DocumentItem(
      id: 'doc-02',
      studentId: 'TS2024S10023',
      docType: 'ST_CERTIFICATE',
      docName: 'Caste Certificate',
      category: 'Caste',
      source: 'DIGILOCKER',
      status: DocumentStatus.verified,
      issuedBy: 'Revenue Department, Govt of Chhattisgarh',
      issuedAt: DateTime(2021, 2, 5),
      verifiedAt: DateTime(2024, 8, 16),
      docUri: 'https://edistrict.cg.gov.in/doc/caste',
    ),
    DocumentItem(
      id: 'doc-06',
      studentId: 'TS2024S10023',
      docType: 'DOMICILE_CERTIFICATE',
      docName: 'Domicile Certificate',
      category: 'Other',
      source: 'UPLOAD',
      status: DocumentStatus.rejected,
      issuedBy: 'Sub-Divisional Magistrate, Ambikapur',
      issuedAt: DateTime(2023, 6, 18),
      verifiedAt: null,
      docUri: 'https://tribalsetu.gov.in/storage/doc-domicile.pdf',
    ),
  ];

  @override
  Future<List<DocumentItem>> getDocuments({String? category}) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (category == null || category.isEmpty || category.toLowerCase() == 'all documents') {
      return List<DocumentItem>.from(_documents);
    }
    return _documents
        .where((d) => d.categoryDisplay.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<DocumentItem> uploadDocument({
    required String docType,
    required String docName,
    required String filePath,
    String? category,
  }) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    final newDoc = DocumentItem(
      id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
      studentId: 'TS2024S10023',
      docType: docType,
      docName: docName,
      category: category ?? 'Other',
      source: 'UPLOAD',
      status: DocumentStatus.pending,
      issuedBy: 'Self Uploaded',
      issuedAt: DateTime.now(),
      verifiedAt: null,
      docUri: filePath,
    );
    _documents.add(newDoc);
    return newDoc;
  }

  @override
  Future<Map<String, dynamic>> requestDigiLockerConsent() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    return {
      'success': true,
      'authUrl': 'https://digilocker.meripehchan.gov.in/oauth2/1/authorize',
      'state': 'ts_dl_consent_active',
      'message': 'DigiLocker consent flow initiated successfully',
    };
  }
}
