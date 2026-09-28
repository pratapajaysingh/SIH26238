import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/auth_controller.dart';
import '../widgets/continue_button.dart';

/// OtpVerificationScreen handles the second step of OTP-based authentication.
class OtpVerificationScreen extends StatefulWidget {
  final AuthController controller;
  final String target;
  final bool isAadhaar;

  const OtpVerificationScreen({
    super.key,
    required this.controller,
    required this.target,
    this.isAadhaar = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
        return true;
      } else {
        setState(() => _canResend = true);
        return false;
      }
    });
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    final success = await widget.controller.verifyOtp(otp);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAadhaar = widget.isAadhaar;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          AssetConstants.govtHeader,
          height: 36,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Text(
                isAadhaar ? 'Verify Aadhaar OTP' : 'Verify Mobile OTP',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isAadhaar
                    ? 'Enter the 6-digit verification code sent to the mobile number registered with your Aadhaar (${widget.target}).'
                    : 'Enter the 6-digit verification code sent to +91 ${widget.target}.',
                style: AppTypography.description,
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.grey600),
                    SizedBox(width: 8),
                    Text(
                      'Demo OTP: 123456',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // OTP Input Field
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
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 14,
                      color: AppColors.textPrimary,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      hintText: '••••••',
                      hintStyle: TextStyle(
                        fontSize: 22,
                        letterSpacing: 14,
                        color: AppColors.textPlaceholder,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _handleVerify(),
                  ),
                ),
              ),

              if (widget.controller.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.controller.errorMessage!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.statusError,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Resend Timer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _canResend
                        ? "Didn't receive code?"
                        : "Resend code in $_resendCountdown s",
                    style: AppTypography.description,
                  ),
                  TextButton(
                    onPressed: _canResend
                        ? () {
                            _startCountdown();
                            widget.controller.submitContinue();
                          }
                        : null,
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _canResend ? AppColors.black : AppColors.grey400,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Verify Button
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  return ContinueButton(
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
