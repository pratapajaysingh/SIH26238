import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/enums/role_enum.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/brand_header.dart';
import '../widgets/continue_button.dart';
import '../widgets/email_input_field.dart';
import '../widgets/government_header.dart';
import '../widgets/role_segmented_control.dart';
import 'otp_verification_screen.dart';

/// LoginScreen implements Step 1 of the Email OTP Authentication Experience.
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

  Future<void> _handleSendCode() async {
    final email = _controller.emailController.text.trim();
    final success = await _controller.requestOtp();
    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            controller: _controller,
            email: email,
          ),
        ),
      );
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

          // 2. Solid dark base at screen bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 16,
            child: const ColoredBox(color: Color(0xFF14191D)),
          ),

          // 3. Bottom Decorative Tribal Landscape
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

                            // TribalSetu Brand & Mission Description
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

                            const SizedBox(height: 20),

                            // Instruction Label
                            const Text(
                              'Sign in to your account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Enter your registered email address to receive a 6-digit verification code.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Email Input Field (Step 1)
                            EmailInputField(
                              controller: _controller.emailController,
                              hasError: _controller.errorMessage != null,
                              onSubmitted: _handleSendCode,
                            ),

                            // Validation / Error Feedback
                            if (_controller.errorMessage != null) ...[
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  _controller.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.statusError,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 18),

                            // Send Code Button
                            ContinueButton(
                              label: AppStrings.sendCodeButton,
                              onPressed: _handleSendCode,
                              isLoading: _controller.isLoading,
                              isEnabled: true,
                            ),

                            // Flexible space pushes footer to natural position when keyboard is closed
                            if (!isKeyboardOpen) const Spacer() else const SizedBox(height: 24),

                            // Bottom Institutional Motto
                            Padding(
                              padding: EdgeInsets.only(
                                top: 12,
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
