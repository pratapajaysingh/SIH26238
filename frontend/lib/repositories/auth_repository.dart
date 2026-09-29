import '../core/network/api_response.dart';
import '../models/auth_session.dart';

/// AuthRepository defines the abstract interface for authentication.
/// Conforms to the repository pattern specified in Team Development & Integration Playbook.
abstract class AuthRepository {
  /// Sends an OTP to the given 10-digit mobile number.
  Future<ApiResponse<void>> sendMobileOtp(String mobileNumber);

  /// Verifies the OTP sent to the mobile number and returns an authenticated session.
  Future<ApiResponse<AuthSession>> verifyMobileOtp(String mobileNumber, String otp);

  /// Sends an OTP to the given 12-digit Aadhaar number.
  Future<ApiResponse<void>> sendAadhaarOtp(String aadhaarNumber);

  /// Verifies the Aadhaar OTP and returns an authenticated session.
  Future<ApiResponse<AuthSession>> verifyAadhaarOtp(String aadhaarNumber, String otp);

  /// Initiates DigiLocker consent/identity flow and returns an authenticated session.
  Future<ApiResponse<AuthSession>> loginWithDigiLocker();

  /// Authenticates using email/username and password directly (e.g. POST /api/v1/auth/login).
  Future<ApiResponse<AuthSession>> login({
    required String usernameOrEmail,
    required String password,
  });

  /// Initiates APAAR ID identity verification and returns an authenticated session.
  Future<ApiResponse<AuthSession>> loginWithApaar(String apaarId);

  /// Retrieves the current cached or active session if still valid.
  Future<AuthSession?> getCurrentSession();

  /// Logs out the user and clears stored session credentials.
  Future<void> logout();
}
