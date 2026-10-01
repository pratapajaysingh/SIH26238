import 'token_storage_stub.dart'
    if (dart.library.io) 'token_storage_io.dart'
    if (dart.library.html) 'token_storage_web.dart'
    if (dart.library.js_interop) 'token_storage_web.dart';

/// Abstract interface for persistent authentication token storage.
///
/// NOTE: This is a prototype-grade store, not production-grade. In production,
/// this should be replaced with a secure storage provider (e.g. flutter_secure_storage
/// backed by Android Keystore / iOS Keychain).
abstract class TokenStorage {
  /// Stores access and refresh tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Retrieves the persisted access token, or null if not found.
  Future<String?> getAccessToken();

  /// Retrieves the persisted refresh token, or null if not found.
  Future<String?> getRefreshToken();

  /// Clears stored authentication tokens.
  Future<void> clearTokens();

  /// Factory constructor to instantiate platform-appropriate token storage.
  factory TokenStorage() => createTokenStorage();
}
