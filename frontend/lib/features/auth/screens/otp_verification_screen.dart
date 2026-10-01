import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/enums/role_enum.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/auth_controller.dart';
import '../widgets/continue_button.dart';

/// OtpVerificationScreen handles Step 2 of the Email OTP Authentication Experience.
class OtpVerificationScreen extends StatefulWidget {
  final AuthController controller;
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.controller,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _countdownTimer;
  int _expiresInSeconds = 300;
  int _resendCooldownSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _expiresInSeconds = widget.controller.expiresIn > 0 ? widget.controller.expiresIn : 300;
    _startTimers();
  }

  void _startTimers() {
    _countdownTimer?.cancel();
    _resendCooldownSeconds = widget.controller.retryAfterSeconds > 0
        ? widget.controller.retryAfterSeconds
        : 60;
    _canResend = false;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_expiresInSeconds > 0) {
          _expiresInSeconds--;
        }
        if (_resendCooldownSeconds > 0) {
          _resendCooldownSeconds--;
        } else {
          _canResend = true;
        }
      });
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    final success = await widget.controller.verifyOtp(otp);
    if (success && mounted) {
      final targetRoute = widget.controller.session?.user.role == UserRole.admin
          ? '/admin'
          : '/dashboard';
      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;
    final success = await widget.controller.resendOtp();
    if (success && mounted) {
      setState(() {
        _expiresInSeconds = widget.controller.expiresIn > 0 ? widget.controller.expiresIn : 300;
      });
      _startTimers();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMockMode = ServiceLocator.useMock;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
          onPressed: () {
            widget.controller.resetOtpState();
            Navigator.pop(context);
          },
        ),
        title: Image.asset(
          AssetConstants.govtHeader,
          height: 36,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Target email display & Change Email button
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Enter the 6-digit code sent to ',
                    style: AppTypography.description,
                  ),
                  Text(
                    widget.email,
                    style: AppTypography.description.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      widget.controller.resetOtpState();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Change email',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Mock Mode Demo Code Banner (NO SMS mentioned)
              if (isMockMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.info_outline_rounded, size: 16, color: AppColors.grey600),
                      SizedBox(width: 8),
                      Text(
                        'Demo Code: 123456',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              // 6-digit Code Input Field
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.controller.errorMessage != null
                        ? AppColors.statusError
                        : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 14,
                      color: AppColors.textPrimary,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      hintText: AppStrings.otpPlaceholder,
                      hintStyle: TextStyle(
                        fontSize: 22,
                        letterSpacing: 14,
                        color: AppColors.textPlaceholder,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _handleVerify(),
                  ),
                ),
              ),

              // Error display
              if (widget.controller.errorMessage != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    widget.controller.errorMessage!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.statusError,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Expiry & Resend Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(
                        _expiresInSeconds > 0
                            ? 'Expires in ${_formatTime(_expiresInSeconds)}'
                            : 'Code expired',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _expiresInSeconds > 0
                              ? const Color(0xFF6B7280)
                              : AppColors.statusError,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _canResend ? _handleResend : null,
                    child: Text(
                      _canResend
                          ? AppStrings.resendCodeButton
                          : 'Resend in ${_resendCooldownSeconds}s',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _canResend ? AppColors.black : AppColors.grey400,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Verify & Continue Button
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  return ContinueButton(
                    label: AppStrings.verifyButton,
                    onPressed: _handleVerify,
                    isLoading: widget.controller.isLoading,
                    isEnabled: _otpController.text.length == 6,
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
