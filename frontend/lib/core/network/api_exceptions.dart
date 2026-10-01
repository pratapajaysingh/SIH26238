/// Base exception for API communication errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => 'ApiException: $message (status: $statusCode, code: $code)';
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class AuthException extends ApiException {
  const AuthException(super.message, {super.statusCode, super.code});
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;

  const ValidationException(super.message, {this.errors = const {}, super.statusCode});
}

class RateLimitException extends ApiException {
  final int retryAfterSeconds;

  const RateLimitException(super.message, {this.retryAfterSeconds = 60, super.statusCode});
}
