import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

/// ApiClient abstracts HTTP network operations conforming to the backend API.
class ApiClient {
  final http.Client _client;
  final String _baseUrl;
  String? _authToken;

  /// Optional callback invoked when a 401 Unauthorized status is returned.
  void Function()? onUnauthorized;

  ApiClient({
    http.Client? client,
    String? baseUrl,
    this.onUnauthorized,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    if (_baseUrl.trim().isEmpty) {
      throw StateError(
        'API_BASE_URL is not set. Please launch the application with '
        '--dart-define=API_BASE_URL=http://localhost:8000 (or your deployed backend URL)',
      );
    }
    final cleanBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath').replace(
      queryParameters: queryParameters?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _client.get(uri, headers: _buildHeaders(headers));
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client.post(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client.patch(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client.put(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client.delete(
        uri,
        headers: _buildHeaders(headers),
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(dynamic json)? fromJson) {
    dynamic decodedBody;
    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        throw ApiException(
          'Invalid response format from server',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody == null) {
        return const ApiResponse(success: true, message: 'Success', data: null);
      }
      return ApiResponse<T>.fromJson(decodedBody, fromJson);
    }

    // 401 Unauthorized handling
    if (response.statusCode == 401) {
      _authToken = null;
      if (onUnauthorized != null) {
        try {
          onUnauthorized!();
        } catch (_) {}
      }

      String message = 'Unauthorized access';
      if (decodedBody is Map) {
        message = decodedBody['detail']?.toString() ??
            decodedBody['message']?.toString() ??
            message;
      }
      throw AuthException(
        message,
        statusCode: response.statusCode,
      );
    }

    // 429 Too Many Requests handling with Retry-After header
    if (response.statusCode == 429) {
      final retryAfterRaw = response.headers['retry-after'];
      final retryAfterSeconds = retryAfterRaw != null ? int.tryParse(retryAfterRaw) ?? 60 : 60;
      String message = 'Too many requests. Please wait before trying again.';
      if (decodedBody is Map && decodedBody['detail'] != null) {
        message = decodedBody['detail'].toString();
      }
      throw RateLimitException(
        message,
        retryAfterSeconds: retryAfterSeconds,
        statusCode: 429,
      );
    }

    // Other error statuses (422, 502, etc.)
    String errorMessage = 'API request failed';
    if (response.statusCode == 502) {
      errorMessage = 'Could not send the code right now. Please try again.';
    }
    if (decodedBody is Map) {
      final detail = decodedBody['detail'];
      if (detail is List) {
        // FastAPI validation errors: [{"loc": [...], "msg": "..."}]
        errorMessage = detail
            .map((item) => item is Map && item['msg'] != null ? item['msg'].toString() : item.toString())
            .join('; ');
      } else if (detail != null) {
        errorMessage = detail.toString();
      } else if (decodedBody['message'] != null) {
        errorMessage = decodedBody['message'].toString();
      }
    }

    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
    );
  }

  Exception _handleError(dynamic error) {
    if (error is StateError) throw error;
    if (error is ApiException) return error;
    return const NetworkException('Unable to connect to server. Please check your internet connection.');
  }
}
