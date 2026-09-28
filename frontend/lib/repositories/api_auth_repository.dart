import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/auth_session.dart';
import 'auth_repository.dart';

/// ApiAuthRepository implements AuthRepository over HTTP using ApiClient.
/// Designed for zero-rewrite swap from MockAuthRepository when backend is live.
class ApiAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  AuthSession? _cachedSession;

  ApiAuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<ApiResponse<void>> sendMobileOtp(String mobileNumber) async {
    return _apiClient.post<void>(
      ApiConstants.authOtpSend,
      body: {'mobile_number': mobileNumber, 'channel': 'SMS'},
    );
  }

  @override
  Future<ApiResponse<AuthSession>> verifyMobileOtp(String mobileNumber, String otp) async {
    final response = await _apiClient.post<AuthSession>(
      ApiConstants.authOtpVerify,
      body: {'mobile_number': mobileNumber, 'otp': otp},
      fromJson: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
    if (response.success && response.data != null) {
      _cachedSession = response.data;
      _apiClient.setAuthToken(response.data!.token);
    }
    return response;
  }

  @override
  Future<ApiResponse<void>> sendAadhaarOtp(String aadhaarNumber) async {
    return _apiClient.post<void>(
      ApiConstants.authAadhaarOtpSend,
      body: {'aadhaar_number': aadhaarNumber},
    );
  }

  @override
  Future<ApiResponse<AuthSession>> verifyAadhaarOtp(String aadhaarNumber, String otp) async {
    final response = await _apiClient.post<AuthSession>(
      ApiConstants.authAadhaarOtpVerify,
      body: {'aadhaar_number': aadhaarNumber, 'otp': otp},
      fromJson: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
    if (response.success && response.data != null) {
      _cachedSession = response.data;
      _apiClient.setAuthToken(response.data!.token);
    }
    return response;
  }

  @override
  Future<ApiResponse<AuthSession>> loginWithDigiLocker() async {
    final response = await _apiClient.post<AuthSession>(
      ApiConstants.authDigiLocker,
      fromJson: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
    if (response.success && response.data != null) {
      _cachedSession = response.data;
      _apiClient.setAuthToken(response.data!.token);
    }
    return response;
  }

  @override
  Future<ApiResponse<AuthSession>> loginWithApaar(String apaarId) async {
    final response = await _apiClient.post<AuthSession>(
      ApiConstants.authApaar,
      body: {'apaar_id': apaarId},
      fromJson: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
    if (response.success && response.data != null) {
      _cachedSession = response.data;
      _apiClient.setAuthToken(response.data!.token);
    }
    return response;
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    if (_cachedSession != null) return _cachedSession;
    try {
      final response = await _apiClient.get<AuthSession>(
        ApiConstants.authMe,
        fromJson: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
      );
      if (response.success && response.data != null) {
        _cachedSession = response.data;
        return _cachedSession;
      }
    } catch (_) {
      // Inactive session
    }
    return null;
  }

  @override
  Future<void> logout() async {
    _cachedSession = null;
    _apiClient.setAuthToken(null);
  }
}
