import 'dart:convert';
import 'dart:io';
import 'token_storage.dart';

/// Prototype-grade file-based TokenStorage using local system storage.
///
/// NOTE: This is a prototype-grade store, not production-grade. In production,
/// this should be replaced with a secure storage provider (e.g. flutter_secure_storage
/// backed by Android Keystore / iOS Keychain).
class FileTokenStorage implements TokenStorage {
  File? _file;

  File _getFile() {
    if (_file != null) return _file!;
    final tempDir = Directory.systemTemp;
    _file = File('${tempDir.path}/tribalsetu_auth_tokens.json');
    return _file!;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final file = _getFile();
      final data = jsonEncode({
        'access_token': accessToken,
        'refresh_token': refreshToken,
      });
      await file.writeAsString(data);
    } catch (_) {}
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final file = _getFile();
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final map = jsonDecode(content) as Map<String, dynamic>;
      return map['access_token'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final file = _getFile();
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final map = jsonDecode(content) as Map<String, dynamic>;
      return map['refresh_token'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      final file = _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

TokenStorage createTokenStorage() => FileTokenStorage();
