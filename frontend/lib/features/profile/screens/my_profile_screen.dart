import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_document_section.dart';
import '../widgets/profile_hero_card.dart';
import '../widgets/profile_info_section_card.dart';
import '../widgets/profile_page_header.dart';
import '../widgets/profile_skeleton_loader.dart';

/// MyProfileScreen renders the "My Profile" screen faithfully matching
/// the reference image with:
/// - Edge-to-edge full-bleed top tribal decoration
/// - Government of India emblem, TribalSetu brand, notification bell, AS avatar header
/// - Page title "My Profile" and subtitle
/// - Profile Hero card with student photo, camera icon overlay, name, student type, student ID, verified pill, and edit button
/// - Personal Information card (Full Name, Date of Birth, Gender, Category)
/// - Contact Information card (Mobile Number with Verified pill, Email with Verified pill, Multi-line Address)
/// - Academic Information card (Current Education Level, Institute Name, Academic Year)
/// - Document Management horizontal cards with status dots
/// - Fixed bottom navigation bar with "Profile" (Tab 3) active
class MyProfileScreen extends StatefulWidget {
  final ProfileController? controller;
  final String studentInitials;
  final int unreadNotificationsCount;

  const MyProfileScreen({
    super.key,
    this.controller,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late final ProfileController _controller;
  final ScrollController _scrollController = ScrollController();
  final int _currentNavIndex = 3; // Profile Tab Active

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        ProfileController(
          profileRepository: ServiceLocator.instance.profileRepository,
          documentRepository: ServiceLocator.instance.documentRepository,
        );
    _controller.addListener(_onControllerUpdate);
    _controller.loadProfile();
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

  void _handleActionNotice(String feature) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature is available'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPatternWidth = screenWidth * 0.72;
    final topPatternHeight = topPatternWidth * (180 / 280);
    final profile = _controller.profile;

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

                    const SizedBox(height: 14),

                    // Page Header (Title + Subtitle)
                    const ProfilePageHeader(),

                    const SizedBox(height: 14),

                    // Loading, Error, or Profile Content
                    if (_controller.isLoading) ...[
                      const ProfileSkeletonLoader(),
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
                              onPressed: _controller.loadProfile,
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
                    ] else if (profile != null) ...[
                      // 1. Profile Hero Card
                      ProfileHeroCard(
                        profile: profile,
                        onEditProfile: () => _handleActionNotice('Edit Profile'),
                      ),

                      const SizedBox(height: 14),

                      // 2. Personal Information Card
                      ProfileInfoSectionCard(
                        title: 'Personal Information',
                        items: [
                          ProfileInfoRowItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Full Name',
                            value: profile.fullName,
                            onTap: () => _handleActionNotice('Full Name'),
                          ),
                          ProfileInfoRowItem(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date of Birth',
                            value: profile.dateOfBirthFormatted,
                            onTap: () => _handleActionNotice('Date of Birth'),
                          ),
                          ProfileInfoRowItem(
                            icon: Icons.people_outline_rounded,
                            label: 'Gender',
                            value: profile.gender ?? '-',
                            onTap: () => _handleActionNotice('Gender'),
                          ),
                          ProfileInfoRowItem(
                            icon: Icons.badge_outlined,
                            label: 'Category',
                            value: profile.categoryDisplay,
                            onTap: () => _handleActionNotice('Category'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 3. Contact Information Card
                      ProfileInfoSectionCard(
                        title: 'Contact Information',
                        items: [
                          ProfileInfoRowItem(
                            icon: Icons.phone_outlined,
                            label: 'Mobile Number',
                            value: profile.mobile ?? '-',
                            isVerified: profile.isVerified,
                            onTap: () => _handleActionNotice('Mobile Number'),
                          ),
                          ProfileInfoRowItem(
                            icon: Icons.mail_outline_rounded,
                            label: 'Email Address',
                            value: profile.email ?? '-',
                            isVerified: profile.isVerified,
                            onTap: () => _handleActionNotice('Email Address'),
                          ),
                          ProfileInfoRowItem(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: profile.formattedAddress,
                            isMultiLine: true,
                            onTap: () => _handleActionNotice('Address'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 4. Academic Information Card
                      ProfileInfoSectionCard(
                        title: 'Academic Information',
                        items: [
                          ProfileInfoRowItem(
                            icon: Icons.school_outlined,
                            label: 'Current Education Level',
                            value: profile.course ?? '-',
                            onTap: () => _handleActionNotice('Current Education Level'),
                          ),
                          ProfileInfoRowItem(
                            icon: Icons.account_balance_outlined,
                            label: 'Institute Name',
                            value: profile.institutionName ?? '-',
                            onTap: () => _handleActionNotice('Institute Name'),
                          ),
                          ProfileInfoRowItem(
                            icon: Icons.description_outlined,
                            label: 'Academic Year',
                            value: profile.academicYear ?? '-',
                            onTap: () => _handleActionNotice('Academic Year'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 5. Document Management Section
                      ProfileDocumentSection(
                        documents: _controller.documents,
                        onViewAll: () => Navigator.of(context).pushNamed('/documents'),
                        onDocumentTap: (doc) => Navigator.of(context).pushNamed('/documents'),
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
            // Already on Profile, scroll to top
            if (_scrollController.hasClients) {
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
