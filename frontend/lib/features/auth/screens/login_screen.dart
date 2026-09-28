import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/enums/auth_method_enum.dart';
import '../../../core/enums/role_enum.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/aadhaar_input_field.dart';
import '../widgets/auth_method_tab_bar.dart';
import '../widgets/brand_header.dart';
import '../widgets/continue_button.dart';
import '../widgets/government_header.dart';
import '../widgets/identity_provider_card.dart';
import '../widgets/mobile_input_field.dart';
import '../widgets/or_divider.dart';
import '../widgets/role_segmented_control.dart';
import 'otp_verification_screen.dart';

/// LoginScreen faithfully implements the Student Login & Entry Experience
/// reproducing the visual source of truth provided in the project specification.
class LoginScreen extends StatefulWidget {
  final AuthController controller;

  const LoginScreen({
    super.key,
    required this.controller,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _handleContinue() async {
    final isAadhaar = _controller.selectedMethod == AuthMethod.aadhaar;
    final target = isAadhaar
        ? _controller.aadhaarController.text.trim()
        : _controller.mobileController.text.trim();

    final success = await _controller.submitContinue();
    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            controller: _controller,
            target: target,
            isAadhaar: isAadhaar,
          ),
        ),
      );
    }
  }

  Future<void> _handleDigiLockerLogin() async {
    final success = await _controller.loginWithDigiLocker();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  Future<void> _handleApaarLogin() async {
    final success = await _controller.loginWithApaar();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final bottomPadding = mediaQuery.padding.bottom;

    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final topPatternWidth = (screenWidth * 0.72).clamp(240.0, 500.0);
    final topPatternHeight = topPatternWidth * (180 / 280);
    final landscapeHeight = (screenHeight * 0.16).clamp(115.0, 160.0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top Decorative Tribal Pattern (Flowing dark curve on top right)
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

          // 2. Solid dark base to guarantee zero subpixel gap at screen bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 16,
            child: const ColoredBox(color: Color(0xFF14191D)),
          ),

          // 3. Bottom Decorative Tribal Landscape (Bleeds full to bottom, left & right)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: landscapeHeight,
            child: IgnorePointer(
              child: Image.asset(
                AssetConstants.bottomTribalLandscape,
                fit: BoxFit.fill,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 4. Main Interactive Foreground Content
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: isKeyboardOpen ? mediaQuery.viewInsets.bottom : 0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: isKeyboardOpen ? 0 : constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 6),

                            // Top Government Identity & Language Selector
                            const GovernmentHeader(),

                            const SizedBox(height: 12),

                            // TribalSetu Brand, Mission Description & Indicators
                            const BrandHeader(),

                            const SizedBox(height: 16),

                            // Role Selector (Student | Admin | Institute)
                            RoleSegmentedControl(
                              selectedRole: _controller.selectedRole,
                              onRoleChanged: (role) {
                                if (role == UserRole.student) {
                                  _controller.setRole(role);
                                } else {
                                  _showRoleNotice(role);
                                }
                              },
                            ),

                            const SizedBox(height: 14),

                            // Login Method Selector (Mobile Number | Aadhaar)
                            AuthMethodTabBar(
                              selectedMethod: _controller.selectedMethod,
                              onMethodChanged: (method) => _controller.setAuthMethod(method),
                            ),

                            const SizedBox(height: 12),

                            // Input Field (Mobile or Aadhaar)
                            if (_controller.selectedMethod == AuthMethod.mobile)
                              MobileInputField(
                                controller: _controller.mobileController,
                                hasError: _controller.errorMessage != null,
                                onSubmitted: _handleContinue,
                              )
                            else
                              AadhaarInputField(
                                controller: _controller.aadhaarController,
                                hasError: _controller.errorMessage != null,
                                onSubmitted: _handleContinue,
                              ),

                            // Validation / Error Feedback
                            if (_controller.errorMessage != null) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  _controller.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.statusError,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 14),

                            // Continue Button
                            ContinueButton(
                              onPressed: _handleContinue,
                              isLoading: _controller.isLoading,
                              isEnabled: true,
                            ),

                            const SizedBox(height: 8),

                            // OR Divider
                            const OrDivider(),

                            const SizedBox(height: 8),

                            // DigiLocker Action Card
                            IdentityProviderCard(
                              iconWidget: Image.asset(
                                AssetConstants.digilockerIcon,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.digilockerBrand,
                                  size: 28,
                                ),
                              ),
                              title: 'Continue with DigiLocker',
                              subtitle: 'Access using your DigiLocker account',
                              onTap: _handleDigiLockerLogin,
                              isLoading: _controller.isLoading,
                            ),

                            const SizedBox(height: 10),

                            // APAAR Action Card
                            IdentityProviderCard(
                              iconWidget: const Icon(
                                Icons.school_rounded,
                                color: Color(0xFF111827),
                                size: 28,
                              ),
                              title: 'Continue with APAAR',
                              subtitle: 'Using your APAAR ID',
                              onTap: _handleApaarLogin,
                              isLoading: _controller.isLoading,
                            ),

                            // Flexible space pushes footer to natural position when keyboard is closed
                            if (!isKeyboardOpen) const Spacer() else const SizedBox(height: 16),

                            // Bottom Institutional Motto
                            Padding(
                              padding: EdgeInsets.only(
                                top: 8,
                                bottom: isKeyboardOpen
                                    ? 16
                                    : max(landscapeHeight * 0.55, bottomPadding + 8),
                              ),
                              child: const Text(
                                AppStrings.bottomMotto,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleNotice(UserRole role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${role.label} portal access is restricted to verified departmental credentials.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.darkCharcoal,
      ),
    );
  }
}
