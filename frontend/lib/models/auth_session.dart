import 'auth_user.dart';

/// AuthSession represents an active user session with JWT token.
class AuthSession {
  final String token;
  final AuthUser user;
  final DateTime issuedAt;
  final DateTime expiresAt;

  const AuthSession({
    required this.token,
    required this.user,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final rawToken = (json['token'] ?? json['access_token'] ?? '').toString();
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json);

    final issuedAt = json['issued_at'] != null
        ? DateTime.tryParse(json['issued_at'].toString()) ?? DateTime.now()
        : DateTime.now();

    final expiresAt = json['expires_at'] != null
        ? DateTime.tryParse(json['expires_at'].toString()) ?? DateTime.now().add(const Duration(days: 7))
        : DateTime.now().add(const Duration(days: 7));

    return AuthSession(
      token: rawToken,
      user: AuthUser.fromJson(userMap),
      issuedAt: issuedAt,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'issued_at': issuedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
