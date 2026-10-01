import '../core/network/api_response.dart';
import '../models/auth_session.dart';
import '../models/otp_request_response.dart';

/// AuthRepository defines the abstract interface for authentication.
/// Conforms to the live OTP authentication contract:
/// - POST /api/v1/auth/otp/request
/// - POST /api/v1/auth/otp/verify
abstract class AuthRepository {
  /// Requests a one-time passcode for the given email identifier.
  /// Returns [OtpRequestResponse] containing backend detail and expiresIn seconds (300).
  Future<ApiResponse<OtpRequestResponse>> requestOtp(String email);

  /// Verifies the 6-digit one-time passcode against the email identifier.
  /// Returns an authenticated [AuthSession] containing bearer JWT tokens.
  Future<ApiResponse<AuthSession>> verifyOtp(String email, String code);

  /// Retrieves the current cached or persisted session if valid.
  Future<AuthSession?> getCurrentSession();

  /// Logs out the user and clears stored session credentials and tokens.
  Future<void> logout();
}
