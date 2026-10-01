import 'token_storage.dart';

/// In-memory token storage for Web and headless test execution.
///
/// NOTE: This is a prototype-grade store, not production-grade. In production,
/// this should be replaced with a secure storage provider.
class MemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

TokenStorage createTokenStorage() => MemoryTokenStorage();
