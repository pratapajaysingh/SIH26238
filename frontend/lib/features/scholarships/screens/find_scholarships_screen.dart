import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/scholarships_controller.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/results_sort_bar.dart';
import '../widgets/scholarship_discovery_card.dart';
import '../widgets/scholarships_page_header.dart';
import '../widgets/scholarships_search_bar.dart';
import '../widgets/scholarship_skeleton_card.dart';

/// FindScholarshipsScreen faithfully reproduces the scholarship discovery visual target
/// matching the exact layout, colors, typography, and controls from the reference image.
class FindScholarshipsScreen extends StatefulWidget {
  final ScholarshipsController? controller;
  final String studentInitials;
  final int unreadNotificationsCount;

  const FindScholarshipsScreen({
    super.key,
    this.controller,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<FindScholarshipsScreen> createState() => _FindScholarshipsScreenState();
}

class _FindScholarshipsScreenState extends State<FindScholarshipsScreen> {
  late final ScholarshipsController _controller;
  int _currentNavIndex = 1; // "Scholarships" tab is active

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        ScholarshipsController(
          scholarshipRepository: ServiceLocator.instance.scholarshipRepository,
        );

    _controller.addListener(_onControllerUpdate);
    _controller.loadScholarships();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onControllerUpdate);
    }
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Schemes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Select Scheme Category:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ScholarshipsController.categories.map((cat) {
                        final isSel = cat == _controller.selectedCategory;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: const Color(0xFF111827),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              _controller.setCategory(cat);
                              setModalState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _controller.resetFilters();
                              Navigator.pop(ctx);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF374151),
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF111827),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final topPatternHeight = (screenHeight * 0.22).clamp(160.0, 220.0);
    final topPatternWidth = (screenWidth * 0.72).clamp(240.0, 360.0);

    final scholarships = _controller.filteredScholarships;

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

                    // Top Branding Header
                    DashboardHeader(
                      initials: widget.studentInitials,
                      unreadNotificationsCount: widget.unreadNotificationsCount,
                      onNotificationTap: () => Navigator.of(context).pushNamed('/notifications'),
                      onProfileTap: () => Navigator.of(context).pushNamed('/profile'),
                    ),

                    const SizedBox(height: 14),

                    // Page Header with Back Arrow and "My Filters"
                    ScholarshipsPageHeader(
                      onBack: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        }
                      },
                      onMyFilters: _showFiltersBottomSheet,
                    ),

                    const SizedBox(height: 14),

                    // Search Bar
                    ScholarshipsSearchBar(
                      initialValue: _controller.searchQuery,
                      onChanged: _controller.setSearchQuery,
                    ),

                    const SizedBox(height: 14),

                    // Horizontal Filter Chips
                    CategoryFilterChips(
                      categories: ScholarshipsController.categories,
                      selectedCategory: _controller.selectedCategory,
                      onSelected: _controller.setCategory,
                    ),

                    const SizedBox(height: 16),

                    // Result Count & Sort Dropdown Bar
                    ResultsSortBar(
                      count: _controller.resultCount,
                      selectedSort: _controller.selectedSort,
                      sortOptions: ScholarshipsController.sortOptions,
                      onSortChanged: _controller.setSort,
                    ),

                    const SizedBox(height: 12),

                    // Scholarship Cards / States
                    if (_controller.isLoading) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: const [
                            ScholarshipSkeletonCard(),
                            SizedBox(height: 12),
                            ScholarshipSkeletonCard(),
                            SizedBox(height: 12),
                            ScholarshipSkeletonCard(),
                          ],
                        ),
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
                              onPressed: _controller.loadScholarships,
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
                    ] else if (scholarships.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.search_off_rounded,
                              size: 44,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No scholarships found',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Try changing your search keywords or filter category.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: scholarships.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final scholarship = scholarships[index];
                            return ScholarshipDiscoveryCard(
                              scholarship: scholarship,
                              onTap: () => Navigator.of(context).pushNamed(
                                '/scholarship-details',
                                arguments: scholarship,
                              ),
                            );
                          },
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

      // 3. Fixed Bottom Navigation Bar (Tab 1 "Scholarships" Active)
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/applications');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
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
