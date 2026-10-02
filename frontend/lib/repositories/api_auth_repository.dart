import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/enums/role_enum.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/network/api_response.dart';
import '../core/storage/token_storage.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import '../models/otp_request_response.dart';
import 'auth_repository.dart';

/// ApiAuthRepository implements AuthRepository over HTTP using ApiClient.
/// Fully conforms to the authoritative FastAPI OTP endpoints:
/// - POST /api/v1/auth/otp/request
/// - POST /api/v1/auth/otp/verify
class ApiAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  AuthSession? _cachedSession;

  ApiAuthRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  @override
  Future<ApiResponse<OtpRequestResponse>> requestOtp(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final response = await _apiClient.post<OtpRequestResponse>(
        ApiConstants.authOtpRequest,
        body: {'identifier': normalizedEmail},
        fromJson: (json) => OtpRequestResponse.fromJson(Map<String, dynamic>.from(json as Map)),
      );

      return response;
    } on RateLimitException catch (e) {
      return ApiResponse<OtpRequestResponse>(
        success: false,
        message: e.message,
        data: OtpRequestResponse(detail: e.message, expiresIn: e.retryAfterSeconds),
      );
    } on NetworkException catch (e) {
      return ApiResponse<OtpRequestResponse>(
        success: false,
        message: e.message,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 502) {
        return const ApiResponse<OtpRequestResponse>(
          success: false,
          message: 'Could not send the code right now. Please try again.',
        );
      }
      return ApiResponse<OtpRequestResponse>(
        success: false,
        message: e.message.isNotEmpty ? e.message : 'Could not send the code right now. Please try again.',
      );
    } catch (_) {
      return const ApiResponse<OtpRequestResponse>(
        success: false,
        message: 'Unable to connect to server. Please check your internet connection.',
      );
    }
  }

  @override
  Future<ApiResponse<AuthSession>> verifyOtp(String email, String code) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedCode = code.trim();

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.authOtpVerify,
        body: {
          'identifier': normalizedEmail,
          'code': normalizedCode,
        },
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final accessToken = (data['access_token'] ?? '').toString();
        final refreshToken = (data['refresh_token'] ?? '').toString();

        if (accessToken.isEmpty) {
          return const ApiResponse<AuthSession>(
            success: false,
            message: 'Invalid or expired code.',
          );
        }

        // Attach Authorization: Bearer <access_token> on centralized ApiClient
        _apiClient.setAuthToken(accessToken);

        // Store tokens securely in TokenStorage
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Decode JWT payload locally to extract user ID ('sub') and expiration ('exp')
        // Signature verification is performed on backend; we only read payload claims client-side.
        final payload = _decodeJwtPayload(accessToken);
        final userId = payload['sub']?.toString() ?? '00000000-0000-0000-0000-000000000001';
        final exp = payload['exp'] as int?;

        final user = AuthUser(
          id: userId,
          name: normalizedEmail.split('@').first,
          mobileNumber: '',
          role: UserRole.student,
          email: normalizedEmail,
        );

        final session = AuthSession(
          token: accessToken,
          user: user,
          issuedAt: DateTime.now(),
          expiresAt: exp != null
              ? DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true)
              : DateTime.now().add(const Duration(days: 7)),
        );

        _cachedSession = session;

        return ApiResponse<AuthSession>(
          success: true,
          data: session,
          message: 'Login successful',
        );
      }

      return const ApiResponse<AuthSession>(
        success: false,
        message: 'Invalid or expired code.',
      );
    } on AuthException {
      // 401 returns generic message deliberately to prevent user enumeration
      return const ApiResponse<AuthSession>(
        success: false,
        message: 'Invalid or expired code.',
      );
    } on NetworkException catch (e) {
      return ApiResponse<AuthSession>(
        success: false,
        message: e.message,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        return const ApiResponse<AuthSession>(
          success: false,
          message: 'Invalid or expired code.',
        );
      }
      if (e.statusCode == 422) {
        return const ApiResponse<AuthSession>(
          success: false,
          message: 'Verification code must be exactly 6 digits.',
        );
      }
      return ApiResponse<AuthSession>(
        success: false,
        message: e.message.isNotEmpty ? e.message : 'Invalid or expired code.',
      );
    } catch (_) {
      return const ApiResponse<AuthSession>(
        success: false,
        message: 'Unable to connect to server. Please check your internet connection.',
      );
    }
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    if (_cachedSession != null) return _cachedSession;

    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final payload = _decodeJwtPayload(token);
      final exp = payload['exp'] as int?;

      if (exp != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
        if (DateTime.now().toUtc().isAfter(expiry)) {
          // Token has expired
          await logout();
          return null;
        }
      }

      final userId = payload['sub']?.toString() ?? '00000000-0000-0000-0000-000000000001';
      _apiClient.setAuthToken(token);

      _cachedSession = AuthSession(
        token: token,
        user: AuthUser(
          id: userId,
          name: 'Student Beneficiary',
          mobileNumber: '',
          role: UserRole.student,
        ),
        issuedAt: DateTime.now(),
        expiresAt: exp != null
            ? DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true)
            : DateTime.now().add(const Duration(days: 7)),
      );

      return _cachedSession;
    }

    return null;
  }

  @override
  Future<void> logout() async {
    _cachedSession = null;
    _apiClient.setAuthToken(null);
    await _tokenStorage.clearTokens();
  }

  /// Decodes standard JWT payload segment locally without client-side signature verification.
  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payloadString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return {};
  }
}
