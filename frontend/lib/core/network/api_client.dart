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

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(
        queryParameters: queryParameters?.map((k, v) => MapEntry(k, v.toString())),
      );
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
      final uri = Uri.parse('$_baseUrl$path');
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
      final uri = Uri.parse('$_baseUrl$path');
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
      final uri = Uri.parse('$_baseUrl$path');
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
      final uri = Uri.parse('$_baseUrl$path');
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

    // Other error statuses
    String errorMessage = 'API request failed';
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
    if (error is ApiException) return error;
    return NetworkException('Network error occurred: $error');
  }
}
