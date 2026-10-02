import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/application.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/verification_controller.dart';
import '../widgets/document_verification_list_card.dart';
import '../widgets/verification_info_cards.dart';
import '../widgets/verification_page_header.dart';
import '../widgets/verification_progress_widget.dart';
import '../widgets/verification_skeleton_loader.dart';
import '../widgets/verification_summary_card.dart';

/// ApplicationVerificationScreen renders the complete "Application Verification" screen
/// strictly adhering to the visual target from the reference image.
///
/// Hierarchy & Navigation:
/// Applications -> My Applications -> Select an Application -> Application / Tracking -> Application Verification.
/// Global bottom navigation: Applications tab (index 2) is active.
class ApplicationVerificationScreen extends StatefulWidget {
  final VerificationController? controller;
  final String? applicationId;
  final Application? initialApplication;
  final String studentInitials;
  final int unreadNotificationsCount;

  const ApplicationVerificationScreen({
    super.key,
    this.controller,
    this.applicationId,
    this.initialApplication,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<ApplicationVerificationScreen> createState() => _ApplicationVerificationScreenState();
}

class _ApplicationVerificationScreenState extends State<ApplicationVerificationScreen> {
  late final VerificationController _controller;
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
          VerificationController(
            verificationRepository: ServiceLocator.instance.verificationRepository,
            applicationRepository: ServiceLocator.instance.applicationRepository,
            documentRepository: ServiceLocator.instance.documentRepository,
            applicationId: '',
          );
      return;
    }

    _controller = widget.controller ??
        VerificationController(
          verificationRepository: ServiceLocator.instance.verificationRepository,
          applicationRepository: ServiceLocator.instance.applicationRepository,
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
        appBar: AppBar(title: const Text('Application Verification')),
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

                    // Page Header with Back Navigation Arrow
                    VerificationPageHeader(
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
                      const VerificationSkeletonLoader(),
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
                      // 1. Application Metadata Summary Card
                      VerificationSummaryCard(
                        application: _controller.application,
                        onViewApplication: () {
                          final appNumber = _controller.application?.applicationNumber ?? _controller.applicationId;
                          _handleActionNotice('Viewing application details for $appNumber');
                        },
                      ),

                      const SizedBox(height: 18),

                      // 2. Verification Progress Horizontal Checkpoints
                      VerificationProgressWidget(
                        lastUpdatedAt: _controller.lastUpdatedAt,
                        timelineEvents: _controller.timelineEvents,
                      ),

                      const SizedBox(height: 18),

                      // 3. Document Verification Status List Card
                      DocumentVerificationListCard(
                        verifications: _controller.verifications,
                        getDocumentName: _controller.getDocumentName,
                        getDocumentSubtitle: _controller.getDocumentSubtitle,
                        onRowTap: (record) {
                          final docName = _controller.getDocumentName(record);
                          _handleActionNotice('$docName verification details');
                        },
                      ),

                      const SizedBox(height: 18),

                      // 4. Informational Callout Cards ("What happens next?" & "Important Information")
                      const VerificationInfoCards(),
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
}
