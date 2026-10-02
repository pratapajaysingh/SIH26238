import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/application.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/application_details_controller.dart';
import '../widgets/application_details_page_header.dart';
import '../widgets/application_details_skeleton_loader.dart';
import '../widgets/application_jago_help_banner.dart';
import '../widgets/application_overview_card.dart';
import '../widgets/application_payment_status_card.dart';
import '../widgets/application_progress_stepper.dart';
import '../widgets/application_section_tabs.dart';
import '../widgets/application_submitted_documents_card.dart';
import '../widgets/application_verification_status_card.dart';

/// ApplicationDetailsScreen faithfully renders the "Application Details" screen
/// strictly adhering to the visual target from the reference image and API contract.
///
/// Hierarchy & Navigation:
/// Home -> Applications -> My Applications -> Tap an Application Card -> Application Details.
/// Global bottom navigation: Applications tab (index 2) is active.
class ApplicationDetailsScreen extends StatefulWidget {
  final ApplicationDetailsController? controller;
  final String? applicationId;
  final Application? initialApplication;
  final String studentInitials;
  final int unreadNotificationsCount;

  const ApplicationDetailsScreen({
    super.key,
    this.controller,
    this.applicationId,
    this.initialApplication,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<ApplicationDetailsScreen> createState() => _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  late final ApplicationDetailsController _controller;
  final ScrollController _scrollController = ScrollController();
  final int _currentNavIndex = 2; // Applications Tab Active

  @override
  void initState() {
    super.initState();
    final String? resolvedId = widget.applicationId ?? widget.initialApplication?.id;
    final String? targetId = resolvedId ?? (ServiceLocator.useMock ? 'app-2024-st-01' : null);

    if (targetId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/applications');
        }
      });
      _controller = widget.controller ??
          ApplicationDetailsController(
            applicationRepository: ServiceLocator.instance.applicationRepository,
            verificationRepository: ServiceLocator.instance.verificationRepository,
            paymentRepository: ServiceLocator.instance.paymentRepository,
            documentRepository: ServiceLocator.instance.documentRepository,
            applicationId: '',
          );
      return;
    }

    _controller = widget.controller ??
        ApplicationDetailsController(
          applicationRepository: ServiceLocator.instance.applicationRepository,
          verificationRepository: ServiceLocator.instance.verificationRepository,
          paymentRepository: ServiceLocator.instance.paymentRepository,
          documentRepository: ServiceLocator.instance.documentRepository,
          applicationId: targetId,
          initialApplication: widget.initialApplication,
        );

    _controller.addListener(_onControllerUpdate);
    _controller.loadData(initialApplication: widget.initialApplication);
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

  void _handleActionNotice(String message) {
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

  @override
  Widget build(BuildContext context) {
    final String? resolvedId = widget.applicationId ?? widget.initialApplication?.id;
    if (resolvedId == null && !ServiceLocator.useMock) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 16),
              const Text('No Application Selected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Please select an application from My Applications.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/applications'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111827)),
                child: const Text('Go to My Applications', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final topPatternWidth = screenWidth * 0.72;
    final topPatternHeight = topPatternWidth * (180 / 280);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-bleed decorative tribal pattern in top-right
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
                      onProfileTap: () => Navigator.of(context).pushNamed('/profile'),
                    ),

                    const SizedBox(height: 14),

                    // Page Navigation Header with Back Arrow
                    ApplicationDetailsPageHeader(
                      onBack: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/applications');
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Loading State
                    if (_controller.isLoading) ...[
                      const ApplicationDetailsSkeletonLoader(),
                    ]
                    // Error State
                    else if (_controller.errorMessage != null) ...[
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
                              onPressed: _controller.loadData,
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
                    ]
                    // Main Content
                    else ...[
                      // 1. Application Overview Card
                      ApplicationOverviewCard(
                        application: _controller.application,
                      ),

                      const SizedBox(height: 16),

                      // 2. Application Progress Stepper (5 stages)
                      ApplicationProgressStepper(
                        timelineEvents: _controller.timelineEvents,
                        submittedAt: _controller.application?.submittedAt,
                        currentStage: _controller.application?.currentStage,
                      ),

                      const SizedBox(height: 16),

                      // 3. Segmented Section Tabs
                      ApplicationSectionTabs(
                        selectedTab: _controller.selectedTab,
                        onTabSelected: _controller.setTab,
                      ),

                      const SizedBox(height: 16),

                      // 4. Tab Content
                      _buildTabContent(),
                    ],

                    // Clearance padding before fixed bottom navigation bar
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. Fixed Global Bottom Navigation Bar (Applications Tab Active)
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/scholarships');
          } else if (index == 2) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/applications');
            }
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          } else if (index == 4) {
            Navigator.of(context).pushNamed('/jago');
          }
        },
        onJagoTap: () => Navigator.of(context).pushNamed('/jago'),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_controller.selectedTab) {
      case ApplicationDetailsTab.overview:
        return Column(
          children: [
            // Deficiencies Notice
            if (_controller.deficiencies.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Action Required (${_controller.deficiencies.length} Deficienc${_controller.deficiencies.length > 1 ? "ies" : "y"})',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final def in _controller.deficiencies)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                '${def.documentName != null ? "${def.documentName}: " : ""}${def.message}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Verification Status Section Card
            ApplicationVerificationStatusCard(
              onViewAll: () {
                Navigator.of(context).pushNamed(
                  '/verification',
                  arguments: _controller.application,
                );
              },
            ),

            const SizedBox(height: 14),

            // Payment / DBT Status Card
            ApplicationPaymentStatusCard(
              payment: _controller.primaryPayment,
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/payment-status',
                  arguments: _controller.application,
                );
              },
            ),

            const SizedBox(height: 14),

            // Submitted Documents Section Card
            ApplicationSubmittedDocumentsCard(
              onViewAll: () {
                _controller.setTab(ApplicationDetailsTab.documents);
              },
              onDocumentTap: (title) {
                _handleActionNotice('$title details');
              },
            ),

            const SizedBox(height: 14),

            // Ask JAGO Help Banner
            ApplicationJagoHelpBanner(
              onAskJago: () {
                Navigator.of(context).pushNamed('/jago');
              },
            ),
          ],
        );

      case ApplicationDetailsTab.documents:
        return _buildDocumentsTab();

      case ApplicationDetailsTab.timeline:
        return _buildTimelineTab();

      case ApplicationDetailsTab.payments:
        return _buildPaymentsTab();
    }
  }

  Widget _buildDocumentsTab() {
    final docs = _controller.documents;
    if (docs.isEmpty) {
      return _buildEmptySection(
        icon: Icons.description_outlined,
        title: 'No Documents Found',
        subtitle: 'No documents attached to this application.',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attached Documents',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Verified documents submitted with this scholarship application.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: docs.length,
              separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.article_outlined, size: 18, color: Color(0xFF374151)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.docName,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doc.issuedBy,
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        doc.status.label,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTab() {
    final events = _controller.timelineEvents;
    if (events.isEmpty) {
      return _buildEmptySection(
        icon: Icons.timeline_rounded,
        title: 'No Timeline Events',
        subtitle: 'No timeline events recorded for this application.',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application History',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Complete audit trail of stages and status transitions.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: events.length,
              separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final evt = events[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: evt.isCompleted
                            ? const Color(0xFF16A34A)
                            : (evt.isInProgress ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB)),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        evt.isCompleted ? Icons.check_rounded : Icons.circle,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evt.title,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                          ),
                          if (evt.description != null && evt.description!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              evt.description!,
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      evt.date != null ? DateFormatter.formatDate(evt.date) : evt.dateFormatted,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    final payment = _controller.primaryPayment;
    final amount = _controller.application?.amountSanctioned ?? payment?.amount ?? 48000.0;
    final statusLabel = _controller.getPaymentStatusLabel(payment?.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disbursement Ledger',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Direct Benefit Transfer and scholarship fund sanction record.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Sanctioned Amount',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'DBT Status',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                        ),
                      ),
                    ],
                  ),
                  if (payment?.bankName != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bank Account',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${payment!.bankName} (${payment.maskedAccountNumber ?? 'XXXX'})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/payment-status',
                    arguments: _controller.application,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'View Detailed Payment & DBT Status',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Color(0xFF111827),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
