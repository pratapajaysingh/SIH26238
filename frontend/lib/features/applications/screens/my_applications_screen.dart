import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/applications_controller.dart';
import '../widgets/application_card_item.dart';
import '../widgets/application_skeleton_card.dart';
import '../widgets/applications_filter_bar.dart';
import '../widgets/applications_page_header.dart';

/// MyApplicationsScreen faithfully renders the "My Applications" screen
/// matching the exact visual target from the reference image.
/// Features:
/// - Full-bleed top decorative tribal pattern
/// - MoTA emblem, TribalSetu logo, notification bell, student avatar AS header
/// - Back navigation, page title, subtitle
/// - 4-segment capsule filter bar: All | In Progress | Under Review | Completed
/// - 5 detailed application cards with left pastel emblem badge, metadata, and 4-step horizontal milestone tracker
/// - Fixed bottom navigation bar with "Applications" (Tab 2) active
class MyApplicationsScreen extends StatefulWidget {
  final ApplicationsController? controller;
  final String studentInitials;
  final int unreadNotificationsCount;

  const MyApplicationsScreen({
    super.key,
    this.controller,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late final ApplicationsController _controller;
  final ScrollController _scrollController = ScrollController();
  final int _currentNavIndex = 2; // Applications Tab Active

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        ApplicationsController(applicationRepository: ServiceLocator.instance.applicationRepository);
    _controller.addListener(_onControllerUpdate);
    _controller.loadApplications();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPatternWidth = screenWidth * 0.72;
    final topPatternHeight = topPatternWidth * (180 / 280);
    final applications = _controller.filteredApplications;

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
                      onProfileTap: () => Navigator.of(context).pushNamed('/profile'),
                    ),

                    const SizedBox(height: 14),

                    // Page Header with Back Arrow and Title/Subtitle
                    ApplicationsPageHeader(
                      onBack: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // 4-Segment Capsule Filter Bar
                    ApplicationsFilterBar(
                      selectedFilter: _controller.selectedFilter,
                      onFilterSelected: _controller.setFilter,
                    ),

                    const SizedBox(height: 12),

                    // Applications Cards List
                    if (_controller.isLoading) ...[
                      for (int i = 0; i < 4; i++) const ApplicationSkeletonCard(),
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
                              onPressed: _controller.loadApplications,
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
                    ] else if (applications.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 48.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.assignment_outlined,
                              size: 44,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No Applications Found',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No applications match the "${_controller.selectedFilter.label}" status filter.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      for (final application in applications)
                        ApplicationCardItem(
                          application: application,
                          onTap: () => Navigator.of(context).pushNamed(
                            '/application-details',
                            arguments: application,
                          ),
                        ),
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

      // 3. Fixed Bottom Navigation Bar (Tab 2 "Applications" Active)
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/scholarships');
          } else if (index == 2) {
            // Already on Applications, scroll to top
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
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
