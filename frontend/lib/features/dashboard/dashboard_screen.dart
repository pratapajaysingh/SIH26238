import 'package:flutter/material.dart';
import '../../core/constants/asset_constants.dart';
import '../../core/di/service_locator.dart';
import '../auth/controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'widgets/application_status_tracker.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/hero_scholarship_banner.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/recommended_scholarship_card.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/student_greeting_section.dart';

/// DashboardScreen reproduces the Student Home / Dashboard visual source of truth
/// for the Ministry of Tribal Affairs (MoTA) TribalSetu platform.
/// Strictly follows:
/// - Screen -> Controller -> Repository -> ApiClient architecture
/// - Pixel-level visual fidelity matching the reference image
/// - Full-bleed top decorative tribal pattern
/// - Dynamic data-driven presentation without modifying backend contracts
class DashboardScreen extends StatefulWidget {
  final AuthController authController;
  final HomeController? homeController;

  const DashboardScreen({
    super.key,
    required this.authController,
    this.homeController,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final HomeController _controller;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.homeController ??
        HomeController(
          studentRepository: ServiceLocator.instance.studentRepository,
          scholarshipRepository: ServiceLocator.instance.scholarshipRepository,
          applicationRepository: ServiceLocator.instance.applicationRepository,
          notificationRepository: ServiceLocator.instance.notificationRepository,
        );

    _controller.addListener(_onControllerUpdate);
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    if (widget.homeController == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onControllerUpdate);
    }
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _handleActionPlaceholder(String actionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$actionName — connecting to verified MoTA service...'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF111827),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final topPatternHeight = (screenHeight * 0.22).clamp(160.0, 220.0);
    final topPatternWidth = (screenWidth * 0.72).clamp(240.0, 360.0);

    final summary = _controller.studentSummary;
    final initials = summary?.initials ?? 'AS';
    final name = summary?.name ?? 'Aarav Singh';
    final greeting = summary?.greeting ?? 'Good Morning';
    final quote = summary?.motivationalQuote ?? 'Keep going! Your dreams matter.';
    final studentId = summary?.studentId ?? 'TS2024S10023';

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
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),

                    // Top Header (Emblem, TribalSetu Brand, Notification, Initials)
                    DashboardHeader(
                      initials: initials,
                      unreadNotificationsCount: _controller.unreadNotificationsCount,
                      onNotificationTap: () => Navigator.of(context).pushNamed('/notifications'),
                      onProfileTap: () => Navigator.of(context).pushNamed('/profile'),
                    ),

                    const SizedBox(height: 16),

                    // Greeting & Student ID Card
                    StudentGreetingSection(
                      greeting: greeting,
                      studentName: name,
                      motivationalQuote: quote,
                      studentId: studentId,
                      onCardTap: () => _handleActionPlaceholder('Student ID Card'),
                    ),

                    const SizedBox(height: 16),

                    // Search Bar
                    SearchBarWidget(
                      onTap: () => Navigator.of(context).pushNamed('/scholarships'),
                    ),

                    const SizedBox(height: 18),

                    // Hero Scholarship Banner
                    HeroScholarshipBanner(
                      onExploreTap: () => Navigator.of(context).pushNamed('/scholarships'),
                    ),

                    const SizedBox(height: 20),

                    // Quick Actions (6 Items)
                    QuickActionsSection(
                      unreadNotificationsCount: _controller.unreadNotificationsCount,
                      onFindScholarships: () => Navigator.of(context).pushNamed('/scholarships'),
                      onMyApplications: () => _handleActionPlaceholder('My Applications'),
                      onDocumentLocker: () => _handleActionPlaceholder('Document Locker'),
                      onPaymentStatus: () => _handleActionPlaceholder('Payment Status'),
                      onAskJago: () => Navigator.of(context).pushNamed('/jago'),
                      onNotifications: () => Navigator.of(context).pushNamed('/notifications'),
                      onSeeAll: () => _handleActionPlaceholder('All Services'),
                    ),

                    const SizedBox(height: 20),

                    // Recommended for You (Scholarship Card)
                    RecommendedScholarshipCard(
                      scholarship: _controller.recommendedScholarship,
                      onTap: () => _handleActionPlaceholder('Post Matric Scholarship Details'),
                      onViewAll: () => Navigator.of(context).pushNamed('/scholarships'),
                    ),

                    const SizedBox(height: 20),

                    // Application Status Tracker
                    ApplicationStatusTracker(
                      application: _controller.activeApplication,
                      timelineEvents: _controller.timelineEvents,
                      onTap: () => Navigator.of(context).pushNamed('/applications'),
                      onViewAll: () => Navigator.of(context).pushNamed('/applications'),
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

      // 3. Fixed Bottom Navigation Bar with Center Elevated JAGO Button
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed('/scholarships');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/applications');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/profile');
          } else if (index == 4) {
            Navigator.of(context).pushNamed('/jago');
          } else {
            setState(() => _currentNavIndex = index);
          }
        },
        onJagoTap: () => Navigator.of(context).pushNamed('/jago'),
      ),
    );
  }
}
