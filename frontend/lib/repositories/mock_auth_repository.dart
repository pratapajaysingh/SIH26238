import 'dart:async';
import '../core/enums/role_enum.dart';
import '../core/network/api_response.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import '../models/otp_request_response.dart';
import 'auth_repository.dart';

/// MockAuthRepository implements AuthRepository with deterministic synthetic data
/// adhering strictly to the documented OTP contract for offline demo usage.
class MockAuthRepository implements AuthRepository {
  AuthSession? _activeSession;

  @override
  Future<ApiResponse<OtpRequestResponse>> requestOtp(String email) async {
    // Simulate network delay for realistic experience
    await Future.delayed(const Duration(milliseconds: 500));

    return const ApiResponse<OtpRequestResponse>(
      success: true,
      data: OtpRequestResponse(
        detail: 'If that address is valid, a code has been sent.',
        expiresIn: 300,
      ),
      message: 'If that address is valid, a code has been sent.',
      requestId: 'req-mock-otp-req-1',
    );
  }

  @override
  Future<ApiResponse<AuthSession>> verifyOtp(String email, String code) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // In mock implementation, accept only 123456 and reject everything else
    if (code.trim() != '123456') {
      return const ApiResponse<AuthSession>(
        success: false,
        message: 'Invalid or expired code.',
        requestId: 'req-mock-otp-err',
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    final isAdmin = normalizedEmail.contains('admin');

    final user = AuthUser(
      id: isAdmin ? '00000000-0000-0000-0000-000000000009' : 'usr-st-908234',
      name: isAdmin
          ? 'MoTA Admin Officer'
          : (normalizedEmail.isNotEmpty ? normalizedEmail.split('@').first : 'Rameshwar Murmu'),
      mobileNumber: '',
      role: isAdmin ? UserRole.admin : UserRole.student,
      maskedAadhaar: 'XXXX-XXXX-4589',
      apaarId: 'APAAR-2026-9921',
      isAadhaarVerified: true,
      isPvtg: true,
      category: 'ST (Santhal)',
      state: 'Odisha',
      district: 'Mayurbhanj',
      email: normalizedEmail,
    );

    final session = AuthSession(
      token: 'jwt-mock-token-sample-${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      issuedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    _activeSession = session;

    return ApiResponse<AuthSession>(
      success: true,
      data: session,
      message: 'Authentication successful.',
      requestId: 'req-mock-auth-success-1',
    );
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    return _activeSession;
  }

  @override
  Future<void> logout() async {
    _activeSession = null;
  }
}
