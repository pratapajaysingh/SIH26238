import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/scholarship.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/eligibility_controller.dart';
import '../widgets/additional_info_card.dart';
import '../widgets/check_eligibility_button.dart';
import '../widgets/eligibility_page_header.dart';
import '../widgets/eligibility_result_card.dart';
import '../widgets/eligibility_stepper.dart';
import '../widgets/proceed_to_apply_button.dart';
import '../widgets/scheme_selector_card.dart';

/// CheckEligibilityScreen faithfully implements the "Check Eligibility" feature
/// matching the exact visual target from the reference image.
///
/// Strictly conforms to:
/// - Screen -> Controller -> Repository -> ApiClient architecture
/// - POST /api/v1/eligibility/check
/// - GET /api/v1/scholarships
/// - Pixel-level fidelity matching the reference image
/// - Full-bleed top decorative tribal pattern
/// - Central ServiceLocator dependency injection
class CheckEligibilityScreen extends StatefulWidget {
  final EligibilityController? controller;
  final Scholarship? initialScholarship;
  final String? initialSchemeId;
  final String studentInitials;
  final int unreadNotificationsCount;

  const CheckEligibilityScreen({
    super.key,
    this.controller,
    this.initialScholarship,
    this.initialSchemeId,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<CheckEligibilityScreen> createState() => _CheckEligibilityScreenState();
}

class _CheckEligibilityScreenState extends State<CheckEligibilityScreen> {
  late final EligibilityController _controller;
  final ScrollController _scrollController = ScrollController();
  final int _currentNavIndex = 1; // "Scholarships" Tab is active

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        EligibilityController(
          eligibilityRepository: ServiceLocator.instance.eligibilityRepository,
          scholarshipRepository: ServiceLocator.instance.scholarshipRepository,
          initialScheme: widget.initialScholarship,
        );

    _controller.addListener(_onControllerUpdate);
    _controller.loadSchemes(
      preselectedScheme: widget.initialScholarship,
      preselectedSchemeId: widget.initialSchemeId,
    );
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

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/scholarships');
    }
  }

  void _handleProceedToApply() {
    Navigator.of(context).pushNamed(
      '/apply',
      arguments: _controller.selectedScheme,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final topPatternWidth = screenWidth * 0.72;
    final topPatternHeight = topPatternWidth * (180 / 280);

    final result = _controller.result;

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
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),

                  // Top Header (Emblem, TribalSetu Brand, Notification, Initials AS)
                  DashboardHeader(
                    initials: widget.studentInitials,
                    unreadNotificationsCount: widget.unreadNotificationsCount,
                    onNotificationTap: () => Navigator.of(context).pushNamed('/notifications'),
                    onProfileTap: () => Navigator.of(context).pushNamed('/profile'),
                  ),

                  const SizedBox(height: 14),

                  // Page Header with Back Arrow, Title and Subtitle
                  EligibilityPageHeader(onBack: _handleBack),

                  const SizedBox(height: 18),

                  // 4-Step Indicator Stepper
                  EligibilityStepper(activeStep: _controller.currentStep),

                  const SizedBox(height: 20),

                  // Select a Scholarship Scheme Section & Card
                  SchemeSelectorCard(
                    schemes: _controller.scholarships,
                    selectedScheme: _controller.selectedScheme,
                    onSchemeSelected: _controller.selectScheme,
                    isLoading: _controller.isLoadingSchemes,
                  ),

                  const SizedBox(height: 16),

                  // Check Eligibility CTA Button
                  CheckEligibilityButton(
                    onPressed: _controller.checkEligibility,
                    isLoading: _controller.isChecking,
                  ),

                  // Error Message Banner (if any)
                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFECACA),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _controller.errorMessage!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Color(0xFF991B1B)),
                              onPressed: _controller.clearError,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Evaluation Result & Follow-up Actions
                  if (result != null) ...[
                    const SizedBox(height: 20),

                    // Result Banner & Detailed Criteria Section
                    EligibilityResultCard(result: result),

                    const SizedBox(height: 16),

                    // Additional Information Informational Card
                    const AdditionalInfoCard(),

                    const SizedBox(height: 16),

                    // Proceed to Apply Button
                    ProceedToApplyButton(
                      onPressed: _handleProceedToApply,
                    ),
                  ],

                  // Clearance before fixed bottom navigation bar
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Fixed Bottom Navigation Bar with Center Elevated JAGO Button
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
          } else if (index == 1) {
            Navigator.of(context).pushNamed('/scholarships');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/applications');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/profile');
          } else if (index == 4) {
            Navigator.of(context).pushNamed('/jago');
          }
        },
        onJagoTap: () => Navigator.of(context).pushNamed('/jago'),
      ),
    );
  }
}
