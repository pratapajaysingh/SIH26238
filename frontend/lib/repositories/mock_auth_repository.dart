import 'dart:async';
import '../core/enums/role_enum.dart';
import '../core/network/api_response.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

/// MockAuthRepository implements AuthRepository with deterministic synthetic data
/// adhering strictly to the documented API contract.
class MockAuthRepository implements AuthRepository {
  AuthSession? _activeSession;

  @override
  Future<ApiResponse<void>> sendMobileOtp(String mobileNumber) async {
    // Simulate network delay for realistic experience
    await Future.delayed(const Duration(milliseconds: 650));

    if (mobileNumber.length != 10) {
      return const ApiResponse<void>(
        success: false,
        message: 'Invalid mobile number format. Must be 10 digits.',
        requestId: 'req-mock-auth-otp-err',
      );
    }

    return const ApiResponse<void>(
      success: true,
      message: 'OTP sent successfully to registered mobile number.',
      requestId: 'req-mock-otp-send-1',
    );
  }

  @override
  Future<ApiResponse<AuthSession>> verifyMobileOtp(String mobileNumber, String otp) async {
    await Future.delayed(const Duration(milliseconds: 750));

    if (otp != '123456' && otp.length != 6) {
      return const ApiResponse<AuthSession>(
        success: false,
        message: 'Invalid OTP. Please check the SMS or use demo OTP 123456.',
        requestId: 'req-mock-otp-err',
      );
    }

    final user = AuthUser(
      id: 'usr-st-908234',
      name: 'Rameshwar Murmu',
      mobileNumber: mobileNumber,
      role: UserRole.student,
      maskedAadhaar: 'XXXX-XXXX-4589',
      apaarId: 'APAAR-2026-9921',
      isAadhaarVerified: true,
      isPvtg: true,
      category: 'ST (Santhal)',
      state: 'Odisha',
      district: 'Mayurbhanj',
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
  Future<ApiResponse<void>> sendAadhaarOtp(String aadhaarNumber) async {
    await Future.delayed(const Duration(milliseconds: 650));

    if (aadhaarNumber.length != 12) {
      return const ApiResponse<void>(
        success: false,
        message: 'Aadhaar number must be 12 digits.',
        requestId: 'req-mock-aadhaar-err',
      );
    }

    return const ApiResponse<void>(
      success: true,
      message: 'Aadhaar OTP dispatched to linked mobile number.',
      requestId: 'req-mock-aadhaar-send-1',
    );
  }

  @override
  Future<ApiResponse<AuthSession>> verifyAadhaarOtp(String aadhaarNumber, String otp) async {
    await Future.delayed(const Duration(milliseconds: 750));

    final user = AuthUser(
      id: 'usr-st-908234',
      name: 'Rameshwar Murmu',
      mobileNumber: '9876543210',
      role: UserRole.student,
      maskedAadhaar: 'XXXX-XXXX-${aadhaarNumber.substring(8)}',
      apaarId: 'APAAR-2026-9921',
      isAadhaarVerified: true,
      isPvtg: true,
      category: 'ST',
      state: 'Odisha',
      district: 'Mayurbhanj',
    );

    final session = AuthSession(
      token: 'jwt-mock-aadhaar-token-${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      issuedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    _activeSession = session;

    return ApiResponse<AuthSession>(
      success: true,
      data: session,
      message: 'Aadhaar e-KYC authentication successful.',
      requestId: 'req-mock-aadhaar-verify-1',
    );
  }

  @override
  Future<ApiResponse<AuthSession>> loginWithDigiLocker() async {
    // Simulates the DigiLocker authorized consent handshake
    await Future.delayed(const Duration(milliseconds: 900));

    final user = const AuthUser(
      id: 'usr-st-908234',
      name: 'Rameshwar Murmu',
      mobileNumber: '9876543210',
      role: UserRole.student,
      maskedAadhaar: 'XXXX-XXXX-4589',
      apaarId: 'APAAR-2026-9921',
      isAadhaarVerified: true,
      isPvtg: true,
      category: 'ST (Santhal)',
      state: 'Odisha',
      district: 'Mayurbhanj',
    );

    final session = AuthSession(
      token: 'jwt-digilocker-mock-${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      issuedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    _activeSession = session;

    return ApiResponse<AuthSession>(
      success: true,
      data: session,
      message: 'DigiLocker consent granted. Profile retrieved.',
      requestId: 'req-mock-digilocker-1',
    );
  }

  @override
  Future<ApiResponse<AuthSession>> loginWithApaar(String apaarId) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final user = AuthUser(
      id: 'usr-st-908234',
      name: 'Rameshwar Murmu',
      mobileNumber: '9876543210',
      role: UserRole.student,
      maskedAadhaar: 'XXXX-XXXX-4589',
      apaarId: apaarId.isNotEmpty ? apaarId : 'APAAR-2026-9921',
      isAadhaarVerified: true,
      isPvtg: true,
      category: 'ST',
      state: 'Odisha',
      district: 'Mayurbhanj',
    );

    final session = AuthSession(
      token: 'jwt-apaar-mock-${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      issuedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    _activeSession = session;

    return ApiResponse<AuthSession>(
      success: true,
      data: session,
      message: 'APAAR Academic ID verified.',
      requestId: 'req-mock-apaar-1',
    );
  }

  @override
  Future<ApiResponse<AuthSession>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = AuthUser(
      id: '00000000-0000-0000-0000-000000000001',
      name: 'Demo Student User',
      mobileNumber: '9876543210',
      role: UserRole.student,
      maskedAadhaar: 'XXXX-XXXX-4589',
      apaarId: 'APAAR-2026-9921',
      isAadhaarVerified: true,
      isPvtg: true,
      category: 'ST',
      state: 'Odisha',
      district: 'Mayurbhanj',
      email: usernameOrEmail,
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
      message: 'Login successful.',
      requestId: 'req-mock-login-1',
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
