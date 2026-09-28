import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/document.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/my_documents_controller.dart';
import '../widgets/document_action_cards.dart';
import '../widgets/document_category_tabs.dart';
import '../widgets/document_empty_state.dart';
import '../widgets/document_important_info_card.dart';
import '../widgets/document_skeleton_loader.dart';
import '../widgets/document_wallet_card_item.dart';
import '../widgets/my_documents_page_header.dart';

/// MyDocumentsScreen renders the student's reusable Document Wallet screen.
/// Follows the visual reference image with:
/// - Top full-bleed curved tribal decoration
/// - Government of India branding header with notification badge and user avatar
/// - Page header with back button, "My Documents" title, and description
/// - 3 Top quick action cards (Upload Document, Fetch from DigiLocker, Supported Formats)
/// - Capsule category filter tabs ([ All Documents | Identity | Academic | Income | Caste | Other ])
/// - Document wallet cards list with verified/pending/rejected chips, issue dates, and source badges
/// - Important Information bottom callout card
/// - Fixed bottom navigation bar with Profile tab active (Tab 3)
class MyDocumentsScreen extends StatefulWidget {
  final MyDocumentsController? controller;
  final String studentInitials;
  final int unreadNotificationsCount;

  const MyDocumentsScreen({
    super.key,
    this.controller,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  late final MyDocumentsController _controller;
  final ScrollController _scrollController = ScrollController();
  final int _currentNavIndex = 3; // Profile Tab Active

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        MyDocumentsController(
          documentRepository: ServiceLocator.instance.documentRepository,
        );
    _controller.addListener(_onControllerUpdate);
    _controller.loadDocuments();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onControllerUpdate);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _showNotice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleUploadDocument() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        String docType = 'OTHER';
        String docName = '';
        String category = 'Other';

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upload Document',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: docType,
                    decoration: InputDecoration(
                      labelText: 'Document Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'OTHER', child: Text('Other Certificate')),
                      DropdownMenuItem(value: 'AADHAAR', child: Text('Aadhaar / Identity Proof')),
                      DropdownMenuItem(value: 'MARK_SHEET_10', child: Text('10th Mark Sheet')),
                      DropdownMenuItem(value: 'MARK_SHEET_12', child: Text('12th Mark Sheet')),
                      DropdownMenuItem(value: 'INCOME_CERTIFICATE', child: Text('Income Certificate')),
                      DropdownMenuItem(value: 'ST_CERTIFICATE', child: Text('Caste Certificate (ST)')),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        docType = val ?? 'OTHER';
                        if (docType == 'AADHAAR') {
                          docName = 'Aadhaar Card';
                          category = 'Identity';
                        } else if (docType.contains('MARK_SHEET')) {
                          docName = docType == 'MARK_SHEET_10' ? '10th Mark Sheet' : '12th Mark Sheet';
                          category = 'Academic';
                        } else if (docType == 'INCOME_CERTIFICATE') {
                          docName = 'Income Certificate';
                          category = 'Income';
                        } else if (docType == 'ST_CERTIFICATE') {
                          docName = 'Caste Certificate';
                          category = 'Caste';
                        } else {
                          docName = 'Document';
                          category = 'Other';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: docName,
                    decoration: InputDecoration(
                      labelText: 'Document Name',
                      hintText: 'e.g. Domicile Certificate',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (val) => docName = val,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(modalContext);
                      final resolvedName = docName.trim().isEmpty ? 'Uploaded Document' : docName.trim();
                      final success = await _controller.uploadDocument(
                        docType: docType,
                        docName: resolvedName,
                        filePath: 'https://tribalsetu.gov.in/storage/$resolvedName.pdf',
                        category: category,
                      );
                      if (success) {
                        _showNotice('Document "$resolvedName" uploaded successfully.');
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 18),
                    label: const Text('Choose File & Upload', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleDigiLockerFetch() async {
    final success = await _controller.fetchFromDigiLocker();
    if (success) {
      _showNotice('DigiLocker integration active. Verified documents are synced.');
    }
  }

  void _handleSupportedFormats() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Supported Document Formats',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFormatRow('PDF (.pdf)', 'Ideal for official certificates and mark sheets'),
              const SizedBox(height: 8),
              _buildFormatRow('JPG / JPEG (.jpg, .jpeg)', 'Scanned photographs or clear camera captures'),
              const SizedBox(height: 8),
              _buildFormatRow('PNG (.png)', 'High-resolution images without loss of detail'),
              const SizedBox(height: 12),
              const Text(
                'Maximum file size per document is 5 MB. All files are encrypted at rest.',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormatRow(String format, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF16A34A)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                format,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleViewDocument(DocumentItem doc) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      doc.docName,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildDetailRow('Category', doc.categorySubtitle),
              _buildDetailRow('Verification Status', doc.status.label),
              _buildDetailRow('Source System', doc.sourceDisplay),
              _buildDetailRow('Issued By', doc.issuedBy),
              _buildDetailRow('Date of Issue', doc.formattedIssuedDate),
              if (doc.docUri != null) _buildDetailRow('URI', doc.docUri!),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showNotice('Document is ready for viewing');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDocumentOptions(DocumentItem doc) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility_outlined, color: Color(0xFF1E293B)),
                title: const Text('View Document Details'),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleViewDocument(doc);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined, color: Color(0xFF1E293B)),
                title: const Text('Download Offline Copy'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showNotice('Downloading ${doc.docName}...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Color(0xFF1E293B)),
                title: const Text('Share Reference'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showNotice('Sharing link copied');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPatternWidth = screenWidth * 0.72;
    final topPatternHeight = topPatternWidth * (180 / 280);
    final filteredDocs = _controller.filteredDocuments;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top Decorative Tribal Curve (Full Bleed to Top & Right Edges)
          Positioned(
            top: 0,
            right: 0,
            width: topPatternWidth,
            height: topPatternHeight,
            child: IgnorePointer(
              child: Image.asset(
                AssetConstants.topTribalPattern,
                fit: BoxFit.fill,
                alignment: Alignment.topRight,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. Main Foreground Scrollable Content
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _controller.refresh,
              color: const Color(0xFF111827),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),

                    // Top Branding Header
                    DashboardHeader(
                      initials: widget.studentInitials,
                      unreadNotificationsCount: widget.unreadNotificationsCount,
                      onNotificationTap: () => Navigator.of(context).pushNamed('/notifications'),
                      onProfileTap: () {},
                    ),

                    const SizedBox(height: 12),

                    // Page Header (Back Arrow + Title + Subtitle)
                    MyDocumentsPageHeader(
                      onBackTap: () => Navigator.of(context).maybePop(),
                    ),

                    const SizedBox(height: 14),

                    // Three Top Action Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DocumentActionCards(
                        onUploadTap: _handleUploadDocument,
                        onDigiLockerTap: _handleDigiLockerFetch,
                        onFormatsTap: _handleSupportedFormats,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Category Filter Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DocumentCategoryTabs(
                        categories: MyDocumentsController.categories,
                        selectedCategory: _controller.selectedCategory,
                        onCategorySelected: _controller.selectCategory,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Document List Cards or Loading / Error / Empty State
                    if (_controller.isLoading) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: DocumentSkeletonLoader(),
                      ),
                    ] else if (_controller.errorMessage != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 40,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _controller.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: _controller.loadDocuments,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF111827),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ] else if (filteredDocs.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DocumentEmptyState(
                          category: _controller.selectedCategory,
                          onResetFilter: () => _controller.selectCategory('All Documents'),
                        ),
                      ),
                    ] else ...[
                      // List of Documents
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: filteredDocs.map((doc) {
                            return DocumentWalletCardItem(
                              document: doc,
                              onViewTap: _handleViewDocument,
                              onMoreTap: _handleDocumentOptions,
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 4),

                    // Important Information Card
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: DocumentImportantInfoCard(),
                    ),

                    // Clearance padding before fixed bottom navigation bar
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. Fixed Bottom Navigation Bar (Tab 3 "Profile" Active)
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/scholarships');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/applications');
          } else if (index == 3) {
            // Already in Profile area; if back is possible, pop, otherwise scroll to top
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          } else if (index == 4) {
            Navigator.of(context).pushNamed('/jago');
          }
        },
        onJagoTap: () => Navigator.of(context).pushNamed('/jago'),
      ),
    );
  }
}
