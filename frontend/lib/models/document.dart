import '../core/enums/document_status.dart';
import '../core/utils/date_formatter.dart';

/// DocumentItem represents a verified/reusable document in the student's Document Wallet.
/// Conforms to GET /api/v1/documents and the authoritative schema.
class DocumentItem {
  final String id;
  final String? studentId;
  final String docType; // ST_CERTIFICATE, INCOME_CERTIFICATE, MARK_SHEET, AADHAAR, etc.
  final String docName;
  final String? category; // Identity, Academic, Income, Caste, Other
  final String source; // DIGILOCKER, STATE_EDISTRICT, APAAR, UPLOAD
  final DocumentStatus status;
  final String issuedBy;
  final String? externalDocumentId;
  final String? storageReference;
  final DateTime? verifiedAt;
  final DateTime? issuedAt;
  final DateTime? expiryAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? docUri;

  const DocumentItem({
    required this.id,
    this.studentId,
    required this.docType,
    required this.docName,
    this.category,
    required this.source,
    required this.status,
    required this.issuedBy,
    this.externalDocumentId,
    this.storageReference,
    this.verifiedAt,
    this.issuedAt,
    this.expiryAt,
    this.createdAt,
    this.updatedAt,
    this.docUri,
  });

  // Backward compatible aliases
  DocumentStatus get verificationStatus => status;
  String get documentType => docType;
  String get documentName => docName;

  /// Resolves the canonical presentation category (Identity, Academic, Income, Caste, Other).
  String get categoryDisplay {
    if (category != null && category!.trim().isNotEmpty) {
      return category!.trim();
    }
    final upperType = docType.toUpperCase();
    final upperName = docName.toUpperCase();
    if (upperType.contains('AADHAAR') || upperType.contains('IDENTITY') || upperName.contains('AADHAAR')) {
      return 'Identity';
    }
    if (upperType.contains('MARK_SHEET') || upperType.contains('ACADEMIC') || upperName.contains('MARK SHEET') || upperName.contains('MARKSHEET')) {
      return 'Academic';
    }
    if (upperType.contains('INCOME') || upperName.contains('INCOME')) {
      return 'Income';
    }
    if (upperType.contains('CASTE') || upperType.contains('ST_') || upperName.contains('CASTE')) {
      return 'Caste';
    }
    return 'Other';
  }

  /// Resolves the subtitle displayed under the document title (e.g. "Identity Document").
  String get categorySubtitle => '$categoryDisplay Document';

  /// True if sourced through DigiLocker.
  bool get isDigiLockerSource => source.toUpperCase().contains('DIGILOCKER');

  /// Human-readable source label (e.g. "DigiLocker", "Uploaded").
  String get sourceDisplay {
    if (isDigiLockerSource) return 'DigiLocker';
    if (source.toUpperCase().contains('UPLOAD')) return 'Uploaded';
    if (source.toUpperCase().contains('STATE') || source.toUpperCase().contains('EDISTRICT')) {
      return 'State e-District';
    }
    return source;
  }

  /// Formatted issue date string: "Issued on 12 Jan 2020".
  String get formattedIssuedDate {
    if (issuedAt != null) {
      return 'Issued on ${DateFormatter.formatDate(issuedAt)}';
    }
    return 'Issued date unavailable';
  }

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] as String,
      studentId: json['student_id'] as String?,
      docType: (json['doc_type'] ?? json['document_type']) as String? ?? 'OTHER',
      docName: (json['doc_name'] ?? json['document_name']) as String? ?? 'Document',
      category: json['category'] as String?,
      source: json['source'] as String? ?? 'DIGILOCKER',
      status: DocumentStatus.fromString((json['status'] ?? json['verification_status']) as String? ?? 'PENDING'),
      issuedBy: (json['issued_by'] ?? json['issuedBy']) as String? ?? 'Government Authority',
      externalDocumentId: json['external_document_id'] as String?,
      storageReference: json['storage_reference'] as String?,
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at'] as String) : null,
      issuedAt: json['issued_at'] != null ? DateTime.tryParse(json['issued_at'] as String) : null,
      expiryAt: json['expiry_at'] != null ? DateTime.tryParse(json['expiry_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      docUri: (json['doc_uri'] ?? json['docUri']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'doc_type': docType,
      'doc_name': docName,
      'category': category,
      'source': source,
      'status': status.value,
      'issued_by': issuedBy,
      'external_document_id': externalDocumentId,
      'storage_reference': storageReference,
      'verified_at': verifiedAt?.toIso8601String(),
      'issued_at': issuedAt?.toIso8601String(),
      'expiry_at': expiryAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'doc_uri': docUri,
    };
  }
}
