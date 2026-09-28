import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/application.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/payment_status_controller.dart';
import '../widgets/payment_application_summary_card.dart';
import '../widgets/payment_details_card.dart';
import '../widgets/payment_info_callout_cards.dart';
import '../widgets/payment_processing_callout_card.dart';
import '../widgets/payment_progress_stepper.dart';
import '../widgets/payment_status_page_header.dart';
import '../widgets/payment_status_skeleton_loader.dart';

/// PaymentStatusScreen renders the complete "Payment / DBT Status" screen
/// strictly adhering to the visual target from the reference image.
///
/// Hierarchy & Navigation:
/// Applications -> My Applications -> Select an Application -> Payment / DBT Status.
/// Global bottom navigation: Applications tab (index 2) is active.
class PaymentStatusScreen extends StatefulWidget {
  final PaymentStatusController? controller;
  final String? applicationId;
  final Application? initialApplication;
  final String studentInitials;
  final int unreadNotificationsCount;

  const PaymentStatusScreen({
    super.key,
    this.controller,
    this.applicationId,
    this.initialApplication,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  late final PaymentStatusController _controller;
  final ScrollController _scrollController = ScrollController();
  final int _currentNavIndex = 2; // Applications Tab Active

  @override
  void initState() {
    super.initState();
    final targetId = widget.applicationId ??
        widget.initialApplication?.id ??
        'app-2026-st-01';

    _controller = widget.controller ??
        PaymentStatusController(
          paymentRepository: ServiceLocator.instance.paymentRepository,
          applicationRepository: ServiceLocator.instance.applicationRepository,
          applicationId: targetId,
          initialApplication: widget.initialApplication,
        );

    _controller.addListener(_onControllerUpdate);
    if (widget.controller == null || _controller.application == null) {
      _controller.loadData(initialApplication: widget.initialApplication);
    }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top Decorative Tribal Pattern
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
                    PaymentStatusPageHeader(
                      onBack: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/applications');
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Loading State Skeleton
                    if (_controller.isLoading && _controller.payments.isEmpty) ...[
                      const PaymentStatusSkeletonLoader(),
                    ]
                    // Error State
                    else if (_controller.errorMessage != null && _controller.payments.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _controller.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _controller.refresh,
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
                    // Populated Content
                    else ...[
                      // 1. Application Summary Card
                      PaymentApplicationSummaryCard(
                        application: _controller.application,
                        onViewApplication: () {
                          if (_controller.application != null) {
                            Navigator.of(context).pushNamed(
                              '/application-details',
                              arguments: _controller.application,
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      // 2. Payment Progress Stepper (4 steps)
                      PaymentProgressStepper(
                        steps: _controller.progressSteps,
                      ),

                      const SizedBox(height: 18),

                      // 3. Payment Processing Callout Card
                      PaymentProcessingCalloutCard(
                        status: _controller.currentPaymentStatus,
                      ),

                      const SizedBox(height: 18),

                      // 4. Payment Details Card (7 item rows)
                      PaymentDetailsCard(
                        sanctionOrderNumber: _controller.sanctionOrderNumber,
                        sanctionDate: _controller.sanctionDateFormatted,
                        sanctionedAmount: _controller.amountFormatted,
                        paymentMethod: _controller.paymentMethod,
                        maskedAccountNumber: _controller.maskedAccountNumber,
                        bankName: _controller.bankAccountName,
                        expectedCreditDate: _controller.expectedCreditDateText,
                        paymentReference: _controller.paymentReference,
                        paymentReferenceDate: _controller.paymentReferenceDateFormatted,
                      ),

                      const SizedBox(height: 18),

                      // 5. Informational Callout Cards (What happens next? & Important Information)
                      const PaymentInfoCalloutCards(),
                    ],

                    // Clearance padding before fixed bottom navigation bar
                    const SizedBox(height: 28),
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
      ),
    );
  }
}
