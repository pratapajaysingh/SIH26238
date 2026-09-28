import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_card_item.dart';
import '../widgets/notifications_empty_state.dart';
import '../widgets/notifications_filter_bar.dart';
import '../widgets/notifications_skeleton_loader.dart';

/// NotificationsScreen renders the global in-app notifications destination
/// matching the exact visual target from the reference screenshot.
///
/// Hierarchy & Flow:
/// Any Screen -> Notification Bell (Header) -> Notifications
///
/// Features:
/// - Full-bleed top tribal curved decoration strip
/// - Shared DashboardHeader with live unread indicator
/// - Page title "Notifications" and descriptive subtitle
/// - 5 filter capsule tabs: [ All | Unread | Applications | Payments | System ]
/// - Real dynamic notifications loaded from GET /api/v1/notifications
/// - Mark as read via PATCH /api/v1/notifications/{id}/read on tap
/// - Contextual empty states and error recovery
/// - Fixed global CustomBottomNavBar (Notifications is not a bottom nav tab)
class NotificationsScreen extends StatefulWidget {
  final NotificationsController? controller;
  final String studentInitials;

  const NotificationsScreen({
    super.key,
    this.controller,
    this.studentInitials = 'AS',
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsController _controller;
  late final bool _isInternalController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = NotificationsController(
        repository: ServiceLocator.instance.notificationRepository,
      );
      _isInternalController = true;
      _controller.loadNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPatternWidth = screenWidth * 0.72;
    final topPatternHeight = topPatternWidth * (180 / 280);

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
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return RefreshIndicator(
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

                        // Shared Top Header
                        DashboardHeader(
                          initials: widget.studentInitials,
                          unreadNotificationsCount: _controller.unreadCount,
                          onNotificationTap: () {
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                          onProfileTap: () => Navigator.of(context).pushNamed('/profile'),
                        ),

                        const SizedBox(height: 18),

                        // Page Title & Subtitle (Left-aligned)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Stay updated on your applications, verifications and payments.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Filter Capsule Tabs Bar
                        NotificationsFilterBar(
                          selectedFilter: _controller.selectedFilter,
                          onFilterSelected: _controller.setFilter,
                        ),

                        const SizedBox(height: 12),

                        // State Handling: Loading, Error, Empty, or Cards
                        if (_controller.isLoading) ...[
                          const NotificationsSkeletonLoader(),
                        ] else if (_controller.errorMessage != null) ...[
                          _buildErrorState(),
                        ] else if (_controller.filteredNotifications.isEmpty) ...[
                          NotificationsEmptyState(filter: _controller.selectedFilter),
                        ] else ...[
                          _buildNotificationsList(),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Fixed Global Bottom Navigation Bar (No item selected on Notifications screen)
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: -1,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('/scholarships');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('/applications');
          } else if (index == 3) {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        },
        onJagoTap: () => Navigator.of(context).pushNamed('/jago'),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final items = _controller.filteredNotifications;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return NotificationCardItem(
          item: item,
          onTap: () async {
            // 1. Mark as read if currently unread
            if (!item.isRead) {
              try {
                await _controller.markAsRead(item.id);
              } catch (_) {
                // Controller handles error state
              }
            }

            // 2. Navigate to application if associated
            if (item.applicationId != null && context.mounted) {
              Navigator.of(context).pushNamed(
                '/application-details',
                arguments: item.applicationId,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 36.0),
      child: Center(
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
              onPressed: _controller.loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
