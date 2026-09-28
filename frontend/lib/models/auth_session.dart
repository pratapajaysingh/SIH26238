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
    return AuthSession(
      token: json['token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      issuedAt: DateTime.parse(json['issued_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
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
