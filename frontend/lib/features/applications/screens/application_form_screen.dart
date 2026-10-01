import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/document.dart';
import '../../../models/scholarship.dart';
import '../controllers/application_form_controller.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../../eligibility/widgets/scheme_conflict_dialog.dart';

/// ApplicationFormScreen is the multi-step scholarship application wizard.
///
/// Steps:
///   0 → Application Details (pre-filled profile + academic year)
///   1 → Document Selection (toggle wallet documents)
///   2 → Review & Submit (declaration + submit button)
///   3 → Confirmation (application number + status)
///
/// Consumes:
///   POST /api/v1/applications              → create draft
///   PUT  /api/v1/applications/{id}         → save draft
///   POST /api/v1/applications/{id}/documents    → attach document
///   DELETE /api/v1/applications/{id}/documents/{docId} → remove document
///   POST /api/v1/applications/{id}/submit  → submit
class ApplicationFormScreen extends StatefulWidget {
  final Scholarship? scholarship;
  final String studentInitials;
  final int unreadNotificationsCount;

  const ApplicationFormScreen({
    super.key,
    this.scholarship,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  late final ApplicationFormController _controller;

  @override
  void initState() {
    super.initState();
    final sl = ServiceLocator.instance;
    _controller = ApplicationFormController(
      applicationRepository: sl.applicationRepository,
      profileRepository: sl.profileRepository,
      documentRepository: sl.documentRepository,
    );
    _controller.addListener(_onControllerChanged);

    if (widget.scholarship != null) {
      _controller.initialize(scheme: widget.scholarship!);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          final conflict = await ServiceLocator.instance.eligibilityRepository.checkConflict(
            studentId: 'TS2024S10023',
            schemeId: widget.scholarship!.id,
          );
          if (mounted && conflict.hasConflict) {
            SchemeConflictDialog.show(
              context,
              conflict: conflict,
              onViewExistingApplication: () {
                Navigator.of(context).pushReplacementNamed(
                  '/application-details',
                  arguments: conflict.existingApplicationId,
                );
              },
            );
          }
        } catch (_) {}
      });
    }
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
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
          // 1. Top Decorative Tribal Curve
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

          // 2. Foreground Scrollable Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),

                  // Top Header
                  DashboardHeader(
                    initials: widget.studentInitials,
                    unreadNotificationsCount: widget.unreadNotificationsCount,
                    onNotificationTap: () => Navigator.of(context).pushNamed('/notifications'),
                    onProfileTap: () => Navigator.of(context).pushNamed('/profile'),
                  ),

                  const SizedBox(height: 12),

                  // Page Header with back arrow
                  _buildPageHeader(),

                  const SizedBox(height: 16),

                  // Step indicator
                  if (_controller.currentStep < 3) _buildStepIndicator(),

                  const SizedBox(height: 16),

                  // Error message
                  if (_controller.errorMessage != null)
                    _buildErrorBanner(_controller.errorMessage!),

                  // Feedback message
                  if (_controller.feedbackMessage != null)
                    _buildFeedbackBanner(_controller.feedbackMessage!),

                  // Loading state
                  if (_controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF111827)),
                      ),
                    )
                  else ...[
                    // Step Content
                    if (_controller.currentStep == 0) _buildDetailsStep(),
                    if (_controller.currentStep == 1) _buildDocumentsStep(),
                    if (_controller.currentStep == 2) _buildReviewStep(),
                    if (_controller.currentStep == 3) _buildConfirmationStep(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar with Applications Tab Active (Index 2)
      bottomNavigationBar: _controller.currentStep == 3
          ? null
          : CustomBottomNavBar(
              selectedIndex: 2,
              onItemSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/scholarships');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/applications');
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

  // ── PAGE HEADER ──────────────────────────────────────────────

  Widget _buildPageHeader() {
    String title;
    String subtitle;

    switch (_controller.currentStep) {
      case 0:
        title = 'Application Details';
        subtitle = 'Review your pre-filled information.';
        break;
      case 1:
        title = 'Attach Documents';
        subtitle = 'Select documents from your wallet.';
        break;
      case 2:
        title = 'Review & Submit';
        subtitle = 'Verify all details before submission.';
        break;
      case 3:
        title = 'Application Submitted';
        subtitle = 'Your application has been received.';
        break;
      default:
        title = 'Apply';
        subtitle = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller.currentStep < 3)
            GestureDetector(
              onTap: () {
                if (_controller.currentStep > 0) {
                  _controller.previousStep();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(top: 2.0, right: 12.0),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 24,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP INDICATOR ──────────────────────────────────────────

  Widget _buildStepIndicator() {
    const steps = ['Details', 'Documents', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == _controller.currentStep;
          final isCompleted = index < _controller.currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? const Color(0xFF16A34A)
                        : isActive
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFE2E8F0),
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF0F172A)
                          : isCompleted
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF94A3B8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 16,
                    height: 1.5,
                    color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── ERROR / FEEDBACK BANNERS ────────────────────────────────

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFEF4444)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFFB91C1C)),
            ),
          ),
          GestureDetector(
            onTap: () => _controller.clearError(),
            child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFF16A34A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF166534)),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 0: APPLICATION DETAILS ─────────────────────────────

  Widget _buildDetailsStep() {
    final profile = _controller.studentProfile;
    final scheme = _controller.scholarship;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scheme Summary Card
        if (scheme != null) _buildSchemeInfoCard(scheme),

        const SizedBox(height: 14),

        // Pre-filled Profile Information
        _buildSectionCard(
          title: 'Student Information',
          icon: Icons.person_outline_rounded,
          children: [
            _buildInfoRow('Full Name', profile?.fullName ?? '-'),
            _buildInfoRow('Date of Birth', profile?.dateOfBirthFormatted ?? '-'),
            _buildInfoRow('Gender', profile?.gender ?? '-'),
            _buildInfoRow('Category', profile?.categoryDisplay ?? '-'),
            _buildInfoRow('Mobile', profile?.mobile ?? '-'),
            _buildInfoRow('Email', profile?.email ?? '-'),
          ],
        ),

        const SizedBox(height: 14),

        _buildSectionCard(
          title: 'Academic Information',
          icon: Icons.school_outlined,
          children: [
            _buildInfoRow('Institution', profile?.institutionName ?? '-'),
            _buildInfoRow('Course', profile?.course ?? '-'),
            _buildInfoRow('Address', profile?.formattedAddress ?? '-'),
          ],
        ),

        const SizedBox(height: 14),

        // Academic Year Selection
        _buildSectionCard(
          title: 'Application Year',
          icon: Icons.calendar_today_outlined,
          children: [
            _buildAcademicYearSelector(),
          ],
        ),

        const SizedBox(height: 20),

        // Next Step Button
        _buildPrimaryButton(
          label: 'Continue to Documents',
          icon: Icons.arrow_forward_rounded,
          onTap: () => _controller.nextStep(),
        ),
      ],
    );
  }

  Widget _buildSchemeInfoCard(Scholarship scheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.account_balance, size: 22, color: Color(0xFF0284C7)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${scheme.sourcePortal} • ${scheme.benefitAmount}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicYearSelector() {
    const years = ['2025-26', '2026-27', '2027-28'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Academic Year',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: years.map((year) {
            final isSelected = _controller.academicYear == year;
            return GestureDetector(
              onTap: () => _controller.setAcademicYear(year),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Text(
                  year,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── STEP 1: DOCUMENT SELECTION ──────────────────────────────

  Widget _buildDocumentsStep() {
    final documents = _controller.walletDocuments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Info banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF3B82F6)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Select documents from your wallet to attach to this application. Toggle to include or exclude.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (documents.isEmpty)
          _buildEmptyDocumentsState()
        else
          ...documents.map((doc) => _buildDocumentToggleItem(doc)),

        const SizedBox(height: 14),

        // Save Draft + Next
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _controller.isSavingDraft
                      ? null
                      : () async {
                          await _controller.saveDraft();
                        },
                  icon: _controller.isSavingDraft
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF64748B)),
                        )
                      : const Icon(Icons.save_outlined, size: 16, color: Color(0xFF0F172A)),
                  label: Text(
                    _controller.isSavingDraft ? 'Saving...' : 'Save Draft',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _controller.nextStep(),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Review',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentToggleItem(DocumentItem doc) {
    final isAttached = _controller.attachedDocumentIds.contains(doc.id);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAttached ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isAttached
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            _getDocumentIcon(doc.categoryDisplay),
            size: 20,
            color: isAttached ? const Color(0xFF16A34A) : const Color(0xFF64748B),
          ),
        ),
        title: Text(
          doc.docName,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          '${doc.categoryDisplay} • ${doc.sourceDisplay}',
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
        ),
        trailing: GestureDetector(
          onTap: () => _controller.toggleDocumentAttachment(doc.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isAttached ? const Color(0xFF16A34A) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isAttached ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: isAttached
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDocumentsState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.folder_open_rounded, size: 40, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          const Text(
            'No Documents in Wallet',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload documents to your Document Wallet first, then come back to attach them.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushNamed('/documents'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Go to Document Wallet',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(String category) {
    switch (category) {
      case 'Identity':
        return Icons.badge_outlined;
      case 'Academic':
        return Icons.school_outlined;
      case 'Income':
        return Icons.currency_rupee_rounded;
      case 'Caste':
        return Icons.verified_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  // ── STEP 2: REVIEW & SUBMIT ─────────────────────────────────

  Widget _buildReviewStep() {
    final profile = _controller.studentProfile;
    final scheme = _controller.scholarship;
    final attachedDocs = _controller.attachedDocuments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scheme Summary
        if (scheme != null) _buildSchemeInfoCard(scheme),

        const SizedBox(height: 14),

        // Applicant Summary
        _buildSectionCard(
          title: 'Applicant Summary',
          icon: Icons.person_outline_rounded,
          children: [
            _buildInfoRow('Full Name', profile?.fullName ?? '-'),
            _buildInfoRow('Category', profile?.categoryDisplay ?? '-'),
            _buildInfoRow('Institution', profile?.institutionName ?? '-'),
            _buildInfoRow('Academic Year', _controller.academicYear),
          ],
        ),

        const SizedBox(height: 14),

        // Attached Documents Summary
        _buildSectionCard(
          title: 'Attached Documents (${attachedDocs.length})',
          icon: Icons.attach_file_rounded,
          children: [
            if (attachedDocs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No documents attached. You can go back to attach documents.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                ),
              )
            else
              ...attachedDocs.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16A34A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            doc.docName,
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)),
                          ),
                        ),
                        Text(
                          doc.categoryDisplay,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )),
          ],
        ),

        const SizedBox(height: 14),

        // Declaration Checkbox
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _controller.setDeclarationAccepted(!_controller.declarationAccepted),
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: _controller.declarationAccepted ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _controller.declarationAccepted
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: _controller.declarationAccepted
                      ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'I hereby declare that all the information provided above is true and correct to the best of my knowledge. I understand that any false information may result in rejection of my application.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Submit Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: _controller.isSubmitting || !_controller.declarationAccepted
                ? null
                : () => _controller.submitApplication(),
            icon: _controller.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            label: Text(
              _controller.isSubmitting ? 'Submitting...' : 'Submit Application',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _controller.declarationAccepted
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFCBD5E1),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
            ),
          ),
        ),
      ],
    );
  }

  // ── STEP 3: CONFIRMATION ────────────────────────────────────

  Widget _buildConfirmationStep() {
    final application = _controller.application;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Success Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF0FDF4),
              border: Border.all(color: const Color(0xFF86EFAC), width: 2),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: Color(0xFF16A34A),
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Center(
          child: Text(
            'Application Submitted!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ),

        const SizedBox(height: 6),

        const Center(
          child: Text(
            'Your scholarship application has been successfully submitted for review.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),

        const SizedBox(height: 20),

        // Application Details Card
        _buildSectionCard(
          title: 'Submission Details',
          icon: Icons.receipt_long_outlined,
          children: [
            _buildInfoRow('Application No.', application?.applicationNumber ?? '-'),
            _buildInfoRow('Scheme', application?.schemeName ?? _controller.scholarship?.name ?? '-'),
            _buildInfoRow('Status', application?.status.label ?? 'Submitted'),
            _buildInfoRow('Academic Year', _controller.academicYear),
            _buildInfoRow('Documents Attached', '${_controller.attachedDocumentIds.length}'),
          ],
        ),

        const SizedBox(height: 14),

        // Important Information
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your application will be verified by your institution. You can track the status under My Applications.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.4),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/applications', (route) => route.settings.name == '/dashboard');
                },
                icon: const Icon(Icons.list_alt_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'View My Applications',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                },
                icon: const Icon(Icons.home_outlined, color: Color(0xFF0F172A), size: 18),
                label: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── SHARED WIDGETS ──────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF0F172A)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
        ),
      ),
    );
  }
}
